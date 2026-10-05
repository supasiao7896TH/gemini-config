---
name: vibe-coding-multifile
description: >
  Multi-File Stack Skill สำหรับ Vibe Coding ของ Supasit.A — **ค่าเริ่มต้นของทุก
  โปรเจกต์ใหม่ตั้งแต่ 2569-09-02** (Vite + ES Modules + Vitest + GitHub Actions
  CI/CD + deploy ขึ้น URL จริง) ใช้ skill นี้ทุกครั้งที่พี่ A ขอสร้างแอปใหม่ ย้าย
  โปรเจกต์เดิมจาก Single HTML File ไปหลายไฟล์ หรือพูดถึงคำว่า "แยกไฟล์",
  "แยกโค้ด", "Vite", "ES Modules", "npm run dev", "unit test"/"Vitest", "CI/CD"
  — ใช้ vibe-coding-core (Single HTML File) เฉพาะข้อยกเว้น: เครื่องมือเล็กมาก
  ใช้ครั้งเดียวทิ้ง ไม่ต้อง deploy (ดู Decision Table)
---

# Vibe Coding Multi-File — Supasit.A Skill

> **Scope:** Vite + ES Modules · Vitest · GitHub Actions CI/CD · **ค่าเริ่มต้นของแอปใหม่ทุกตัว**
> **ใช้เมื่อ:** เริ่มโปรเจกต์ใหม่ (ค่าเริ่มต้น) หรือย้ายโปรเจกต์เดิมออกจาก Single HTML File
> **ใช้ร่วมกับ:** vibe-coding-core (§2 module pattern ยังใช้ได้ แค่เปลี่ยน "1 IIFE" เป็น "1 ไฟล์" · ใช้เต็มรูปแบบเฉพาะข้อยกเว้น single-file) · vibe-coding-workflow (§18 session hygiene) · cloudflare-workers-deploy (deploy จริง)

| | |
|---|---|
| **Version** | 1.3 |
| **Updated** | 2026-09 |
| **Brand** | A-Class WebCraft · Code • Share • Inspire · by Supasit.A |
| **Sections in this file** | §21 |
| **Related skills** | `vibe-coding-core` (§1–17) · `vibe-coding-workflow` (§18–19, §23–24) · `cloudflare-workers-deploy` |
| **Derived from** | Migration จริงของโปรเจกต์ `Monitor-Quality-PTA` (2026-08-08) — ดู `README.md` "Session Log" ของโปรเจกต์นั้นสำหรับเคสอ้างอิงเต็ม |

---

## § 21 · Multi-File Stack (Vite + ES Modules) — **ค่าเริ่มต้นของทุกโปรเจกต์ใหม่**

> **อัปเดต 2569-09-02 — พลิกกลับจาก skill เสริมมาเป็นค่าเริ่มต้น:** มาตรฐานเดิมคือ Single HTML
> File เท่านั้น เหตุผลตอนนั้นคือกลัว build tools ทำ workflow 2 เครื่อง (บ้าน/ที่ทำงาน) พัง
> เหตุผลนั้นไม่จริงอีกต่อไป — Node/npm ลงได้ทั้ง 2 เครื่องแล้ว, deploy ทั้งหมดรันผ่าน GitHub
> Actions ไม่ต้องพึ่งเครื่อง local เลย, และมีแอปจริง 2 ตัว (Plant Log Analyzer, condo-rental-app)
> ใช้ stack นี้มาหลายสัปดาห์พร้อม Vitest ที่ผ่านครบ 146 เทสต์ Single HTML File
> (`vibe-coding-core` มาตรฐานเดิม) ยังใช้ได้อยู่ แต่เป็น**ข้อยกเว้น**สำหรับเครื่องมือเล็กมาก
> ที่ใช้ครั้งเดียวทิ้ง ไม่ใช่จุดเริ่มต้นของโปรเจกต์ทั่วไปอีกต่อไป

### Decision Table — เริ่มโปรเจกต์ใหม่ ใช้ Multi-File หรือ Single HTML File?

```
คำถาม                                              → Stack
─────────────────────────────────────────────────────────────────────
โปรเจกต์ทั่วไป จะใช้งานต่อเนื่อง / ให้คนอื่นใช้ด้วย   → Multi-File (ค่าเริ่มต้น — skill นี้)
อยากมี automated test คุ้มครอง business logic       → Multi-File + Vitest (skill นี้)
อยากมี CI ตรวจ build/test อัตโนมัติก่อน deploy       → Multi-File + GitHub Actions (skill นี้)
เครื่องมือเล็กมาก ใช้ครั้งเดียวแล้วทิ้ง ไม่ต้อง deploy → Single HTML File (ข้อยกเว้น — vibe-coding-core)
ทดลองไอเดียเร็วๆ ยังไม่แน่ใจว่าจะใช้จริงไหม           → Single HTML File (ข้อยกเว้น — vibe-coding-core)
```

> **ข้อควรรู้:** multi-file มีต้นทุนเริ่มต้นที่ single-file ไม่มี — ต้องมี repo, ตั้ง
> `CLOUDFLARE_API_TOKEN` secret เอง (Claude ทำให้ไม่ได้), เขียน `wrangler.jsonc`, `npm install`
> ก่อนรันครั้งแรก ถ้าเป็นเครื่องมือใช้ครั้งเดียวทิ้งจริงๆ ต้นทุนนี้ไม่คุ้ม — นั่นคือเหตุผลที่
> single-file ยังไม่ถูกตัดทิ้ง ไม่ใช่เพราะเป็นค่าเริ่มต้นที่แข่งกันอยู่

### ทำไม stack นี้ใช้ได้ทั้งบ้านและ Office (อัปเดต 2569-09-02)

```
เดิม: เครื่อง Office ไม่มีสิทธิ์ admin → กลัวติดตั้ง Node.js/npm ไม่ได้ (เจอ UAC popup)
      → เลยล็อกไว้ที่ Single HTML File เพื่อกัน build tools พัง workflow 2 เครื่อง

ยืนยันแล้ว 2569-09-02: Node/npm ลงได้จริงทั้ง 2 เครื่อง (ไม่ต้อง admin) — ข้อกังวลเดิมไม่จริงแล้ว

แต่ที่สำคัญกว่านั้น: ต่อให้เครื่องไหนไม่มี Node.js ก็ยังใช้ stack นี้ได้ปกติ เพราะ
build/test/deploy ทั้งหมดรันผ่าน GitHub Actions ไม่ใช่เครื่อง local:
  - npm ci, npm run build, npm test, wrangler deploy → รันบน cloud runner ทั้งหมด
  - เครื่องที่ไม่มี Node.js: แก้โค้ดผ่าน Claude Code ตรงๆ, push ขึ้น GitHub,
    ดูผล build/test/deploy จากแท็บ "Actions" แทนการรันเองในเครื่อง
  - เครื่องที่มี Node.js (ทั้ง 2 เครื่องตอนนี้): ใช้ npm run dev ทดสอบ local เพิ่มได้ตามสะดวก
    แต่ไม่ใช่ข้อบังคับ — CI คือ source of truth เสมอ

GitHub คือสะพานซิงค์เหมือนเดิม (ตาม USER.md) — สลับเครื่องแล้วไม่มีอะไรพัง
```

### Tech Stack มาตรฐาน

| หมวด | เทคโนโลยี | หมายเหตุ |
|---|---|---|
| Build tool | **Vite** | dev server + hot reload + production build |
| Module system | **ES Modules** (`import`/`export`) | ไม่ใช้ TypeScript — ใช้ JSDoc comment แทนถ้าต้องการ type hint |
| Unit test | **Vitest** | เขียนเทสต์เฉพาะ business logic ที่เคยมี bug จริง หรือมี logic ซับซ้อนพอจะพังเงียบๆ ได้ — ไม่ต้อง 100% coverage |
| CI | **GitHub Actions** (`check` job) | รันทุก push/PR: `npm ci` → `npm run check` (lint + secrets + unit + e2e) |
| CD | **GitHub Actions** (`deploy` job) | รันเฉพาะ push เข้า `main` **และ** ต่อเมื่อ `check` ผ่านเท่านั้น |
| Deploy target | Cloudflare Workers *หรือ* GitHub Pages | ดู `cloudflare-workers-deploy` skill สำหรับ setup เต็ม |
| Third-party libs | ยังโหลดผ่าน CDN `<script>` ใน `index.html` เหมือนเดิมได้ | ไม่บังคับย้ายเป็น npm import — ดู "สิ่งที่ไม่ต้องแตะ" ด้านล่าง |

### เริ่มโปรเจกต์ใหม่ — copy จาก starter ตรงๆ ไม่ต้องสร้างเอง

> `cp -r design-lab/starter-multifile <ชื่อโปรเจกต์ใหม่>` แล้ว `npm ci && npm test` ให้เขียว
> ก่อนเริ่มฟีเจอร์แรก — มีครบ: 8 โมดูล ES ใน `src/modules/` (app-config · app-core · chart-theme ·
> cloud-sync-manager · debug-module · state-store · storage-engine · ui-renderer) · Vitest+Playwright 2 ชั้น (เทียบเท่า
> `design-lab/starter` ฝั่ง single-file) · `vite-plugin-pwa` (service worker generate อัตโนมัติ
> ไม่ต้อง bump CACHE_NAME มือ) · CI/preview/uptime workflow ครบ ดูรายละเอียดที่
> `design-lab/starter-multifile/README.md`

### โครงสร้างไฟล์มาตรฐาน

```
project/
├── index.html              # markup/modal ทั้งหมด — CDN <script> tags อยู่ตรงนี้
├── src/
│   ├── main.js              # entry point — เดิมคือ APP_CORE ใน Single HTML File
│   └── modules/
│       ├── app-config.js    # 1 module = 1 ไฟล์ = 1 exported const-object namespace
│       ├── storage-engine.js
│       ├── ui-renderer.js
│       └── ...               # เลือกเท่าที่ใช้ ไม่บังคับครบ 9 (เหมือน vibe-coding-core §2)
├── tests/
│   └── *.test.js            # Vitest — เฉพาะ business logic ที่เคยพัง/ซับซ้อน
├── package.json
├── vite.config.js           # ถ้าต้องปรับ default (ส่วนใหญ่ไม่ต้องมีไฟล์นี้เลยก็ได้)
├── wrangler.jsonc.example   # copy เป็น wrangler.jsonc เอง ถ้า deploy ขึ้น Cloudflare Workers
└── .github/workflows/ci.yml
```

### IIFE Module → ES Module — วิธีแปลง

> หลักการ 1 module = 1 namespace ยังเหมือน `vibe-coding-core` §2 ทุกอย่าง เปลี่ยนแค่ "1 IIFE ในไฟล์เดียว" เป็น "1 `export const` ในไฟล์ของตัวเอง" — ไม่ต้องคิด pattern ใหม่

```javascript
// ❌ เดิม (Single HTML File, รวมกันใน app.js)
const STORAGE_ENGINE = (() => {
  'use strict';
  async function _open() { /* ... */ }
  return {
    async get(key) { return _open().then(db => db.get(key)); }
  };
})();

// ✅ ใหม่ (src/modules/storage-engine.js — แยกไฟล์)
async function _open() { /* ... */ }

export const StorageEngine = {
  async get(key) {
    const db = await _open();
    return db.get(key);
  }
};
```

```javascript
// src/main.js — import โมดูลที่ต้องใช้ตรงๆ (ไม่มี DI container/build-time magic)
import { StorageEngine } from './modules/storage-engine.js';
import { UIRenderer } from './modules/ui-renderer.js';

// index.html ยังใช้ inline onclick="..." แบบเดิมได้ — ES module ไม่ auto-global
// ต้อง attach function ที่ HTML เรียกใช้ลง window เอง ท้าย main.js:
window.saveAction = ActionLogUI.save;
```

> **จุดที่ต้องระวังเสมอ:** ES module ไม่ expose ตัวแปรออกไป global scope โดยอัตโนมัติเหมือน `<script>` ธรรมดา ถ้า `index.html` ยังมี `onclick`/`onchange` inline attribute อ้างชื่อฟังก์ชัน ต้องแนบ `window.foo = ...` ท้าย `main.js` ให้ครบ ไม่งั้นปุ่มจะกดไม่ทำงานเงียบๆ

### สิ่งที่ไม่ต้องแตะตอนย้าย (ลดความเสี่ยง)

```
✅ CDN libraries เดิม (Tailwind, SheetJS/XLSX, Chart.js, Lucide, html2pdf.js ฯลฯ)
   ยังโหลดผ่าน <script> ใน index.html เหมือนเดิมได้ — module ที่ใช้ต้องประกาศ
   /* global XLSX, lucide */ แทนการ import จาก npm
   WHY: ย้าย CDN libs เป็น npm import พร้อมกับแยกไฟล์ = เปลี่ยน 2 อย่างพร้อมกัน
        ถ้าพัง จะแยกไม่ออกว่าพังเพราะแยกไฟล์หรือเพราะเปลี่ยน import — ทำทีละอย่าง

✅ IndexedDB schema / DB_VERSION เดิม — ไม่ต้อง migrate ข้อมูลผู้ใช้เดิม
   การแยกไฟล์เป็นเรื่อง "โค้ดจัดยังไง" ไม่ใช่เรื่อง "ข้อมูลเก็บยังไง"
```

### Migration Playbook — ย้ายจาก Single HTML File มา Multi-File

```
1. READ ก่อนแตะโค้ด
   - อ่านไฟล์ app.js/index.html เดิมทั้งหมด ระบุ IIFE module ที่มีอยู่กี่ตัว
   - list business logic ที่เคยมี bug จริงมาก่อน (จาก PROGRESS.md/HANDOFF.md ถ้ามี)
     → นี่คือ candidate อันดับแรกสำหรับเขียน Vitest

2. ตั้ง tooling ก่อนแยกไฟล์
   - npm init, ติดตั้ง vite + vitest (devDependencies)
   - เพิ่ม scripts ใน package.json: dev / build / preview / test / test:watch
   - ยืนยัน `npm run dev` เปิดแอปเดิมได้ปกติ ก่อนเริ่มแยกไฟล์จริง

3. แยกทีละ module ไม่ใช่ทีเดียวหมด
   - เริ่มจาก module ที่ dependency น้อยสุด (เช่น APP_CONFIG) ไล่ไปจนถึง APP_CORE
   - แยกเสร็จแต่ละไฟล์ → npm run dev เช็คว่ายังพังไหมทันที อย่ารอแยกครบก่อนเทส

4. เขียน Vitest เฉพาะจุดเสี่ยง (ไม่ต้อง 100% coverage)
   - เจาะจง business logic ที่ "เคยพังจริง" หรือ "logic ซับซ้อนจนพังเงียบๆ ได้"
   - ตัวอย่างจริงจาก Monitor-Quality-PTA: baseline drift calculation (self-referential
     bug), spec/warning band parsing (หลาย format ไม่สม่ำเสมอ), success/fail
     determination ของ action log

5. ตั้ง GitHub Actions CI ก่อน deploy
   - job check รันทุก push/PR (ดู ci.yml ตัวอย่างด้านล่าง)
   - job deploy รันเฉพาะ push เข้า main และต้องรอ check ผ่านก่อน (needs:)

6. Manual verify ผ่าน browser จริงก่อนลบไฟล์เดิม
   - ทดสอบทุก flow หลักที่แอปมี (ไม่ใช่แค่ที่มี Vitest คุ้มครอง)
   - เปิด Console เช็คไม่มี error สีแดง
   - ต่อเมื่อผ่านครบ ค่อยลบ app.js เดิมทิ้ง — ห้ามลบก่อนยืนยัน

7. อัปเดต CLAUDE.md ของโปรเจกต์ให้ตรงความจริงใหม่
   - commands (npm run dev/test/build แทนการเปิด index.html ตรงๆ)
   - architecture section อธิบายว่าไฟล์ไหนอยู่ตรงไหน ทำหน้าที่อะไร
   - เพิ่ม "History note" อธิบายว่าทำไมย้าย (เช่นเดียวกับที่ทำใน Monitor-Quality-PTA)
```

### GitHub Actions CI/CD — ไฟล์จริงคือ source of truth

> `design-lab/starter-multifile/.github/workflows/ci.yml` คือไฟล์จริงที่ copy ไปใช้ตรงๆ
> ตัวอย่างย่อด้านล่างนี้แสดงแค่โครง flow — ไฟล์จริงมีรายละเอียดเพิ่มที่ตัวอย่างนี้ไม่ได้ใส่:
> ขั้น `npm run audit` (dependency scan, ดู `vibe-coding-quality` §25.8) ก่อนติดตั้ง Chromium,
> `playwright install --with-deps chromium` ก่อนรัน `npm run check`, ฝัง build stamp
> ลง `index.html` ก่อน build เพื่อตรวจว่า deploy จริงหรือยัง, deploy แบบ 2-step ของ
> `wrangler-action` (`versions upload` → `versions deploy -y`) และขั้น verify URL จริงหลัง
> deploy เทียบ commit hash — **ห้ามพิมพ์ ci.yml ใหม่ตามตัวอย่างนี้ ให้ใช้ไฟล์จริงจาก starter**

```yaml
# .github/workflows/ci.yml — โครงคร่าวๆ (ดูไฟล์จริงสำหรับรายละเอียดเต็ม)
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: actions/setup-node@v7
        with:
          node-version: 22
          cache: npm
      - run: npm ci
      - run: npx playwright install --with-deps chromium
      - run: npm run check   # lint + secrets + unit + e2e

  deploy:
    needs: check
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: actions/setup-node@v7
        with:
          node-version: 22
          cache: npm
      - run: npm ci
      - run: npm run build
      # deploy จริงเป็น 2-step wrangler-action + verify URL — ดูไฟล์จริงสำหรับ syntax เต็ม
```

> **WHY `needs: check`:** กัน deploy โค้ดที่ test ไม่ผ่านขึ้น production โดยไม่ตั้งใจ — เป็นจุดที่ Single HTML File เดิมไม่มีทางทำได้เลยเพราะไม่มี test ให้รอผ่าน

### package.json — ไฟล์จริงคือ source of truth

> `design-lab/starter-multifile/package.json` มี scripts และ devDependencies ครบกว่านี้มาก
> (ผูกกับ quality gate ของ `vibe-coding-quality` skill) และ dependency versions ขยับตามเวลา
> **ห้ามพิมพ์ตามตัวอย่างย่อด้านล่าง — ให้ `cp -r` จาก starter-multifile ตรงๆ ตามหัวข้อด้านบน**
> ตารางนี้บอกแค่ชื่อ script ที่ต้องมีเสมอ (ชื่อคงที่ แม้ implementation ข้างในจะเปลี่ยน):

| Script | หน้าที่ |
|---|---|
| `dev` / `build` / `preview` | Vite ปกติ |
| `test` / `test:watch` | Vitest |
| `e2e` | Playwright |
| `lint` / `fix` | Prettier check / write |
| `secrets` | secretlint |
| `check` | lint + secrets + test + e2e — gate เต็มก่อน deploy |
| `check:local` | ชุดเดียวกันแต่ไม่รวม e2e (เครื่องที่ลง Chromium ไม่ได้) |

### CLAUDE.md — ส่วนที่ต่างจาก Single HTML File (§18.2 ของ vibe-coding-workflow)

```markdown
## Commands
npm install
npm run dev          # Vite dev server with hot reload
npm test             # run all Vitest tests once
npm run build         # production build -> dist/

## Architecture
- src/main.js = entry point (เดิมคือ APP_CORE)
- src/modules/*.js = 1 module ต่อ 1 ไฟล์ (namespace pattern เดิมจาก vibe-coding-core §2)
- CDN libs (Tailwind/XLSX/ฯลฯ) ยังโหลดใน index.html — module ที่ใช้ประกาศ /* global X */

## CI/CD
- check รันทุก push/PR
- deploy รันเฉพาะ push → main และต้องรอ test ผ่านก่อน (ดู .github/workflows/ci.yml)
- งานที่ push ตรงเข้า main = ขึ้น production อัตโนมัติเมื่อ test ผ่าน ไม่มี staging แยก
```

### Decision Table — Deploy ไปที่ไหน?

```
คำถาม                                    → ทางเลือก
──────────────────────────────────────────────────────
อยากได้ URL แชร์ให้ทีมใช้ง่ายๆ ไม่ผูก repo → Cloudflare Workers (ดู cloudflare-workers-deploy)
Static site ล้วน ไม่มี server-side logic  → Cloudflare Workers หรือ GitHub Pages ก็ได้
มี Firebase Functions ร่วมด้วย             → ดู vibe-coding-firebase §20 GitHub Actions flow แทน
```

---

*SKILL: vibe-coding-multifile v1.3 | Section: §21*
*Supasit.A × A-Class WebCraft | Code • Share • Inspire*
*Related: vibe-coding-core · vibe-coding-workflow · cloudflare-workers-deploy*
*Derived from: Monitor-Quality-PTA migration (August 2026 / พ.ศ. 2569)*
*Updated: September 2026 (พ.ศ. 2569)*
