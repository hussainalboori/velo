import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const authHeader = req.headers.get('Authorization')!
    
    // 1. The USER Client (Strict security, respects RLS)
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } }
    )

    // 2. The ADMIN Client (Bypasses all security to handle billing)
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { data: { user }, error: authError } = await supabaseClient.auth.getUser()
    if (authError || !user) throw new Error("Unauthorized user")

    // Fetch profile securely using Admin
    const { data: profile, error: profileError } = await supabaseAdmin
      .from('profiles')
      .select('tier, tokens_used')
      .eq('id', user.id)
      .single()

    if (profileError || !profile) throw new Error("Could not fetch profile")

    // THE PAYWALL BLOCK
    if (profile.tier === 'free' && profile.tokens_used >= 3) {
      return new Response(JSON.stringify({ 
        error: "OUT_OF_TOKENS", 
        message: "You have reached your free AI limit. Please upgrade to Pro." 
      }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 403, 
      })
    }

    // Call OpenAI
    const { taskId, taskTitle } = await req.json()
    const openAiKey = Deno.env.get('OPENAI_API_KEY')

    const aiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${openAiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        response_format: { type: "json_object" },
        messages: [
          { role: "system", content: "You are a productivity expert. Break the user's task down into 3 to 5 logical, immediately actionable sub-tasks. Return ONLY a JSON object: { \"subtasks\": [\"Step 1\", \"Step 2\"] }" },
          { role: "user", content: `Break down this task: ${taskTitle}` }
        ]
      })
    })

    const aiData = await aiResponse.json()
    const subtaskList = JSON.parse(aiData.choices[0].message.content).subtasks

    const insertData = subtaskList.map((title: string) => ({
      title: title,
      parent_id: taskId,
    }))

    // Insert the tasks using the standard User Client
    const { error: insertError } = await supabaseClient.from('tasks').insert(insertData)
    if (insertError) throw insertError

    // Charge the token securely using the ADMIN Client
    await supabaseAdmin
      .from('profiles')
      .update({ tokens_used: profile.tokens_used + 1 })
      .eq('id', user.id)

    return new Response(JSON.stringify({ success: true, message: "Subtasks generated." }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})