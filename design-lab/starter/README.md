# ไฟล์ตั้งต้น — Supasit.A Studio

ก๊อปโฟลเดอร์นี้ทั้งอัน แล้วเริ่มแอปใหม่ได้ทันที **ไม่ต้องให้ AI สร้าง token/โครงใหม่ทุกครั้ง**
ซึ่งเป็นสาเหตุที่ทำให้แต่ละแอปหน้าตาไม่ตรงกันมาตลอด

## เริ่มโปรเจกต์ใหม่ 7 ขั้นตอน

1. `cp -r design-lab/starter <ชื่อโปรเจกต์ใหม่>` — คัดลอกไฟล์ที่ขึ้นต้นด้วยจุดไปด้วย
   (`cp -r` และ `Copy-Item -Recurse` ทำให้อยู่แล้ว)
2. `npm ci && npm test` — **ต้องเขียวก่อนเริ่มเขียนฟีเจอร์แรก**
   ถ้าแดงตั้งแต่ยังไม่ได้แก้อะไร แปลว่าการคัดลอกไม่ครบ · `npm ci` ติดตั้ง git hook ให้ด้วย
3. แก้ชื่อแอป 4 จุด: `<title>` · `.app-name` · `APP_CONFIG.APP_NAME` · `manifest.webmanifest`
4. แก้ `APP_CONFIG.DB_NAME` + `STORES` ให้ตรงกับข้อมูลของแอปนี้
5. ตั้ง `APP_CONFIG.ISSUE_URL` เป็น `https://github.com/<user>/<repo>/issues/new`
   — ปุ่ม "รายงานปัญหา" จะเงียบถ้าเว้นว่างไว้
   · ตั้ง repo variable **`APP_URL`** (Settings → Secrets and variables → Actions → Variables)
     ให้ชี้ URL production — ใช้ทั้งตรวจ build stamp หลัง deploy และ uptime check
   · ตั้ง repo secret **`CLOUDFLARE_API_TOKEN`** (จำกัดสิทธิ์แค่ "Edit Cloudflare Workers")
6. ลบข้อมูลตัวอย่างใน `APP_CORE.init()` แล้วต่อกับ `STORAGE_ENGINE` ของจริง
7. bump `CACHE_NAME` ใน `sw.js` ทุกครั้งที่แก้ไฟล์ — CI มี job `cache-guard` คอยจับให้แล้ว

## คำสั่งที่ใช้จริง

| คำสั่ง | ใช้เมื่อไหร่ | เวลาที่ใช้ |
|---|---|---|
| `npm test` | ระหว่างแก้โค้ด — เร็วที่สุด ไม่ต้องมีเบราว์เซอร์ | ~2 วิ |
| `npm run e2e` | ก่อนส่งงาน — เบราว์เซอร์จริง ตรวจ contrast/44px/โฟกัส | ~10 วิ |
| `npm run check` | **ก่อน deploy ทุกครั้ง** — lint + secret + unit + e2e | ~15 วิ |
| `npm run check:local` | เครื่องที่ลง Chromium ไม่ได้ (ตัด e2e ออก) | ~5 วิ |

> เครื่องที่มี Chromium อยู่แล้วแต่โหลด build ของ Playwright ไม่ได้:
> `PW_CHROMIUM_PATH=/path/to/chrome npm run e2e`

## เทสต์ทำงานยังไง (สำคัญ — อ่านก่อนแก้โครงโค้ด)

เทสต์ **โหลด `index.html` ตัวจริงที่ deploy** เข้าไปรัน ไม่ได้คัดลอก logic ออกมาไว้อีกไฟล์
เพราะถ้าแยกออกมา สิ่งที่เทสต์ผ่านจะไม่ใช่สิ่งที่ผู้ใช้เปิด และไม่มีใครสังเกตเห็นตอนมัน drift

สิ่งที่ทำให้ทำแบบนี้ได้คือโมดูลประกาศด้วย **`var`** ที่ระดับบนสุด ซึ่งผูกกับ `window`

> ❗ **ห้ามเปลี่ยน `var MODULE = (function(){...})()` เป็น `const`**
> แอปจะยังทำงานปกติทุกอย่าง แต่เทสต์จะมองไม่เห็นโมดูลทันที
> (harness จะบอกสาเหตุนี้ให้เองเวลาเจอ — แต่รู้ไว้ก่อนดีกว่า)

เทสต์แบ่ง 2 ชั้นโดยตั้งใจ:

| ชั้น | ที่อยู่ | ตรวจอะไร | ตรวจอะไร**ไม่ได้** |
|---|---|---|---|
| unit (jsdom) | `tests/unit/` | logic · IndexedDB CRUD · migration · XSS · ธีม · error boundary | contrast · ขนาดปุ่ม · การเลื่อนหน้า · service worker |
| e2e (Playwright) | `tests/e2e/` | contrast จริง · 44px · โฟกัส · hscroll · a11y ทั้ง 2 ธีม | — |

ชั้น e2e ปิดเน็ตภายนอกทั้งหมดโดยตั้งใจ (hermetic) — ผลเทสต์จึงไม่ขึ้นกับว่า CDN ขึ้นหรือไม่
และได้ผลพลอยได้เป็นการพิสูจน์ว่าแอปยังใช้ได้ตอนออฟไลน์

## มีอะไรมาให้แล้ว

| ไฟล์ | เนื้อหา |
|---|---|
| `index.html` | token Supasit.A Studio ครบ (สว่าง + มืด 3 สถานะ) · component พื้นฐาน · โครง 9 โมดูล IIFE · ปุ่มสลับธีม · badge · boot splash นีออนกระพริบ (D1/D2) · CSP · helper กัน XSS |
| `chart-theme.js` | ธีม Chart.js ที่อ่านสีจาก CSS variable — สลับธีมแล้วกราฟตามเอง |
| `sw.js` | Service Worker cache-first |
| `manifest.webmanifest` | PWA manifest |
| `assets/icon.svg` | ไอคอนแอป (A(i)CODER ชุด Studio) |
| `assets/d1-neon-arcade-bare.svg` · `assets/d2-crt-night-bare.svg` | นีออนกระพริบสำหรับ boot splash เท่านั้น (ดู `branding/README.md`) — ไม่มีพื้นหลังของตัวเอง ต้องวางบน `var(--bg)` เสมอ ห้ามเอาไปแทน `.logo`/`.aicoder-badge` เพราะเล็กกว่าขนาดต่ำสุดของมันมาก |
| `tests/` + `tools/serve.mjs` | ชุดทดสอบ 2 ชั้น (รายละเอียดข้างบน) |
| `.github/workflows/` | CI ที่กันโค้ดไม่ผ่านเทสต์ขึ้น production · preview URL ทุก PR · uptime check รายชั่วโมง |
| `.assetsignore` | กันไฟล์เทสต์/config หลุดขึ้น public URL ตอน deploy |
| `.husky/pre-commit` | รัน format + secret scan + unit test ก่อน commit ให้อัตโนมัติ |

## กติกาที่ห้ามพลาด

- **ห้าม `innerHTML` กับข้อมูลจากผู้ใช้** — ใช้ `UI_RENDERER.el()` ที่เขียนด้วย `textContent` ให้แล้ว
- **`localStorage` ต้องอยู่ใน `try/catch` เสมอ** — โหมดส่วนตัวโยน error ได้ ถ้าไม่ดักหน้าจะพังทั้งหน้า
- **ธีมต้องครบ 3 สถานะ** — `:root` (สว่าง) · `prefers-color-scheme` (ตามระบบ) · `[data-theme]` (ผู้ใช้เลือก)
  การไม่ stamp `data-theme` เลยคือ "ตามระบบ" — อย่าเผลอ stamp ค่าเริ่มต้นทับ
- **ทุกสีต้องมาจาก token** — ห้าม hardcode hex ในโค้ดแอป (รวม badge ด้วย ยกเว้นจุดกลม `#F2B705` ที่คงที่ตั้งใจตาม studio-badge-*.svg)
- **เป้าแตะบนมือถืออย่างน้อย 44px** — `.btn` ตั้งไว้ให้แล้ว ปุ่มที่เขียนเพิ่มต้องรักษาเกณฑ์นี้
- **Chart.js** ต้อง `.destroy()` ก่อนสร้างใหม่ทุกครั้งที่ re-render ไม่งั้น instance ค้างจนหน่วยความจำบวม
- **เปลี่ยน `DB_VERSION` ต้องเขียน migration แบบเพิ่มอย่างเดียว** — ไม่มี down-migration
  `STORAGE_ENGINE.open()` ปิด connection เก่าให้เองเมื่อมีเวอร์ชันใหม่ขอ upgrade (`onversionchange`)
  และ reject พร้อมข้อความที่อ่านรู้เรื่องถ้าโดนบล็อก — สองอันนี้ **ไม่มีอยู่เดิม** เทสต์ migration
  เป็นคนเจอ (เปิดแอปไว้ 2 แท็บแล้ว bump version = แท็บที่สองค้างถาวรโดยไม่มี error)
