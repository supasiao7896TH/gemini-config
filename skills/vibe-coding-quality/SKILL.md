---
name: vibe-coding-quality
description: >
  Quality & Release Engineering Skill ของ Supasit.A — ใช้เมื่อพี่ A พูดถึงการทดสอบ
  (test/เทสต์/unit test/e2e), CI/CD, lint/format, secret scan, preview ก่อนขึ้นจริง,
  rollback/ย้อนกลับเวอร์ชัน, observability/ดู error ของผู้ใช้, GitHub Issues,
  หรือถามว่า "workflow ถูกหลัก software engineering ไหม" · ครอบคลุมวิธี test
  Single HTML File โดยไม่ต้องย้ายไป Vite · ไม่ใช้กับการออกแบบ UI หรือสร้างแอปใหม่
  ตั้งแต่ต้น (→ vibe-coding-core) หรือการไล่บักรายตัว (→ vibe-coding-workflow)
---

# Vibe Coding Quality — Supasit.A Skill

> **Role:** Quality & Release Engineer
> **Mission:** เปลี่ยนกฎที่ต้อง "จำเอง" ให้เป็นกฎที่ "เครื่องบังคับ"
> **Mandate:** ทุกกฎที่สำคัญต้องรันได้ด้วยคำสั่งเดียว และทุกการเปลี่ยนแปลงบน production ต้องย้อนกลับได้

| | |
|---|---|
| **Version** | 1.3 |
| **Updated** | 2026-09 |
| **Sections in this file** | §25 |
| **Related skills** | `vibe-coding-core` (§1–2, §8, §16–17) · `vibe-coding-workflow` (§18–19, §23–24) · `vibe-coding-multifile` (§21) · `cloudflare-workers-deploy` |

---

## § 25.0 · ปัญหาที่ skill นี้แก้

ก่อนหน้านี้กระบวนการทำงานของพี่ A มีครบเกือบทุกอย่างที่ทีมมืออาชีพมี — Blueprint ที่ต้อง
ขออนุมัติ · loop ที่จำกัดรอบไม่ให้วนแก้ไม่จบ · QA/Deploy checklist · Git Safety Protocol ·
subagent แบ่งหน้าที่ชัด

**แต่ทั้งหมดเป็นข้อความใน markdown ที่คนหรือ AI ต้องจำเอง ไม่มีเครื่องบังคับสักตัว**

ผลที่เกิดขึ้นจริงและตรวจสอบได้:

| กฎที่เขียนไว้ | ความจริงก่อนมี skill นี้ |
|---|---|
| `sa-code-reviewer` "ใช้ทุกครั้งก่อน commit" | ไม่มี workflow step ไหนเรียกมันเลย |
| §16 "วัด contrast ด้วยเครื่อง ไม่ใช่กะด้วยตา" | ไม่มีเครื่องไหนวัด |
| `sa-git-manager` "ห้าม `git add -A`" | skill 2 ตัวสั่งให้ใช้ `git add -A` |
| §18.2 CLAUDE.md template | ยังเขียนฟอนต์ Sarabun/Fraunces ที่เลิกใช้ไป 2 design system แล้ว |
| §2 "APP_CORE มี Global Error Boundary" | starter ไม่เคย implement |

**หลักการของ skill นี้:** กฎที่ตรวจด้วยเครื่องได้ ต้องมีเครื่องตรวจ · กฎที่เหลือต้องบอกชัดว่า
ใครเป็นคนตรวจ · checklist ที่ไม่บอกว่าใครรันแต่ละบรรทัด คือ checklist ที่ไม่มีใครรัน

---

## § 25.1 · คำสั่งเดียวที่ต้องจำ

```bash
npm run check         # lint + secret scan + unit + e2e — ต้องเขียวก่อน deploy เสมอ
npm run check:local   # ชุดเดียวกันแต่ตัด e2e ออก (เครื่องที่ลง Chromium ไม่ได้)
npm test              # unit อย่างเดียว ~2 วิ — ใช้ระหว่างแก้โค้ด
npm run e2e           # เบราว์เซอร์จริง ~10 วิ — contrast/44px/โฟกัส/hscroll
```

| slash command | ทำอะไร |
|---|---|
| `/ตรวจ` | รัน `npm run check` แล้วต่อด้วย `sa-code-reviewer` รายงานผ่าน/ไม่ผ่านทีละข้อ |
| `/preview` | push branch แล้วรอ preview URL ที่เปิดบนมือถือได้ |
| `/rollback` | เดิน rollback runbook แบบโต้ตอบทีละขั้น |
| `/deploy` | Deployment Checklist §17 (ต้องผ่าน `/ตรวจ` ก่อน) |

---

## § 25.2 · วิธีทดสอบ Single HTML File (หัวใจของ skill นี้)

**หัวข้อนี้ใช้เฉพาะกรณี Single HTML File (ข้อยกเว้น ดู `vibe-coding-multifile` §21 Decision
Table — Multi-File คือค่าเริ่มต้นตั้งแต่ 2569-09-02) ถ้าโปรเจกต์เลือก Single HTML File โดย
ตั้งใจแล้ว ห้ามเสนอให้ย้ายไป Vite แค่เพื่อให้ test ได้ — วิธีข้างล่างนี้มีอยู่เพื่อไม่ให้ต้อง
เสนอแบบนั้นอีก (ถ้าโปรเจกต์เป็น Multi-File อยู่แล้ว ใช้ Vitest ตรงๆ ตาม `vibe-coding-multifile`
§21 แทน ไม่ต้องอ่านหัวข้อนี้)**

ข้อเท็จจริง 2 ข้อที่ทำให้ทดสอบได้โดยไม่ต้องแก้สถาปัตยกรรม:

1. `design-lab/starter/` เป็นโฟลเดอร์อยู่แล้ว (index.html + sw.js + chart-theme.js +
   manifest + assets) มาตรฐานจริงคือ **"ไม่มี build step · ดับเบิลคลิกเปิดได้ ·
   deploy ด้วยการ copy โฟลเดอร์"** → `package.json` + `tests/` + `.github/` ไม่ผิดกติกา
   เพราะไม่มีตัวไหนถูกส่งไปที่เบราว์เซอร์ (และ `.assetsignore` กันไม่ให้หลุดขึ้น public URL)
2. โมดูลประกาศด้วย `var MODULE = (function(){...})()` → ผูกกับ `window` → เข้าถึงจากภายนอกได้

> ❗ **กฎเหล็ก:** โมดูลต้องเป็น `var` ที่ top-level เท่านั้น **ห้ามเปลี่ยนเป็น `const`**
> `const` ที่ top-level ไม่ผูกกับ `window` — แอปยังทำงานปกติทุกอย่าง แต่เทสต์มองไม่เห็นทันที
> (`tests/harness/load-app.mjs` จะบอกสาเหตุนี้ให้เองเวลาเจอ)

### แบ่ง 2 ชั้นตามสิ่งที่แต่ละชั้น "พิสูจน์ได้จริง"

| ชั้น | เครื่องมือ | พิสูจน์ได้ | พิสูจน์**ไม่ได้** |
|---|---|---|---|
| unit | Vitest + jsdom + fake-indexeddb | logic · IndexedDB CRUD · migration · XSS · ธีม 3 สถานะ · error boundary | contrast · ขนาดปุ่ม · การเลื่อนหน้า · focus ring · service worker |
| e2e | Playwright + axe-core | ทุกอย่างในคอลัมน์ขวาข้างบน ทั้ง 2 ธีม | — |

🔴 **ห้ามอ้างว่า `npm test` ครอบคลุมหมวด ACCESSIBILITY/BRAND ของ §16** — jsdom ไม่มี
layout engine และไม่มี CSS cascade จริง หมวดนั้นเป็นงานของ `npm run e2e` เท่านั้น

### เกณฑ์ว่าเทสต์ไหนควรมีอยู่

- ✅ กฎที่ skill เขียนไว้เป็นร้อยแก้วอยู่แล้ว แต่ไม่มีอะไรบังคับ (เช่น §8 ห้าม `innerHTML`)
- ✅ บักที่เคยเกิดจริงแล้วไม่อยากให้กลับมา
- ❌ ไล่เขียนให้ครบทุกฟังก์ชันเพื่อเอา coverage — **ไม่มีเป้า coverage ตลอดกาล**

**เทสต์ที่ไม่เคยแดงคือเทสต์ที่ยังไม่ได้พิสูจน์ว่าใช้ได้** ทุกครั้งที่เขียนเทสต์ใหม่ ให้ทำสิ่งที่มัน
ควรจับพังโดยตั้งใจก่อน แล้วดูว่ามันแดงจริงไหม เคยเจอเคสที่เทสต์เทียบ `objectStoreNames`
กับ `APP_CONFIG.STORES` แล้วผ่านตลอด เพราะสองฝั่งหดตามกัน — ตรวจแล้วไม่ได้ตรวจอะไรเลย

→ รายละเอียดการเขียนเทสต์และ harness: `references/testing-single-html.md`

---

## § 25.3 · Definition of Done

งานถือว่าเสร็จเมื่อครบทุกข้อ ไม่ใช่แค่ "โค้ดรันได้":

```
[ ] npm run check เขียว (lint + secret + unit + e2e)
[ ] เทสต์ใหม่ที่เขียน ถูกพิสูจน์แล้วว่าแดงได้จริงเมื่อทำสิ่งที่มันคุมพัง
[ ] sa-code-reviewer ไม่เหลือ 🔴
[ ] Single HTML File: bump CACHE_NAME ใน sw.js (CI job cache-guard คุมให้อีกชั้น)
    · Multi-File: ข้าม — vite-plugin-pwa สร้าง service worker ให้เอง
[ ] เปิด preview URL บนมือถือจริงแล้ว ไม่ใช่แค่ DevTools
[ ] รู้คำสั่ง rollback ก่อนกด deploy
[ ] ถ้าแก้บัก — มีเทสต์ที่จะแดงถ้าบักนั้นกลับมา
[ ] ถ้าเปลี่ยน DB_VERSION — มีเทสต์ migration ที่พิสูจน์ว่าข้อมูลเดิมอยู่ครบ
```

---

## § 25.4 · Deploy safety

**Preview ก่อน production เสมอ** — ใช้ Cloudflare Workers version preview เป็น preview
environment ของ *ทุก* แอป รวมถึงแอปที่ production อยู่บน GitHub Pages (GH Pages ไม่มี PR
preview ในตัว และ deploy ลงโฟลเดอร์ `preview/` ใน repo production ทำให้ prod สกปรก)

ผลพลอยได้ที่สำคัญ: ข้อ "ทดสอบบนมือถือจริง" ใน §24.5 เกิดขึ้นได้ **ก่อน** ของขึ้น production
เป็นครั้งแรก — ซึ่งที่ผ่านมาทำไม่ได้เลยเพราะ push main = ขึ้น production ทันที

**Gate 2 ชั้นก่อน deploy (Single HTML File):** `check` (เทสต์ทั้งหมด) + `cache-guard` (แก้ index.html แล้ว
ต้อง bump CACHE_NAME) — job ที่สองยาว 5 บรรทัดแต่ปิดบักที่เอกสาร 3 skill บันทึกตรงกันว่าเกิดซ้ำ
· **Multi-File:** `starter-multifile/.github/workflows/ci.yml` มีแค่ job `check` → `deploy` — ไม่มี `cache-guard`
เพราะไม่มี `CACHE_NAME` ให้ลืม (vite-plugin-pwa จัดการให้)

→ YAML เต็มทั้ง 2 workflow: `references/ci-cd-templates.md`
→ ขั้นตอน rollback พร้อมคำสั่งจริง: `references/rollback-runbook.md`

---

## § 25.5 · Observability สำหรับแอปผู้ใช้หลักสิบคน

ทำ 4 อย่าง ฟรีทั้งหมด · เกินกว่านี้คือ over-engineering สำหรับ scale นี้

1. `observability.enabled: true` ใน `wrangler.jsonc` (ทั้ง 2 starter ตั้งตรงกันแล้ว — เดิมมี
   drift ที่ `cloudflare-workers-deploy` ตั้ง `false` ทั้งที่ `logs.enabled: true` ขัดกันเอง แก้แล้ว)
2. ปุ่ม "รายงานปัญหา" → เปิด GitHub issue ที่กรอกไว้ล่วงหน้า (มีใน starter แล้ว)
3. `window.onerror` + `unhandledrejection` → `DEBUG_MODULE` → toast (มีใน starter แล้ว
   ตอนนี้ ring buffer คงอยู่ข้าม reload ด้วย — persist ผ่าน `STORAGE_ENGINE` ที่มีอยู่แล้ว)
4. Uptime ด้วย GitHub Actions cron
5. **ดู log/trace จริงเวลาแอปพัง** — `wrangler tail <worker-name>` (streams log สดจาก
   terminal) หรือ Cloudflare dashboard → Workers & Pages → Worker นั้น → tab **Logs**
   (retention เช็คในหน้า dashboard เอง เปลี่ยนได้ตาม plan ไม่ตรึงตัวเลขไว้ที่นี่)

**Known Issues ย้ายไป GitHub Issues** — หัวข้อนั้นใน `CLAUDE.md` คือสำเนาที่การันตีว่าจะตกยุค

→ รายละเอียด + สิ่งที่จงใจไม่ทำและเหตุผล: `references/observability-and-issues.md`

---

## § 25.6 · สิ่งที่จงใจ "ไม่ทำ" (สำคัญพอๆ กับสิ่งที่ทำ)

มาตรฐานมืออาชีพสำหรับคนเดียว + AI ไม่เท่ากับมาตรฐานของทีม 20 คน อย่าลอกมาทั้งดุ้น

| ไม่ทำ | เหตุผล |
|---|---|
| Branch protection บังคับ PR review | รีวิว PR ตัวเองไม่ได้ — **gate ที่ deploy ไม่ใช่ gate ที่ push** โค้ดลง main ได้ แต่ CI กันไม่ให้ถึง production |
| Staging environment ถาวร | preview URL ชั่วคราวดีกว่าและไม่ต้องดูแล |
| เป้า coverage | เขียนเทสต์เฉพาะกฎที่มีอยู่แล้วและบักที่เคยเกิดจริง |
| Semver + CHANGELOG เขียนมือ | ไม่มีใครอ่านแล้วจะเน่า → git tag วันที่ + `gh release --generate-notes` |
| Sentry / error SDK | ต้องแก้ CSP + script บุคคลที่สาม + ข้อมูลโรงงานไป cloud คนอื่น · คุ้มเมื่อเกิน ~20 คน |
| Analytics ทุกชนิด | พี่ A รู้จักผู้ใช้ทุกคน เดินไปถามเร็วกว่า |
| Dependabot สำหรับ npm (เฉพาะ `claude-config` เอง) | devDeps ไม่กี่ตัว จะกลายเป็น noise · เปิดเฉพาะ `github-actions` (ยังจริงสำหรับ meta-repo นี้ — แต่เปิด npm แยกให้ `design-lab/starter-multifile/` แล้ว เพราะ dependency ที่นั่น ship เข้าแอปจริงที่คนอื่นใช้ ไม่ใช่ devDeps ของ repo นี้ → ดู §25.8) |
| Playwright ใน pre-commit hook | ช้าเกิน 5 วิเมื่อไหร่ คนจะเริ่มพิมพ์ `--no-verify` ซึ่งห้ามไว้ · ให้ CI รัน |
| เอา lint/test ไปใส่ hooks ใน `settings.json` | PowerShell เฉพาะเครื่อง ช้า และสู้กับ agent loop · npm script + git hook เดินทางไปกับ repo และใช้ใน CI ได้ด้วย |
| ย้ายไป Vite เพื่อให้ test ได้ | §25.2 แก้ปัญหานี้แล้ว · Decision Table ใน `vibe-coding-multifile` ยังใช้เกณฑ์เดิม |

---

## § 25.7 · TDD Checkpoint — Red ก่อน Green (บังคับที่ Step 5a ของ `vibe-coding-core` §1)

> มาจาก 7 SE Fundamentals for Vibe Coding (BoomtoDev) — False Success: AI บอกว่า "เสร็จแล้ว"
> ไม่ได้แปลว่าเสร็จจริง จนกว่าจะมีเทสต์ที่เคยแดงมาพิสูจน์

**ใช้ตอนไหน:** เริ่ม logic ใหม่ที่ยังไม่เคยมี บนแอปที่มีโมดูล/ฟังก์ชันให้ stub ได้ (9-Module
starter — Multi-File หรือ Single HTML File) — ไม่ใช่ตอนแก้บัก (นั่นคือกฎเดิมของ
`sa-code-reviewer` ข้อ 6: ต้องมีเทสต์ที่จะแดงถ้าบักกลับมา) และไม่ใช่ "เขียนเทสต์ใหม่แล้วลอง
ทำให้มันพัง" ของ §25.2 (นั่นใช้ตอนเทสต์ใหม่ ไม่ว่าโค้ดจะมีอยู่แล้วหรือไม่) รอบนี้ยังไม่ครอบคลุม
งานแก้บัก/iterate แอปเดิมของ `vibe-coding-workflow` — เฉพาะโปรเจกต์ใหม่ของ `vibe-coding-core`

### ทำยังไงให้ "แดง" มีความหมายจริง

ปัญหา: ถ้ายังไม่มี `index.html`/module เลย เทสต์จะแดงเพราะหาไฟล์ไม่เจอ ไม่ใช่เพราะ assert
พัง — พิสูจน์อะไรไม่ได้ ต้องมี "โครงที่เทสต์เรียกได้" ก่อนเขียน logic เสมอ:

| Stack | ก่อนเขียน logic | เทสต์เรียกอะไร |
|---|---|---|
| Single HTML File | copy `design-lab/starter/` แล้ว stub ฟังก์ชันในโมดูลที่เกี่ยวข้อง | `mod(win, "MODULE_NAME").fn(...)` ผ่าน harness (§25.2) |
| Multi-File | copy `design-lab/starter-multifile/`, สร้าง `src/modules/*.js` พร้อม `export` ฟังก์ชัน stub | `import` ตรงจาก module ใน Vitest (`vibe-coding-multifile` §21) |

### ขอบเขต — ไม่ใช่ทุกบรรทัดโค้ด
- เฉพาะ logic ที่ Test Plan ของ Blueprint ระบุไว้แล้ว — ไม่มีเป้า coverage เหมือนเดิม (§25.6)
- UI/markup ล้วนๆ ไม่ต้องมี failing test ก่อน — จับด้วย e2e ตามปกติ
- แอปสไตล์ DOM-driven เก่าที่ไม่มีโมดูลให้ stub — ข้าม checkpoint นี้ไปเลย (ดู `vibe-coding-core`
  §1 Step 5)

---

## § 25.8 · Dependency vulnerability scanning (app template)

**ปัญหา:** §25.6 ปิด Dependabot สำหรับ npm ไว้จงใจ — แต่เหตุผลนั้น ("devDeps ไม่กี่ตัว
จะกลายเป็น noise") พูดถึงแค่ devDependency ของ `claude-config` เอง (~6 ตัว ไม่มีอะไรถูก
ship ไปไหน) ไม่เคยครอบคลุมถึง `design-lab/starter-multifile/` ซึ่งเป็นเทมเพลตที่ทุกแอปจริง
ถูก copy ไปใช้ แล้วมี dependency มากกว่ามาก (Vite/Vitest/Firebase SDK/Chart.js ฯลฯ) ที่ถูก
deploy ให้คนอื่นใช้งานจริง — ช่องโหว่ที่นั่นกระทบผู้ใช้จริง ต่างเหตุผลกันจึงต่างการตัดสินใจกัน

**ทำ 2 อย่าง เฉพาะ `starter-multifile`:**
1. `.github/dependabot.yml` (npm ecosystem, group `minor-and-patch` รวมเป็น PR เดียว
   ต่อสัปดาห์กัน noise, major แยกให้เห็นทีละตัว) — advisory เท่านั้น ไม่ block อะไร
2. `npm run audit` (`npm audit --audit-level=high`) เป็น step แยกใน CI job `check` —
   นี่คือตัวที่ block จริงผ่าน `needs: check` ก่อนถึง `deploy` ตามหลัก "CI คือที่เดียวที่
   บังคับได้จริง" · แยกเป็น script ของตัวเอง ไม่ยัดเข้า `check`/`check:local` เพื่อไม่ให้
   วลี "lint + secret scan + unit + e2e" ที่ repo อื่นอ้างถึงคำต่อคำต้องเปลี่ยนตาม

→ รายละเอียด YAML เต็ม: `references/ci-cd-templates.md`

---

## Reference Library

| ไฟล์ | เนื้อหา | โหลดเมื่อ |
|---|---|---|
| `references/where-we-stand.md` | ตารางเทียบ workflow เรา vs หลัก SE 19 ข้อ (ก่อน/หลัง) + สิ่งที่จงใจข้าม | อยากรู้ว่าตอนนี้อยู่ตรงไหน หรือถูกถามว่ามาตรฐานพอหรือยัง |
| `references/testing-single-html.md` | harness ทำงานยังไง · เขียนเทสต์ใหม่ยังไง · กับดักที่เจอมาแล้ว | จะเขียน/แก้เทสต์ |
| `references/ci-cd-templates.md` | YAML เต็มของ ci.yml + preview.yml + uptime.yml | จะตั้ง CI ให้ repo ใหม่ |
| `references/rollback-runbook.md` | ขั้นตอนย้อนกลับพร้อมคำสั่งจริง ทั้ง Workers และ Pages | production พัง หรือจะซ้อม |
| `references/observability-and-issues.md` | error boundary · ปุ่มรายงานปัญหา · uptime · issue workflow | จะตั้ง observability |
