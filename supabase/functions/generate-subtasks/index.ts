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
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    )

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
          { 
            role: "system", 
            content: "You are a productivity expert. Break the user's task down into 3 to 5 logical, immediately actionable sub-tasks. Return ONLY a JSON object in this exact format: { \"subtasks\": [\"Step 1\", \"Step 2\", \"Step 3\"] }" 
          },
          { 
            role: "user", 
            content: `Break down this task: ${taskTitle}` 
          }
        ]
      })
    })

    const aiData = await aiResponse.json()
    const subtaskList = JSON.parse(aiData.choices[0].message.content).subtasks

    const insertData = subtaskList.map((title: string) => ({
      title: title,
      parent_id: taskId,
    }))

    const { error } = await supabaseClient.from('tasks').insert(insertData)
    
    if (error) throw error

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