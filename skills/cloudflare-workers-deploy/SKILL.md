---
name: cloudflare-workers-deploy
description: >
  Cloudflare Workers Static-Assets Deploy Skill — ใช้เมื่อพี่ A ต้อง deploy เว็บแอป
  (Single HTML/CSS/JS หรือ static site ใดก็ได้ ไม่จำกัดว่าต้องมี Firebase/real-time)
  ขึ้น Cloudflare Workers แล้วเอา URL ไปแชร์ให้คนอื่นใช้งาน (เช่น แปะในหน้า Excel,
  ส่งลิงก์ให้ทีม) หรือพูดถึงคำว่า Cloudflare Workers, wrangler, workers.dev,
  .assetsignore, "deploy อัตโนมัติ", GitHub Actions deploy ตรงๆ ใช้ได้ทั้งตอนตั้ง
  โปรเจกต์ใหม่และตอนแก้ปัญหา deploy ของโปรเจกต์เดิมที่มีอยู่แล้ว
---

# Cloudflare Workers Deploy — Supasit.A Skill

> **Scope:** Deploy static-asset web app (ไม่จำกัด stack) ขึ้น Cloudflare Workers
> พร้อม auto-deploy ผ่าน GitHub Actions
> **ใช้เมื่อ:** ต้องการ URL สาธารณะให้คนอื่นเข้าใช้งานเว็บแอป โดยไม่ต้องมี realtime/Firebase
> **ใช้ร่วมกับ:** `vibe-coding-core` เมื่อเป็นโปรเจกต์ใหม่ (ไม่บังคับถ้าโปรเจกต์เดิมมีอยู่แล้ว)

| | |
|---|---|
| **Version** | 1.2 |
| **Updated** | 2026-09 |
| **Brand** | A-Class WebCraft · Code • Share • Inspire · by Supasit.A |
| **แยกออกมาจาก** | `vibe-coding-firebase` §20 (เดิมฝังอยู่ผิดที่ใต้ skill ชื่อ Firebase ทั้งที่ไม่เกี่ยว Firebase) |

---

## ตัวอย่างประโยคสั่งงาน (copy ไปใช้ได้เลย)

> เก็บไว้กันลืม — พี่ A พิมพ์ประมาณนี้ตอนเริ่มโปรเจกต์ใหม่ได้เลย ไม่ต้องจำ syntax หรือชื่อ skill

**กรณี Local-First ธรรมดา ไม่มี real-time (เหมือน PM-500 Runtime Tracker):**
```
ช่วยสร้างเว็บแอปใหม่ให้หน่อยครับ เป็น Local-First (ไม่ต้อง real-time/หลาย user)
แต่ต้องการ deploy ขึ้น Cloudflare Workers ให้ได้ URL เดียวไปแปะในหน้า Excel
ให้คนอื่นเปิดใช้งานได้ ตั้ง auto-deploy ผ่าน GitHub Actions + wrangler ด้วย
```

**กรณีต้องการ real-time หลาย user sync ข้อมูลกันสด (ผสาน `vibe-coding-firebase`):**
```
ช่วยสร้างเว็บแอปใหม่ให้หน่อยครับ ต้องการให้หลาย user เปิดพร้อมกันแล้วเห็นข้อมูล
sync กันแบบ real-time (ใช้ Firebase Firestore) และ deploy frontend ขึ้น
Cloudflare Workers ให้ได้ URL ไปแชร์ทีมได้เลย
```

**กรณีโปรเจกต์เดิมมีอยู่แล้ว แค่ยังไม่มี auto-deploy (แก้ปัญหาแบบ PM-500 เจอ):**
```
ช่วยตั้ง auto-deploy ให้โปรเจกต์นี้หน่อยครับ ตอนนี้ deploy Cloudflare Workers
แบบ manual upload อยู่ อยากให้ push ขึ้น GitHub แล้ว deploy เองอัตโนมัติ
```

---

## ทำไม Cloudflare Workers ถึงเป็นตัวเลือกที่ดี

- ไม่ต้องมี server ของตัวเอง, ไม่มีค่าใช้จ่ายสำหรับ static site ทั่วไป (free tier)
- ได้ URL แบบ `ชื่อ-worker.บัญชี.workers.dev` ทันที เอาไปแปะที่ไหนก็ได้ (Excel, LINE, Intranet)
- รองรับทั้ง Single HTML File แบบ Local-First และแอปที่มี Firebase/real-time อยู่ข้างในด้วย — ตัว skill นี้ดูแลแค่ "เอาไฟล์ขึ้น production" ไม่เกี่ยวกับว่าข้างในแอปใช้ stack อะไร

## ⚠️ กับดักที่เจอจริง: "เชื่อม GitHub ไว้แล้ว" ≠ "Auto-deploy"

เจอเคสจริงกับโปรเจกต์ PM-500 Runtime Tracker เมื่อ 2569-08-06: Cloudflare dashboard
โชว์ว่า Worker ผูกกับ GitHub repo ไว้แล้ว แต่ deploy ทุกครั้งเป็นแบบ
**"Manually deployed"** เท่านั้น (ต้องกด "New deployment" → อัปโหลดไฟล์เอง) — push
โค้ด fix ขึ้น `main` แล้ว **ไม่ทำให้ production อัปเดตจริง** ทำให้บั๊กที่แก้ในโค้ดแล้ว
ดูเหมือนยัง "ไม่หาย" เพราะปัญหาจริงคือ deploy ไม่ใช่โค้ด

**วิธีเช็คว่าโปรเจกต์ไหนกำลังเจอกับดักนี้อยู่:** เข้า Cloudflare dashboard → Workers
& Pages → เลือก Worker → ดูที่ Versions ล่าสุด ถ้าคอลัมน์ source เขียนว่า
**"Dashboard"** (ไม่ใช่ "Wrangler") แปลว่า deploy ล่าสุดเป็น manual upload ไม่ใช่ CI

ทางแก้ถาวรคือตั้ง GitHub Actions ให้รัน `wrangler deploy` เองตามด้านล่างนี้ — เพราะ
`wrangler deploy` และ Node.js รันบน **GitHub-hosted runner (cloud) ทั้งหมด**
เครื่อง PC ของผู้ใช้ (บ้าน/ที่ทำงาน) **ไม่ต้องติดตั้ง Node.js เลย** เหมาะกับเครื่องที่
ฝ่าย IT บล็อกการติดตั้งซอฟต์แวร์เพิ่มด้วย

## Setup

### 1. `wrangler.jsonc` (วางที่ root repo, commit เข้า git ปกติ — ไม่ใช่ความลับ)

```jsonc
{
  "name": "ชื่อ-worker-ตรงกับใน-cloudflare-dashboard",
  "account_id": "account-id-จาก-cloudflare-dashboard",  // ไม่ใช่ความลับ เห็นได้ใน URL ของ dashboard
  "compatibility_date": "2026-08-06",                    // ใส่วันที่ปัจจุบันตอน setup
  "assets": {
    "directory": "./"          // path ไปยังโฟลเดอร์ที่มี index.html — ปกติคือ root
  },
  "observability": {
    "enabled": true,            // เปิด Workers Logs/Traces ให้ค่านี้ "เป็นโค้ด" จะได้ไม่หายตอน deploy รอบหน้า
    "head_sampling_rate": 1,
    "logs": {
      "enabled": true,
      "head_sampling_rate": 1,
      "persist": true,
      "invocation_logs": true
    },
    "traces": { "enabled": false, "persist": true, "head_sampling_rate": 1 }
  }
}
```

### 2. `.assetsignore` (วางที่ root repo เดียวกัน — **บังคับ ห้ามข้าม**)

> **WHY:** ตอน GitHub Actions รัน `wrangler deploy` มันจะติดตั้ง `node_modules/`
> (รวมไฟล์ `workerd` binary ~122 MiB) ไว้ที่ root repo ชั่วคราว ถ้า `assets.directory`
> ชี้ที่ root (`"./"`) wrangler จะเข้าใจผิดว่า `node_modules` เป็น asset ที่ต้องอัปโหลด
> ด้วย แล้ว fail ทันทีด้วย error **"Asset too large"** (Cloudflare limit 25 MiB/ไฟล์)
> เจอเคสนี้จริงกับ PM-500 Runtime Tracker — ใส่ `.assetsignore` (syntax แบบ
> `.gitignore`) ตั้งแต่ต้นจะไม่มีวันเจอปัญหานี้เลย

```
node_modules
.git
.github
.wrangler
wrangler.jsonc
CLAUDE.md
agents.md
context.md
README.md
```

### 3. `.github/workflows/deploy.yml`

```yaml
name: Deploy
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - name: Deploy to Cloudflare Workers
        uses: cloudflare/wrangler-action@v4
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
```

### 4. Setup ครั้งเดียวต่อโปรเจกต์ (นอก CI, ต้องทำเองเสมอ — ห้าม AI แตะ credential)

```
1. สร้าง Cloudflare API Token ที่ https://dash.cloudflare.com/profile/api-tokens
   → "Create Token" → เลือก permission "Edit Cloudflare Workers" เท่านั้น
   (scope แคบสุด ไม่ใช้ Global API Key) → จำกัดให้เหลือแค่ account ที่ต้องการ
   ⚠️ อย่าใช้ token เก่าที่ Cloudflare สร้างอัตโนมัติตอนเชื่อม "Workers Builds"
   (มักตั้งชื่อว่า "xxx build token") — token พวกนั้น permission กว้างเกินความจำเป็นมาก

2. เอา token ไปตั้งเป็น GitHub Secret ของ repo นี้:
   Settings → Secrets and variables → Actions → New repository secret
   → ชื่อ CLOUDFLARE_API_TOKEN

3. ยืนยันค่าใน wrangler.jsonc (name, account_id, compatibility_date) ให้ตรงกับที่
   เห็นจริงในหน้า Cloudflare dashboard ของ Worker นั้นก่อน push ครั้งแรก
```

> **⚠️ ถ้า Worker เดิมเคย deploy แบบ manual upload มาก่อน** (ผ่านปุ่ม
> "New deployment" → "file") ให้เช็ค observability settings (Workers Logs/Traces)
> ในหน้า dashboard เทียบกับ `wrangler.jsonc` ก่อน push ครั้งแรกด้วย — ค่าที่เคยตั้งไว้
> ผ่าน dashboard อย่างเดียว (ไม่ได้เขียนลง `wrangler.jsonc`) มีโอกาสถูก deploy ผ่าน
> CI ทับ/รีเซ็ตกลับเป็นค่า default ได้ (เจอจริงกับ Workers Logs ของ PM-500)

## Verify หลัง push ครั้งแรก

```
1. เข้า GitHub repo → tab "Actions" → เช็คว่า workflow "Deploy" ขึ้นเครื่องหมาย
   ✅ (ไม่ใช่ ❌) — ถ้า fail ให้กดเข้าไปดู log ตรง step "Deploy to Cloudflare Workers"
2. เข้า Cloudflare dashboard → Worker นั้น → Overview → ดู "Versions" ล่าสุด
   ต้องเห็น source เป็น "Wrangler" (ไม่ใช่ "Dashboard") ถึงจะแปลว่า auto-deploy ทำงานจริง
3. เปิด URL จริงเช็คว่าแอปโหลดได้ปกติ
```

## ดู log จริงเวลาแอปพัง

`observability.enabled: true` เปิดไว้แล้วข้างบน (ฟรี, native Cloudflare — ไม่มีอะไรออกไป
นอกโครงสร้างที่แอป deploy อยู่แล้ว) แต่การเปิดไว้เฉยๆ ไม่มีประโยชน์ถ้าไม่รู้ว่าไปดูที่ไหน:

1. **`wrangler tail <worker-name>`** — stream log สดจาก terminal (ต้อง `wrangler login`
   ครั้งเดียวก่อน) เหมาะตอนกำลัง reproduce ปัญหาสดๆ
2. **Cloudflare dashboard → Workers & Pages → Worker นั้น → tab Logs** — ดูย้อนหลังได้
   โดยไม่ต้องเปิด terminal ไว้ตลอด (retention เท่าไหร่เช็คในหน้านั้นเอง เปลี่ยนได้ตาม plan
   ไม่ตรึงตัวเลขไว้ในเอกสารนี้)

→ รายละเอียดเพิ่มเติม + สิ่งที่จงใจไม่ทำ (Sentry ฯลฯ): `vibe-coding-quality` §25.5

## Error ที่เจอบ่อย + วิธีแก้

| Error message | สาเหตุ | วิธีแก้ |
|---|---|---|
| `it's necessary to set a CLOUDFLARE_API_TOKEN environment variable` | ยังไม่ได้ตั้ง GitHub Secret หรือชื่อ secret สะกดผิด | เช็คชื่อ secret ต้องเป็น `CLOUDFLARE_API_TOKEN` เป๊ะๆ |
| `Asset too large` (พบไฟล์ใน `node_modules`) | ไม่มี `.assetsignore` หรือไม่ครอบคลุม `node_modules` | เพิ่ม `.assetsignore` ตามข้อ 2 ด้านบน |
| Deploy สำเร็จแต่หน้าเว็บยังเป็นโค้ดเก่า | **Single HTML File:** ลืม bump `CACHE_NAME` ใน service worker (`sw.js`) · **Multi-File:** ไม่ใช่สาเหตุนี้ (`vite-plugin-pwa` สร้าง SW ให้เอง ไม่มี `CACHE_NAME`) — ให้สงสัยว่า deploy ยังไม่ขึ้นจริงก่อน | **Single HTML File:** bump `CACHE_NAME` ทุกครั้งที่แก้ `app.js`/`index.html` · **Multi-File:** เทียบ build stamp บน URL จริงกับ commit ล่าสุด ถ้าตรงแล้วยังเห็นของเก่า ให้ดูข้อ 3.2 ของ `rollback-runbook.md` |

---

*SKILL: cloudflare-workers-deploy v1.1*
*Supasit.A × A-Class WebCraft | Code • Share • Inspire*
*Updated: August 2026 (พ.ศ. 2569)*
