import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

async function isValidSignature(body: string, signature: string, secret: string): Promise<boolean> {
  if (!signature || !secret) return false

  const encoder = new TextEncoder()
  const key = await crypto.subtle.importKey(
    'raw',
    encoder.encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  )

  const digest = await crypto.subtle.sign('HMAC', key, encoder.encode(body))
  const signatureHex = Array.from(new Uint8Array(digest))
    .map((value) => value.toString(16).padStart(2, '0'))
    .join('')

  return signature.toLowerCase() === signatureHex.toLowerCase()
}

serve(async (req) => {
  try {
    const secret = Deno.env.get('REVENUECAT_WEBHOOK_SECRET') ?? ''
    const signature = req.headers.get('x-revenuecat-signature') ?? ''
    const rawBody = await req.text()

    if (!secret || !signature || !(await isValidSignature(rawBody, signature, secret))) {
      return new Response(JSON.stringify({ error: 'Unauthorized webhook request' }), {
        headers: { 'Content-Type': 'application/json' },
        status: 401,
      })
    }

    const body = JSON.parse(rawBody)
    const event = body.event

    if (!event) throw new Error('No event found')

    const userId = event.app_user_id
    const eventType = event.type

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    let newTier = 'free'

    if (eventType === 'INITIAL_PURCHASE' || eventType === 'RENEWAL') {
      newTier = 'pro'
    } else if (eventType === 'CANCELLATION' || eventType === 'EXPIRATION') {
      newTier = 'free'
    } else {
      return new Response(JSON.stringify({ message: 'Event ignored' }), { status: 200 })
    }

    const { error } = await supabaseAdmin
      .from('profiles')
      .update({ tier: newTier })
      .eq('id', userId)

    if (error) throw error

    return new Response(JSON.stringify({ success: true, updated_to: newTier }), {
      headers: { 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})