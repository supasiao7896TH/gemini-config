# HANDOFF.md — สถานะและคู่มือส่งต่องาน gemini-config

> ไฟล์นี้ใช้สำหรับส่งต่องานข้ามเครื่อง (บ้าน ↔ ที่ทำงาน GC-M PTA) และเป็นแผนกู้ชีพฉุกเฉิน (Disaster Recovery Runbook) สำหรับการตั้งค่า Google Antigravity / Gemini CLI ของพี่ A (Supasit.A)

**อัปเดตล่าสุด:** 2026-10-05 (เครื่อง Office — แยก gemini-config เป็น Standalone Repo อิสระจาก claude-config พร้อมระบบ Junction อัตโนมัติ)

---

## 🚨 1. แผนกู้ชีพเมื่อย้ายเครื่องใหม่ หรือข้อมูลหาย (Disaster Recovery in 3 Steps)

หากคอมพัง, ล้างเครื่องใหม่, หรือไปเริ่มงานที่เครื่อง PC อื่น ให้ทำตาม 3 ขั้นตอนนี้เท่านั้น:

### Step 1: Clone Repository
เปิด PowerShell แล้วรันคำสั่ง:
```powershell
git clone https://github.com/supasiao7896TH/gemini-config.git "$env:USERPROFILE\A(i)CODER2025TH\gemini-config"
```

### Step 2: รันสคริปต์เชื่อมโยง Junction
```powershell
cd "$env:USERPROFILE\A(i)CODER2025TH\gemini-config"
powershell -ExecutionPolicy Bypass -File .\setup-junctions.ps1
```

### Step 3: ตรวจสอบความถูกต้อง
สคริปต์จะสร้าง Directory Junction สำหรับ `skills/` และโฟลเดอร์ใน `plugins/` เข้าไปยัง `~/.gemini/config/` โดยอัตโนมัติ:
```powershell
Get-Item "$env:USERPROFILE\.gemini\config\skills" | Select-Object FullName, LinkType, Target
Get-ChildItem "$env:USERPROFILE\.gemini\config\plugins" | Select-Object Name, LinkType, Target
```
*(ต้องแสดง `LinkType = Junction` และชี้กลับมาที่โฟลเดอร์ repo นี้)*

---

## 🔄 2. การทำงานประจำวัน (Daily Workflow)

### บนเครื่องที่กำลังทำงาน (Office / บ้าน):
เมื่อมีการแก้ไข Skill, เพิ่ม Custom Hook, หรือแก้การตั้งค่าใน Antigravity:
```powershell
cd "$env:USERPROFILE\A(i)CODER2025TH\gemini-config"
git status
git add .
git commit -m "feat: update gemini configuration or skills"
git push origin main
```

### เมื่อสลับไปอีกเครื่อง:
```powershell
cd "$env:USERPROFILE\A(i)CODER2025TH\gemini-config"
git pull origin main
```
*(ข้อมูลทั้งหมดจะอัปเดตเข้า Antigravity / Gemini CLI ทันทีโดยไม่ต้องรันสคริปต์ซ้ำ เพราะเชื่อมโยงผ่าน NTFS Junction ไว้อยู่แล้ว)*

---

## 🗂️ 3. โครงสร้างไฟล์และหน้าที่ (Repository Architecture)

```text
gemini-config/
├── config.json             → การตั้งค่า Plugins, Remote Control Hostname, Dark Theme
├── hooks.json              → Life-cycle hooks (Windows SAPI Voice alerts Start/Stop)
├── mcp_config.json         → MCP Servers (Firebase, Notebooks, Visualizations)
├── .geminiignore           → Ignore rules สำหรับ Gemini CLI
├── .gitignore              → ป้องกัน Credentials, /brain, /logs หลุดขึ้น GitHub
├── setup-junctions.ps1     → สคริปต์ติดตั้งและสร้าง Junction อัตโนมัติ (มี Per-plugin Fallback)
├── plugins/                → แหล่งรวม Plugins & กฎเหล็ก (user-profile/rules/AGENTS.md)
├── skills/                 → แหล่งรวม Skills ทั้งหมด (Vibe Coding + GCP/BigQuery + PTA)
├── sidecars/               → Sidecars configuration
├── README.md               → ภาพรวมโปรเจกต์และวิธีติดตั้ง
└── HANDOFF.md              → เอกสารฉบับนี้ (Disaster Recovery & Operational Runbook)
```

---

## 🛡️ 4. กฎความปลอดภัย (Security Checklist)
- [x] ตรวจสอบ `.gitignore` ว่าตัดโฟลเดอร์ `brain/`, `logs/`, `projects/`, `.env*`, `credentials.json`, `*serviceAccount*.json` เรียบร้อย
- [x] ไม่เก็บบัญชีรหัสผ่านหรือ Token ส่วนบุคคลลงใน `mcp_config.json` หรือ `config.json`
- [x] หากเครื่องบ้านมี User profile ชื่ออื่น (เช่น `PC 4000D` แทน `26007294`) ให้ตรวจทาน Path ใน `mcp_config.json` ให้ตรงกับ Extension Directory ของเครื่องนั้นๆ
