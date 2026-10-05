# AI (Gemini) Integration Reference

> ส่วนหนึ่งของ `vibe-coding-core` — โหลดไฟล์นี้เมื่อแอปมี AI feature (GEMINI_AI_BRIDGE module)

---

## Config & Patterns

```javascript
// GEMINI_CONFIG — ใช้ใน GEMINI_AI_BRIDGE module
const GEMINI_CONFIG = {
  model      : 'gemini-2.5-flash', // ← ตรวจรุ่นล่าสุดที่ยังรองรับก่อนใช้จริงทุกครั้ง โมเดลเปลี่ยนเร็ว
  maxTokens  : 8192,
  temperature: 0.7,
  retries    : 4,
  backoff    : [1000, 2000, 4000, 8000], // ms — exponential
  cacheMs    : 24 * 60 * 60 * 1000,      // 24h cache
  rateLimit  : { requests: 60, windowMs: 60_000 },
};

// JSON Contract (บังคับ — ป้องกัน hallucination)
const systemPrompt = `
  ตอบเป็น JSON เท่านั้น ห้ามมีข้อความนอก JSON
  Schema: { "result": string, "confidence": number, "sources": string[] }
`;

// Streaming response
async function* streamGemini(prompt) {
  const res = await fetch(`https://generativelanguage.googleapis.com/...`, {
    method: 'POST', body: JSON.stringify({ contents: [{ parts: [{ text: prompt }] }] })
  });
  const reader = res.body.getReader();
  // yield chunks...
}
```

---

## BYOK (Bring Your Own Key) — Threat Model

รูปแบบมาตรฐานของ Vibe Coding คือให้ผู้ใช้ (พี่ A) ใส่ Gemini API key ของตัวเอง แล้วเข้ารหัส
AES-GCM 256-bit ก่อนเก็บใน IndexedDB:

```
สิ่งที่การเข้ารหัสนี้ป้องกันได้:
  ✅ คนอื่นเปิดเครื่อง/เปิด DevTools > Application > IndexedDB แล้วอ่าน key ตรงๆ ไม่ได้

สิ่งที่การเข้ารหัสนี้ *ไม่* ป้องกัน:
  ❌ XSS — decrypt logic รันในบริบท JS เดียวกับหน้าเว็บเสมอ ถ้ามี script แปลกปลอมรันสำเร็จ
     มันเรียก decrypt function เดียวกับแอปได้เลย
  ❌ การดัก network request — key ถูกส่งตรงจาก browser ไปยัง Google API ทุกครั้งที่เรียก
     (เห็นได้ใน DevTools > Network เป็นเรื่องปกติของ client-side call ไม่ใช่บั๊ก)

→ เหมาะกับ: แอปที่พี่ A ใช้คนเดียว ใส่ key ของตัวเอง ไม่แชร์ URL ให้คนอื่น
→ ไม่เหมาะกับ: แอปที่จะแชร์ link ให้คนอื่นใช้ — ให้เปลี่ยนไปใช้ Worker Proxy Pattern ด้านล่าง
```

### Worker Proxy Pattern (แนะนำสำหรับแอปที่จะแชร์)

ย้าย Gemini key ไปเก็บเป็น secret ฝั่ง server (Cloudflare Worker) แทน — client ไม่เห็น key เลย:

```javascript
// worker.js — Gemini proxy (secret เก็บด้วย `wrangler secret put GEMINI_API_KEY`)
export default {
  async fetch(request, env) {
    if (request.method !== 'POST') return new Response('Method not allowed', { status: 405 });

    // ✅ Rate limit ต่อ IP แบบง่าย (ใช้ Cloudflare KV หรือ Durable Object ถ้าต้องการแม่นยำกว่านี้)
    const body = await request.json();
    const res = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_CONFIG.model}:generateContent?key=${env.GEMINI_API_KEY}`,
      { method: 'POST', body: JSON.stringify(body), headers: { 'Content-Type': 'application/json' } }
    );
    return new Response(await res.text(), {
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
    });
  },
};
// ใช้ใน HTML: fetch(`${GEMINI_PROXY_URL}`, { method: 'POST', body: JSON.stringify({...}) })
// client ไม่ต้อง encrypt/decrypt อะไรเลย เพราะไม่มี key ให้เก็บอีกต่อไป
```

**ตัดสินใจว่าจะใช้แบบไหน:**
```
คำถาม                                    → Pattern
────────────────────────────────────────────────────
พี่ A ใช้คนเดียว ไม่แชร์ link             → BYOK + AES-GCM (เร็ว ตั้งค่าน้อย)
จะแชร์ link ให้เพื่อน/ทีม/public          → Worker Proxy (key ไม่หลุดไป client เลย)
ต้องการ track การใช้งานต่อ user           → Worker Proxy + Auth (§20 ของ vibe-coding-firebase)
```
