# Tech Stack, PWA & CDN Reference

> ส่วนหนึ่งของ `vibe-coding-core` — โหลดไฟล์นี้เมื่อเริ่มโปรเจกต์ใหม่ หรือเพิ่ม dependency

---

## Omni-Platform & PWA Ecosystem

### Viewport (บังคับทุกแอป)
```html
<meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover" />
```

### Adaptive Layout Strategy
```
Target Device   → Layout Style
────────────────────────────────────────────
Mobile          → SPA + Bottom Nav · Vertical Stack · Pull-to-Refresh
PC/Desktop      → Dashboard + Sidebar · Bento Grid · Wide Table
Both            → Mobile-first + md:/lg: breakpoints ทุก section
```

### PWA Structure
```
project/
├── index.html           ← Single-file app
├── manifest.webmanifest ← PWA metadata
└── sw.js                ← Service Worker
```

```javascript
// sw.js — Cache-First Strategy
const CACHE_NAME = 'app-v1'; // ← bump ทุกครั้งที่แก้โค้ด ไม่งั้น browser ใช้ cache เก่า
const STATIC_ASSETS = ['/', '/index.html'];
self.addEventListener('install', e =>
  e.waitUntil(caches.open(CACHE_NAME).then(c => c.addAll(STATIC_ASSETS)))
);
self.addEventListener('fetch', e =>
  e.respondWith(caches.match(e.request).then(cached => cached || fetch(e.request)))
);
```

### Mobile-Specific Patterns
```javascript
// Pull-to-Refresh
let startY = 0;
document.addEventListener('touchstart', e => startY = e.touches[0].clientY);
document.addEventListener('touchmove', e => {
  const dy = e.touches[0].clientY - startY;
  if (dy > 80 && window.scrollY === 0) APP_CORE.refresh();
});

// Haptic Feedback
const haptic = (pattern = 50) => {
  if ('vibrate' in navigator) navigator.vibrate(pattern);
};

// Safe Area (Notch)
// CSS: padding-bottom: max(env(safe-area-inset-bottom), 16px);
```

---

## Tech Stack

### Core (บังคับทุกโปรเจกต์)

| หมวด | เทคโนโลยี | CDN / Version |
|---|---|---|
| CSS Framework | Tailwind CSS v3 (Play CDN) | `cdn.tailwindcss.com` — **prototype เท่านั้น ดูคำเตือนด้านล่าง** |
| Icons | Lucide Icons | vendor ไว้ในเครื่อง `public/vendor/lucide.js` (ไม่ใช้ CDN — CSP-friendly + offline-first) |
| Font (ทุกอย่าง) | **Noto Sans Thai** wght 300–700 | Google Fonts · preconnect — fallback `system-ui, -apple-system, sans-serif` |
| ตัวเลขในตาราง/KPI | `font-variant-numeric: tabular-nums` | ไม่ต้องใช้ฟอนต์ mono — วัดแล้วตัวเลขของ Noto Sans Thai กว้างเท่ากันทุกตัวอยู่แล้ว (ดู design-system.md ST-2) |
| Storage | IndexedDB | Native Promise-based wrapper |
| Encryption | Web Crypto API | Native AES-GCM 256-bit |

> ⚠️ **Tailwind Play CDN ไม่เหมาะกับ production** — Tailwind ประกาศเองว่า CDN build
> ช้ากว่า, ไฟล์ CSS ใหญ่กว่า (ไม่ purge), และต้องพึ่ง `unsafe-inline` ใน CSP (ดู
> `vibe-coding-core` §8) ใช้ได้สำหรับ single-file prototype ที่พี่ A ต้องการความเร็วในการส่งมอบ
> แต่ถ้าแอปจะ deploy จริงจัง/มีผู้ใช้จำนวนมาก ให้เปลี่ยนไป build ด้วย Tailwind CLI
> (`npx tailwindcss -i input.css -o output.css --minify`) แล้ว commit ไฟล์ CSS แทน

### Optional (เพิ่มเมื่อ App ต้องการ)

| หมวด | เทคโนโลยี | เมื่อไหร่ใช้ |
|---|---|---|
| Charts | Chart.js (vendor `public/vendor/chart.js` เหมือน Lucide — ไม่ใช้ CDN) | มี data visualization / แนวโน้มย้อนหลัง |
| Cloud DB | Firestore v11 Modular | ต้องการ sync หลาย device |
| Auth | Firebase Auth 11 | มี login/user system |
| AI | Gemini 2.5 Flash (ตรวจรุ่นล่าสุดก่อนใช้จริงทุกครั้ง) | มี AI feature · BYOK |
| CORS Proxy | Cloudflare Worker | external API ที่ไม่มี CORS header |

### CDN Pinning (ห้ามใช้ @latest)
```javascript
const CDN = {
  tailwind : 'https://cdn.tailwindcss.com',
  chartjs  : 'https://cdn.jsdelivr.net/npm/chart.js@4.4.4/dist/chart.umd.min.js',
  lucide   : 'https://unpkg.com/lucide@0.460.0/dist/umd/lucide.min.js',
  firebase : 'https://www.gstatic.com/firebasejs/11.6.0/firebase-app.js',
};
```

> **Freshness check:** เวอร์ชันที่ pin ไว้ข้างบนคือค่า ณ วันที่ทำรีวิวนี้ (2026-07)
> ก่อนเริ่มโปรเจกต์ใหม่ทุกครั้ง ให้เช็คว่ามี security patch ใหม่กว่านี้ไหม (เช่นผ่าน
> `npm view <package> versions` หรือหน้า release ของแต่ละ CDN) แล้วอัปเดตเลขที่ pin —
> pin เวอร์ชันไว้เพื่อความเสถียร ไม่ใช่เพื่อค้างเวอร์ชันเก่าที่มีช่องโหว่ตลอดไป

### Cloudflare Worker CORS Proxy
```javascript
// worker.js — ตัวอย่าง: avi-proxy.supasiao.workers.dev
export default {
  async fetch(request) {
    const url = new URL(request.url);
    const target = url.searchParams.get('url');
    if (!target) return new Response('Missing url param', { status: 400 });

    // ✅ Allowlist โดเมนปลายทาง — ห้าม proxy URL ใดๆ ก็ได้แบบ open proxy
    const ALLOWED_HOSTS = ['query1.finance.yahoo.com', 'query2.finance.yahoo.com'];
    const targetHost = new URL(target).hostname;
    if (!ALLOWED_HOSTS.includes(targetHost)) {
      return new Response('Host not allowed', { status: 403 });
    }

    const res = await fetch(target, { headers: { 'User-Agent': 'Mozilla/5.0' } });
    return new Response(await res.text(), {
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
    });
  },
};
// ใช้ใน HTML: fetch(`${PROXY}?url=${encodeURIComponent(targetUrl)}`)
// Yahoo Finance SET: ticker.BK เช่น PTT.BK, PTTEP.BK
```

> **WHY allowlist:** proxy ที่รับ URL ปลายทางตามใจ user (open proxy) ถูกคนอื่นเอาไปยิง
> เว็บอื่นผ่าน Worker ของพี่ A ได้ (ทั้งเปลือง quota และเสี่ยงถูก flag ว่า abuse) — allowlist
> เฉพาะโดเมนที่แอปต้องใช้จริงเท่านั้น
