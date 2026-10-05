# Antigravity CLI (`agy`) Cheatsheet — คู่มือฉบับพกพาสำหรับพี่ A

> รวมคำสั่งลัด, Slash Commands, และคลัง Custom Skills สำหรับใช้งาน **Antigravity CLI (`agy`)** ควบคู่กับ VS Code สไตล์ Vibe Coding ของ Supasit.A

---

## ⚡ 1. คำสั่งพื้นฐานใน Terminal (CLI Commands)

| คำสั่ง | ประโยชน์ / การใช้งาน |
|---|---|
| `agy` | เริ่มรัน Antigravity CLI ในโฟลเดอร์ปัจจุบัน (รันใน VS Code Terminal) |
| `agy --version` | ตรวจสอบเวอร์ชันของ Antigravity CLI |
| `agy update` | อัปเดต Antigravity CLI เป็นเวอร์ชันล่าสุด |
| `agy --help` | แสดงคำสั่งและ flag ทั้งหมดที่รองรับ |
| `Ctrl + C` | ยกเลิกคำสั่งที่กำลังทำงาน |
| `Ctrl + D Ctrl + D` หรือ `/exit` | ออกจาก Antigravity CLI กลับสู่ PowerShell ปกติ |

---

## 🚀 2. Built-in Slash Commands (คำสั่งพิเศษใน TUI)

พิมพ์ `/` ในช่องรับคำสั่งของ `agy` เพื่อเรียกใช้งาน:

| คำสั่ง | ความสามารถ | สไตล์ Vibe Coding ของพี่ A |
|---|---|---|
| `/plan` | บังคับให้ AI วางแผนสถาปัตยกรรม (Blueprint) อย่างละเอียดก่อนลงมือเขียนโค้ด | 🌟 **ตรงกับกฎเหล็ก:** ใช้ทุกครั้งก่อนเริ่มสร้างฟีเจอร์ใหม่ |
| `/boost` | เปิดโหมด Deep Reasoning ใช้สมองวิเคราะห์เชิงลึก | เหมาะกับงานคำนวณเคมี PTA, Logic ที่ซับซ้อน หรือไล่บั๊กที่หาสาเหตุไม่เจอ |
| `/learn` | บันทึก Pattern สไตล์โค้ดหรือการตัดสินใจในรอบนี้ไว้ถาวร | ช่วยสอนให้ AI จดจำแนวทางเฉพาะของพี่ A เพื่อใช้ในครั้งต่อไป |
| `/goal` | Autonomous Run — สั่งงานชิ้นใหญ่แล้วปล่อยให้ AI วิ่งจนจบ | เหมาะกับงาน Refactor หรือ Batch processing |
| `/browser` | เปิดระบบทดสอบเว็บแบบ Headless Browser | ใช้ตรวจเช็ก UI หน้าเว็บจริงหรือทดสอบฟังก์ชัน |
| `/model` | สลับโมเดล AI (เช่น สลับระหว่าง Flash และ Pro) | ค่าเริ่มต้นแนะนำใช้ **Gemini 3.8 Flash** |
| `/compact` | บีบอัด Context เพื่อประหยัด Token และเพิ่มความเร็ว | ใช้เมื่อบทสนทนาเริ่มยาวเกินไป |
| `/clear` | ล้างหน้าจอและรีเซ็ต Context เพื่อเริ่มงานเรื่องใหม่ | |

---

## 🧩 3. Custom Skills ประจำตัว (พิมพ์ `/<ชื่อสกิล>`)

ทุกสกิลในโฟลเดอร์ `skills/` สามารถเรียกใช้ผ่าน Slash Command ได้ทันที:

### 🌐 หมวด Vibe Coding & Web Architecture
- `/vibe-coding-core`: ออกแบบสถาปัตยกรรม 9 โมดูล, Local-First, Security Checklist
- `/vibe-coding-multifile`: เริ่มต้นหรือจัดการโปรเจกต์แบบ Multi-File (Vite + ES Modules)
- `/vibe-coding-quality`: วางแผนเทสต์ Vitest/Playwright, Quality Gate, Pre-commit
- `/vibe-coding-firebase`: จัดการ Firestore Delta Sync, Firebase Auth, Security Rules
- `/cloudflare-workers-deploy`: จัดการ Deploy หน้าเว็บบน Cloudflare Workers

### 🏭 หมวดโรงงาน GC-M PTA (PTA Mastermind)
- `/pta-process-diagnostic`: ผู้ช่วยวินิจฉัย DCS Yokogawa, Alarm, และวิเคราะห์กระบวนการเคมี
- `/pta-kaizen-writer`: ร่างรายงาน Kaizen 7 หัวข้อ (Kaizen Report Card)
- `/pta-ips-writer`: ร่างข้อความ Before/After สำหรับ Improvement Sheet บน Lotus Notes
- `/pta-safety-observation`: ร่างรายงานสังเกตความปลอดภัย (Unsafe Act / Condition)
- `/pta-exapilot-logic`: ออกแบบลำดับ Logic / Sequence สำหรับ Yokogawa Exapilot
- `/pta-pi-datalink-excel`: ช่วยเขียนสูตรและดึงข้อมูลจาก OSIsoft PI Datalink

### 📈 หมวดการลงทุนหุ้นคุณค่า (VI)
- `/vi-analysis`: ประเมินมูลค่าหุ้น VI Scorecard และวิเคราะห์ปันผลระยะยาว
- `/technical-timing`: จับจังหวะเข้าซื้อหุ้นที่ผ่าน VI Scorecard แล้วด้วย Volume / แนวรับแนวต้าน

---

## 🤖 4. Native Subagents 7 บทบาท (ในโฟลเดอร์ `agents/`)

สามารถสั่งให้ระบบเรียก Subagent เฉพาะทางมารับงานคู่ขนานได้:

1. **`sa-architect`** *(Model: Pro)* — วาง Blueprint 9 โมดูลก่อนเขียนโค้ด
2. **`sa-code-reviewer`** *(Model: Pro)* — ตรวจ Security XSS, Token Contrast, Local-First
3. **`sa-debugger`** *(Model: Pro)* — วินิจฉัย Root Cause ด้วย Five Whys
4. **`sa-explore`** *(Model: Flash)* — ค้นหาไฟล์ ฟังก์ชัน โครงสร้างโปรเจกต์ไว ไม่เปลือง Context
5. **`sa-git-manager`** *(Model: Flash)* — ตรวจ diff, ร่าง commit message, ป้องกัน git พัง
6. **`sa-handoff`** *(Model: Flash)* — จัดการบันทึกสถานะงานข้ามเครื่องลง `HANDOFF.md`
7. **`sa-summarizer`** *(Model: Flash)* — รวบรวมผลลัพธ์จาก Subagent หลายตัวที่รันขนานกัน
