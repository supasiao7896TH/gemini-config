# Workflow ของ Supasit.A เทียบกับหลัก Software Engineering

> ส่วนหนึ่งของ `vibe-coding-quality` §25.0 · ประเมินเมื่อ 2026-09-02
> เกณฑ์: **solo developer + AI pair สำหรับ internal tool ผู้ใช้หลักสิบคน**
> ไม่ใช่ทีม 20 คนทำ SaaS — สิ่งที่ควรข้ามอยู่ท้ายไฟล์

## ตารางเทียบ

| # | ขั้นตอนมาตรฐาน SE | ของเรา | ก่อน 2026-09 | หลัง |
|---|---|---|---|---|
| 1 | Requirements / Discovery | core §1 Step 1 · workflow §23 STEP 2 CONFIRM | 🟢 | 🟢 |
| 2 | Design spec + sign-off gate | core §1 Step 3 Blueprint + คำว่า "อนุมัติ" | 🟢 | 🟢 + Test Plan/DoD |
| 3 | Design system review | `design-lab/preview-kit.html` ตัดสินจากหน้าจอจริง | 🟢 | 🟢 |
| 4 | Coding standard | core §2 · 9 IIFE modules · ฟังก์ชัน ≤30 บรรทัด | 🟡 มีกฎ ไม่มีเครื่องตรวจ | 🟡 (กฎที่ตรวจได้ ตรวจแล้ว) |
| 5 | **Automated test** | — | 🔴 stack หลักไม่มีเลย | 🟢 15 unit + 16 e2e |
| 6 | Code review | `sa-code-reviewer` | 🟡 มี agent ไม่มีใครเรียก | 🟢 อยู่ใน loop STEP 5 |
| 7 | **Static analysis** | — | 🔴 | 🟢 prettier + pre-commit |
| 8 | **Secret scanning** | ตาเปล่า | 🔴 | 🟢 secretlint 2 ชั้น |
| 9 | Version control discipline | Git Safety Protocol · conventional commits | 🟢 (ขาด test:/chore:) | 🟢 ครบ |
| 10 | **CI gate ก่อน deploy** | — | 🔴 | 🟢 check + cache-guard |
| 11 | **Preview ก่อนขึ้นจริง** | "ไม่มี staging แยก" | 🔴 | 🟢 preview URL ทุก PR |
| 12 | Release / deploy | core §17 · `/deploy` | 🟡 checklist ดี รันมือ | 🟢 gate + build stamp |
| 13 | **Rollback plan** | — | 🔴 ไม่มีสักบรรทัด | 🟢 มี runbook · **ซ้อมจริงแล้ว 1:31 นาที** |
| 14 | **Observability** | `DEBUG_MODULE` → IndexedDB | 🔴 อ่านจากระยะไกลไม่ได้ | 🟢 error boundary + ปุ่มรายงาน + uptime |
| 15 | **Issue tracking** | bullet ใน CLAUDE.md | 🔴 | 🟢 GitHub Issues + template |
| 16 | **Versioning** | — | 🔴 ไม่รู้ว่า production คือ commit ไหน | 🟢 build stamp + git tag |
| 17 | Handoff | `HANDOFF.md` · `sa-handoff` | 🟢 | 🟢 |
| 18 | Accessibility | ST-13 · WCAG AA · ≥44px | 🟡 "ตรวจด้วยเครื่องได้" แต่ไม่มีเครื่อง | 🟢 axe ทั้ง 2 ธีม |
| 19 | Security | core §8 CSP/SRI/AES-GCM | 🟡 กฎครบ ไม่มี scan | 🟢 เทสต์ XSS + secretlint |

**ก่อน: 6 🟢 · 6 🟡 · 7 🔴 → หลัง: 16 🟢 · 2 🟡 · 0 🔴**

🟡 ที่เหลืออยู่ 1 ข้อ:
- **ข้อ 4** — "ฟังก์ชัน ≤30 บรรทัด" กับ naming convention ยังไม่มีเครื่องตรวจ
  (ยังไม่ได้ตั้ง ESLint เพราะ Single HTML File ทำให้ config ยุ่งกว่าที่ควร — คุ้มค่าน้อยเทียบกับที่ทำไปแล้ว)
- **ข้อ 4** (ต่อ) — accessibility ระดับ `--surface`/`--bg`/contrast มีเครื่องตรวจแล้ว (ข้อ 18)
  แต่ code-style ยังไม่มี ถือเป็น 🟡 ที่ตั้งใจปล่อยไว้ ไม่ใช่ของที่ลืม

✅ **ปิดครบทั้ง 2 ข้อที่เคยค้าง (2026-09-02):**

- **harness ลองกับแอปจริงแล้ว** — สำรวจ ~10 แอป พบว่าไม่มีตัวไหนใช้
  `var MODULE = ...` แบบ starter ปัจจุบันเป๊ะๆ (แอปจริงถูกสร้างก่อนมาตรฐานรอบที่ 4)
  แต่พิสูจน์แล้วว่า jsdom ยังทดสอบแอปสไตล์เก่าได้เต็มรูปแบบด้วย "โหมด DOM-driven"
  (จำลองคลิกปุ่มจริง เช็คว่า DOM เปลี่ยนตามที่ควร) — ดู `testing-single-html.md`
  ผลพลอยได้: เจอว่าแอป Plant Log Analyzer ที่ย้ายไป Vite แล้วมี Vitest 146 เทสต์
  ผ่านครบอยู่แล้ว ยืนยันว่า multi-file stack เดิมก็ยังแข็งแรงดี

- **rollback ซ้อมจริงแล้วกับ `condo-rental-app`** — deploy ของผิดขึ้นจริง (เปลี่ยน `<title>`)
  แล้ว rollback กลับด้วยคำสั่งที่ยืนยันแล้วว่าใช้ได้จริง **รวมเวลา 1 นาที 31 วินาที**
  (เป้า < 5 นาที) และเจอบั๊กจริงในตัว runbook เอง (ลืมส่ง version-id เข้าคำสั่ง rollback) —
  ดู `rollback-runbook.md` § 7 สำหรับ timeline เต็ม

✅ **ปิดช่องว่างเพิ่ม 3 ข้อ (2026-09-10):** ไม่ใช่ข้อที่เคยเป็น 🔴 ในตารางหลัก (ทั้งหมดยัง 🟢
อยู่แล้ว) แต่เป็นช่องว่างที่เหตุผลเดิมไม่เคยครอบคลุมถึง — เจอตอนพี่ A ถามตรงๆ ว่าระบบ
"เพียบพร้อมตามหลัก SE" หรือยัง

- **Dependency scanning สำหรับ app template** — `design-lab/starter-multifile/` ไม่เคยมี
  Dependabot/`npm audit` เลย ทั้งที่มี dependency มากกว่า meta-repo มาก (เหตุผลเดิมที่ปิด
  Dependabot npm ไว้พูดถึงแค่ devDeps ของ `claude-config` เอง) → เปิดแยกให้แล้ว ดู
  `vibe-coding-quality` §25.8
- **Cloudflare observability drift** — `cloudflare-workers-deploy` skill ตั้ง
  `observability.enabled: false` ทั้งที่ `logs.enabled: true` ขัดกันเอง (เอกสารเองเคย
  flag ไว้ว่าเป็น known drift) → แก้ให้ตรงกับ `starter-multifile` แล้ว พร้อมเพิ่มวิธีดู
  log จริง (`wrangler tail` / dashboard Logs tab)
- **`DEBUG_MODULE` persist ข้าม reload** — เดิมเก็บ log ใน memory เท่านั้น หายทันทีที่
  reload ทั้งที่เอกสารเขียนไว้ผิดว่าเขียนลง IndexedDB อยู่แล้ว → ตอนนี้ persist จริงผ่าน
  `STORAGE_ENGINE` ที่มีอยู่แล้ว (ไม่กระทบการตัดสินใจเรื่อง Sentry — ยังไม่มี auto-upload)

## สิ่งที่จงใจข้าม และเหตุผล

| ข้าม | เหตุผล |
|---|---|
| Branch protection บังคับ PR review | รีวิว PR ตัวเองไม่ได้ — **gate ที่ deploy ไม่ใช่ gate ที่ push** |
| Staging environment ถาวร | preview URL ชั่วคราวดีกว่าและไม่ต้องดูแล |
| Sprint / story point / velocity | ทีมคนเดียว ไม่มีอะไรให้ประมาณเทียบ |
| เป้า coverage | เขียนเทสต์เฉพาะกฎที่มีอยู่แล้วและบักที่เคยเกิดจริง |
| Semver + CHANGELOG เขียนมือ | ไม่มีใครอ่านแล้วจะเน่า → git tag วันที่ + `--generate-notes` |
| TypeScript / Docker / k8s | เกินจำเป็นมหาศาลสำหรับ scale นี้ |
| ย้ายไป Vite เพื่อให้ test ได้ | §25.2 แก้ปัญหานี้แล้ว |

## ข้อสรุปที่อยากให้จำ

กระบวนการเดิม **ไม่ได้ขาดความรู้** — Blueprint gate, loop ที่จำกัดรอบ, QA checklist,
Git Safety Protocol ล้วนเป็น SE practice ของจริงที่หลายทีมยังไม่มี

สิ่งที่ขาดคือ **เครื่องบังคับ** · กฎที่ต้องพึ่งความจำ สุดท้ายจะกลายเป็นกฎที่ถูกลืม
และไม่มีใครรู้ว่าลืมไปแล้วด้วยซ้ำ — จนกระทั่งมีเครื่องมาตรวจ แล้วพบว่ามันไม่ตรงมา 2 design system แล้ว
