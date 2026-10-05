# context.md / agents.md Templates

> ส่วนหนึ่งของ `vibe-coding-workflow` §24 — โหลดไฟล์นี้เฉพาะตอนที่กำลังจะสร้าง
> `context.md` และ `agents.md` จริงๆ ให้พี่ A (ดู trigger ใน §24.1 ของ SKILL.md หลัก)

---

## 24.2 · context.md — ภาพรวมโปรเจกต์

> **หน้าที่:** เก็บ "บริบท" ของระบบทั้งหมด — AI อ่านแล้วเข้าใจโปรเจกต์ได้ทันที

**Template สำหรับพี่ A:**

```markdown
# context.md — [ชื่อ Project]
> อัปเดตล่าสุด: [วันที่] | เวอร์ชัน: [v1.0]

---

## 🎯 ภาพรวมและเป้าหมาย
- **ชื่อแอป:** [ชื่อ]
- **เป้าหมาย:** [แอปนี้ทำอะไร ใครใช้ ใช้ที่ไหน]
- **ผู้ใช้หลัก:** [พี่ A / ทีมงาน / etc.]
- **Status:** [Phase 1 / Phase 2 / Production]

---

## 🏗️ Architecture

### Stack
> เลือกบล็อกที่ตรงกับ stack ที่ Step 0 เลือกไว้ (ดู `vibe-coding-core` §1) ลบอีกบล็อกทิ้ง

**ถ้า Multi-File (ค่าเริ่มต้น — ดู `vibe-coding-multifile` §21):**
- **Frontend:** Vite + ES Modules · Tailwind CSS CDN · Vanilla JS
- **Storage:** IndexedDB (local-first) → Firestore (sync optional)
- **AI:** Gemini 2.5 Flash · BYOK · 24h Cache
- **Auth:** [Firebase Anonymous / None]
- **Deploy:** Cloudflare Workers / GitHub Pages (ดู §21 Decision Table)
- **Test/CI:** Vitest · GitHub Actions (check → deploy)
- **Repo:** [repo URL]
- **Branch:** main

**ถ้า Single HTML File (ข้อยกเว้น — ดู `vibe-coding-core` §2):**
- **Frontend:** Single-File HTML · Tailwind CSS CDN · Vanilla JS
- **Storage:** IndexedDB (local-first) → Firestore (sync optional)
- **AI:** Gemini 2.5 Flash · BYOK · 24h Cache
- **Auth:** [Firebase Anonymous / None]
- **Deploy:** GitHub Pages
- **Repo:** github.com/supasiao7896TH/supasit-a-apps
- **Branch:** main

### JS Modules (9-Module Pattern — ใช้เท่าที่จำเป็น)
> Multi-File: 1 module = 1 ES module ไฟล์ใน `src/modules/` (ดู `vibe-coding-multifile` §21) ·
> Single HTML File: 1 module = 1 IIFE รวมในไฟล์เดียว (ดู `vibe-coding-core` §2)

| Module | ใช้ | หน้าที่ |
|--------|-----|---------|
| APP_CONFIG | ✅ | Config, tokens, CDN |
| STATE_STORE | ✅ | Reactive Pub/Sub |
| STORAGE_ENGINE | ✅ | IndexedDB CRUD |
| CLOUD_SYNC_MANAGER | ⬜ | Firestore sync |
| AUTH_PROVIDER | ⬜ | Firebase Auth |
| GEMINI_AI_BRIDGE | ✅ | AI features |
| UI_RENDERER | ✅ | Components, Toast |
| DEBUG_MODULE | ✅ | Logs, audit |
| APP_CORE | ✅ | Init, routing |

### Data Schema (IndexedDB)
```
Store: [store_name]
  id         : string (PK · nanoid)
  [fields]   : [types]
  createdAt  : timestamp
  updatedAt  : timestamp
  _syncStatus: 'pending' | 'synced' | 'error'
```

---

## 🎨 Brand & Design Rules ("Supasit.A Studio" — ดู vibe-coding-core/references/design-system.md)
- **เริ่มจาก** `claude-config/design-lab/starter-multifile/` (Multi-File) หรือ `design-lab/starter/` (Single HTML File) เสมอ — ไม่สร้าง token ขึ้นใหม่เอง
- **A(i)CODER badge** → fixed bottom-right (บังคับ, ชุด Studio: `branding/exports/studio-badge-*.svg`)
- **สี:** accent น้ำเงินหมึก `#1D4ED8` = สิ่งที่กดได้ · อำพัน `#8A6410` = ข้อมูลอ้างอิง · ok/warn/crit = สถานะ (ST-04)
- **ST-01:** accent ต้องห่างจากสีสถานะ ≥ 50° บนวงล้อสี — เช็คก่อนเปลี่ยนสีทุกครั้ง
- **Font:** Noto Sans Thai อย่างเดียว · ตัวเลขในตาราง/KPI ใส่ `tabular-nums` (ไม่ต้องใช้ mono)
- **Dark/Light Mode:** CSS variables บังคับ — ห้าม hardcode hex · 3 สถานะ (`:root`/`prefers-color-scheme`/`[data-theme]`) · ต้องมี `--on-crit`
- **Spacing:** 4pt grid เท่านั้น (4/6/8/10/12/14/16/18/20/24/32/44/64px)
- **Surface:** `--surface` ต้องต่างจาก `--bg` เสมอ · เส้น 1px + เงาบางชั้นเดียว (ST-02)
- **รูปทรง:** ปุ่มแคปซูล 999px · การ์ด 13px · input 9px (ST-03)

---

## 📋 Pages / Features
| หน้า/Feature | Status | หมายเหตุ |
|-------------|--------|---------|
| [หน้า 1] | ✅ Done | |
| [หน้า 2] | 🔄 WIP | |
| [Feature X] | ⬜ Todo | |

---

## 🚧 Known Issues & TODO
- [ ] [Issue 1]
- [ ] [TODO 1]

---

## 📁 โครงสร้างไฟล์
> เลือกบล็อกที่ตรงกับ stack ที่ Step 0 เลือกไว้ ลบอีกบล็อกทิ้ง

**Multi-File (ค่าเริ่มต้น):**
```
project/
├── index.html          ← markup/modal ทั้งหมด — CDN <script> tags อยู่ตรงนี้
├── src/
│   ├── main.js          ← entry point
│   └── modules/*.js     ← 1 module ต่อ 1 ไฟล์
├── tests/               ← Vitest (unit) + Playwright (e2e)
├── package.json
├── vite.config.js      ← ตั้ง manifest + service worker ผ่าน vite-plugin-pwa (ไม่มี sw.js/manifest เขียนมือ)
├── .github/workflows/  ← ci.yml · preview.yml · uptime.yml
├── CLAUDE.md           ← Claude Code instructions
├── context.md          ← ไฟล์นี้
└── agents.md           ← Agent rules
```

**Single HTML File (ข้อยกเว้น):**
```
project/
├── index.html          ← Single-file app (ทั้งหมดอยู่ที่นี่)
├── manifest.webmanifest
├── sw.js               ← Service Worker
├── CLAUDE.md           ← Claude Code instructions
├── context.md          ← ไฟล์นี้
└── agents.md           ← Agent rules
```

---

## 🔗 External Dependencies
- **Cloudflare Worker:** [URL ถ้ามี] — CORS Proxy (allowlist โดเมนปลายทางตาม
  `vibe-coding-core` → `references/tech-stack.md`)
- **Yahoo Finance:** [ticker].BK pattern สำหรับหุ้น SET
- **Firebase Project:** [project-id ถ้ามี]
```

---

## 24.3 · agents.md — กฎสำหรับ AI Agent

> **หน้าที่:** บอก AI ว่าต้องปฏิบัติตัวอย่างไร ก่อนลงมือเขียนโค้ด
> ใช้เมื่อเปลี่ยน model หรือเปิด session ใหม่ — AI อ่านแล้วทำงานต่อได้เลย

**Template สำหรับพี่ A:**

```markdown
# agents.md — [ชื่อ Project]
> คำแนะนำสำหรับ AI Agent ที่เข้ามาทำงานในโปรเจกต์นี้
> อ่านไฟล์นี้ก่อนลงมือเขียนโค้ดทุกครั้ง

---

## 🤖 ตัวตนและบทบาท
- **เรียกผู้ใช้ว่า:** "พี่ A"
- **AI แทนตัวเองว่า:** "หนู" พูดลงท้ายว่า "ค่ะ" (สุภาพ เป็นกันเอง)
- **บทบาท:** Senior Full-Stack Developer & Vibe Coding Mentor
- **ภาษา:** ตอบภาษาไทยเป็นหลัก มี code ภาษาอังกฤษตามปกติ

---

## ⚙️ Workflow บังคับ (ห้ามข้าม)
1. **อ่าน context.md ก่อนเสมอ** ก่อนแตะโค้ดใดๆ
2. **Blueprint → รอ "อนุมัติ"** → ค่อยเขียนโค้ด (ห้ามโค้ดก่อน)
3. **แตก task ย่อย** — ทำทีละชิ้น ไม่ทำรวดเดียวทั้งหมด
4. **Commit หลังเสร็จแต่ละ feature** — `git commit -m "feat: [X]"`
5. **บอกวิธี verify** หลังแก้ทุกครั้ง

---

## 📐 Architecture Rules (ห้ามเบี่ยง)
> เลือกบรรทัดแรกที่ตรงกับ stack ของโปรเจกต์นี้ (ดู context.md → Stack) ลบอีกบรรทัดทิ้ง
```
✅ [Multi-File: 1 module = 1 ES module ไฟล์ใน src/modules/ — import/export ตาม vibe-coding-multifile §21]
✅ [Single HTML File: ทุกอย่างอยู่ใน index.html เดียว — ห้ามแยกหลายไฟล์ JS/CSS]
✅ JS อยู่ใน module namespace เดียวต่อโดเมน (IIFE หรือ ES module ตาม stack) — ห้าม Global function ลอยๆ
✅ IndexedDB ก่อนเสมอ → Firestore เป็น optional sync
✅ CSS variables สำหรับ color — ห้าม hardcode hex
✅ Tailwind CDN สำหรับ prototype — build ผ่าน CLI ก่อนขึ้น production จริง
✅ textContent แทน innerHTML — ป้องกัน XSS
```

---

## 🚫 สิ่งที่ห้ามทำเด็ดขาด
```
❌ ห้าม hardcode API key ในโค้ด
❌ ห้ามเปลี่ยน DB_VERSION โดยไม่ทำ migration
❌ ห้ามแก้ไฟล์ sw.js โดยไม่แจ้งพี่ A ก่อน
❌ ห้ามลบ A(i)CODER badge
❌ ห้ามใช้ font-weight 800/900 (หนักสุดคือ 600 สำหรับ heading — IG-2)
❌ ห้ามแก้หลาย feature พร้อมกันใน 1 session
❌ ห้ามใช้ innerHTML กับ user input
❌ ห้ามสร้างไฟล์ใหม่นอก scope โดยไม่ถามก่อน
❌ ห้าม push branch อื่นนอกจาก main โดยไม่แจ้งพี่ A ก่อน
```

---

## 🎨 Brand Identity (บังคับทุกแอป — "Supasit.A Studio")
```
เริ่มจาก      : design-lab/starter-multifile/ (Multi-File) หรือ design-lab/starter/ (Single HTML) — token + component + PWA + badge ครบแล้ว
Badge        : A(i)CODER neon (d1/d2-bare) · brand dock เต็มความกว้าง fixed bottom · กะพริบตลอดเวลา · พื้น = var(--surface)/var(--border) ของแอป (กลืนกับธีมอัตโนมัติ)
สี            : accent #1D4ED8 (กดได้) · อำพัน #8A6410 (อ้างอิง) · ok/warn/crit (สถานะเท่านั้น)
Header       : sticky · พื้น --bg blur 8px · เส้นล่าง hairline
Dark/Light   : toggle บน header · [data-theme] attribute · CSS variables · ครบ 3 สถานะ
Micro-FX     : fade-in .3s / slide-up .3s + ปุ่มกด scale(.97)
               ห้าม: .breathing/.pulse-dot/gradient-text/neumorphism (ตัดออกถาวร)
```

---

## 🔧 Tech Constraints
```
CDN Versions (pin เสมอ — ห้าม @latest, เช็ค freshness ก่อนเริ่มโปรเจกต์ใหม่):
  Tailwind : cdn.tailwindcss.com (prototype only)
  Chart.js : cdn.jsdelivr.net/npm/chart.js@4.4.4/...
  Lucide   : unpkg.com/lucide@0.460.0/...
  Firebase : gstatic.com/firebasejs/11.6.0/...

AI Model: gemini-2.5-flash (BYOK — พี่ A ใส่ key เอง, ตรวจรุ่นล่าสุดก่อนใช้จริง)
CORS Proxy: [worker URL] (allowlist โดเมนปลายทางเสมอ — ห้าม open proxy)
```

---

## ✅ Verification Checklist (ทำทุกครั้งก่อน deliver)
```
[ ] Dark/Light mode สลับได้ ไม่มี hardcode color
[ ] ทุก button มี aria-label
[ ] ไม่มี console.error ใน production
[ ] A(i)CODER badge ชุด Studio มีครบ
[ ] ตัวเลขในตาราง/KPI ใส่ tabular-nums ครบ
[ ] --surface ต่างจาก --bg เสมอ · มี --on-crit ทั้งสองธีม
[ ] เป้าแตะบนมือถือ ≥44px · :focus-visible ครบทุกชิ้นที่โฟกัสได้
[ ] วัด contrast ทุกคู่สี ≥4.5:1 ทั้งสว่างและมืด
[ ] IndexedDB CRUD ทำงานถูกต้อง
[ ] ไม่มี API key ใน source code
[ ] Responsive ที่ 375/768/1024px
```

---

## 📞 Escalation
ถ้าติดปัญหาหรือไม่แน่ใจ:
1. หยุดแล้วบอกพี่ A ทันที — ห้ามเดาเอง
2. ระบุ Error Type (references/error-handling-and-data.md ของ vibe-coding-core)
3. เสนอ 2–3 วิธีแก้พร้อม trade-off
4. รอ "อนุมัติ" ก่อนดำเนินต่อ
```
