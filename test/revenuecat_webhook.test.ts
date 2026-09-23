import { expect, test, describe, mock } from "bun:test"

mock.module("https://deno.land/std@0.168.0/http/server.ts", () => ({
  serve: () => {},
}))

mock.module("https://esm.sh/@supabase/supabase-js@2", () => ({
  createClient: () => {},
}))

const { timingSafeEqual, isValidSignature } = await import("../supabase/functions/revenuecat-webhook/index.ts")

describe("timingSafeEqual", () => {
  test("returns true for identical Uint8Arrays", () => {
    const a = new Uint8Array([1, 2, 3, 4, 5])
    const b = new Uint8Array([1, 2, 3, 4, 5])
    expect(timingSafeEqual(a, b)).toBe(true)
  })

  test("returns false for Uint8Arrays with different lengths", () => {
    const a = new Uint8Array([1, 2, 3])
    const b = new Uint8Array([1, 2, 3, 4])
    expect(timingSafeEqual(a, b)).toBe(false)
  })

  test("returns false for Uint8Arrays with different content at start", () => {
    const a = new Uint8Array([0, 2, 3, 4, 5])
    const b = new Uint8Array([1, 2, 3, 4, 5])
    expect(timingSafeEqual(a, b)).toBe(false)
  })

  test("returns false for Uint8Arrays with different content at end", () => {
    const a = new Uint8Array([1, 2, 3, 4, 0])
    const b = new Uint8Array([1, 2, 3, 4, 5])
    expect(timingSafeEqual(a, b)).toBe(false)
  })
})

describe("isValidSignature", () => {
  const secret = "test_webhook_secret_123"
  const body = JSON.stringify({
    event: {
      type: "INITIAL_PURCHASE",
      app_user_id: "user_12345",
    },
  })

  async function computeHmacHex(payload: string, keySecret: string): Promise<string> {
    const encoder = new TextEncoder()
    const key = await crypto.subtle.importKey(
      "raw",
      encoder.encode(keySecret),
      { name: "HMAC", hash: "SHA-256" },
      false,
      ["sign"]
    )
    const digest = await crypto.subtle.sign("HMAC", key, encoder.encode(payload))
    return Array.from(new Uint8Array(digest))
      .map((val) => val.toString(16).padStart(2, "0"))
      .join("")
  }

  test("returns true for valid HMAC SHA-256 signature", async () => {
    const validSignature = await computeHmacHex(body, secret)
    const result = await isValidSignature(body, validSignature, secret)
    expect(result).toBe(true)
  })

  test("returns true for valid HMAC SHA-256 signature with different case", async () => {
    const validSignature = await computeHmacHex(body, secret)
    const result = await isValidSignature(body, validSignature.toUpperCase(), secret)
    expect(result).toBe(true)
  })

  test("returns false for invalid signature value", async () => {
    const validSignature = await computeHmacHex(body, secret)
    const tamperedSignature = validSignature.slice(0, -1) + (validSignature.slice(-1) === "a" ? "b" : "a")
    const result = await isValidSignature(body, tamperedSignature, secret)
    expect(result).toBe(false)
  })

  test("returns false when signature length does not match expected digest length", async () => {
    const result = await isValidSignature(body, "invalid_short_signature", secret)
    expect(result).toBe(false)
  })

  test("returns false when signature or secret is empty", async () => {
    const validSignature = await computeHmacHex(body, secret)
    expect(await isValidSignature(body, "", secret)).toBe(false)
    expect(await isValidSignature(body, validSignature, "")).toBe(false)
  })
})
