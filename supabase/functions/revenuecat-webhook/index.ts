import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

serve(async (req) => {
  try {
    // 1. Parse the incoming webhook from RevenueCat
    const body = await req.json()
    const event = body.event

    if (!event) throw new Error("No event found")

    // The app_user_id is the user's Supabase UUID that we pass to RevenueCat in Flutter
    const userId = event.app_user_id
    const eventType = event.type 

    // 2. Wake up the Admin database client (to bypass security rules for billing)
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    let newTier = 'free'

    // 3. Determine their new status based on what happened
    if (eventType === 'INITIAL_PURCHASE' || eventType === 'RENEWAL') {
      newTier = 'pro'
    } else if (eventType === 'CANCELLATION' || eventType === 'EXPIRATION') {
      newTier = 'free'
    } else {
      // Ignore other random RevenueCat events (like test pings)
      return new Response(JSON.stringify({ message: "Event ignored" }), { status: 200 })
    }

    // 4. Update their profile in the database!
    const { error } = await supabaseAdmin
      .from('profiles')
      .update({ tier: newTier })
      .eq('id', userId)

    if (error) throw error

    return new Response(JSON.stringify({ success: true, updated_to: newTier }), {
      headers: { "Content-Type": "application/json" },
      status: 200,
    })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { "Content-Type": "application/json" },
      status: 400,
    })
  }
})