import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

serve(async (req) => {
  try {
    const payload = await req.json()
    const event = payload.event

    // RevenueCat sends the Supabase Auth UID exactly as we passed it from Flutter
    const userId = event.app_user_id
    const eventType = event.type 

    // We must use the SERVICE_ROLE key here to bypass RLS since this is server-to-server
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Determine the new tier based on the RevenueCat event
    let newTier = 'free'
    if (eventType === 'INITIAL_PURCHASE' || eventType === 'RENEWAL') {
      newTier = 'pro'
    } else if (eventType === 'EXPIRATION' || eventType === 'CANCELLATION' || eventType === 'BILLING_ISSUE') {
      newTier = 'free'
    } else {
      // Ignore other events like trial starts or non-critical updates
      return new Response(JSON.stringify({ message: "Event ignored" }), { status: 200 })
    }

    // Update the user's profile in the database
    const { error } = await supabaseAdmin
      .from('profiles')
      .update({ tier: newTier })
      .eq('id', userId)

    if (error) throw error

    return new Response(JSON.stringify({ success: true, newTier }), { status: 200, headers: { "Content-Type": "application/json" } })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 400 })
  }
})
