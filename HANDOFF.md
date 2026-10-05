# HANDOFF.md — สถานะและคู่มือส่งต่องาน gemini-config

> ไฟล์นี้ใช้สำหรับส่งต่องานข้ามเครื่อง (บ้าน ↔ ที่ทำงาน GC-M PTA) และเป็นแผนกู้ชีพฉุกเฉิน (Disaster Recovery Runbook) สำหรับการตั้งค่า Google Antigravity / Gemini CLI ของพี่ A (Supasit.A)

**อัปเดตล่าสุด:** 2026-10-05 (เพิ่มคู่มือติดตั้ง Antigravity CLI (`agy`) สำหรับเครื่องบ้าน/เครื่องใหม่ + อธิบายความต่างจาก Antigravity IDE)

---

## 🚨 1. แผนกู้ชีพเมื่อย้ายเครื่องใหม่ หรือข้อมูลหาย (Disaster Recovery Runbook)

หากคอมพัง, ล้างเครื่องใหม่, หรือไปเริ่มงานที่เครื่อง PC อื่น (เช่น เครื่องที่บ้าน) ให้ทำตามขั้นตอนนี้:

### Step 0: ติดตั้ง Antigravity CLI (`agy`)
> **ข้อสังเกต:** หากดาวน์โหลดจากหน้าเว็บหลักของ Antigravity ปุ่มดาวน์โหลดมักจะได้ **Antigravity IDE** (ไฟล์ติดตั้ง `.exe` ขนาด ~220 MB ซึ่งเป็นโปรแกรม IDE หน้าต่างแยกเดี่ยว)  
> หากต้องการใช้งานเป็น **CLI ใน Terminal ของ VS Code** (มีโลโก้ตัว A สีรุ้งและพิมพ์คำสั่งได้เหมือนที่ทำงาน) ให้ติดตั้งตัว CLI ผ่าน PowerShell:

1. เปิด **PowerShell** บนเครื่องใหม่ แล้วรันคำสั่งติดตั้งตัว CLI:
   ```powershell
   irm https://antigravity.google/cli/install.ps1 | iex
   ```
   *(สคริปต์จะติดตั้ง `agy.exe` ไว้ที่ `C:\Users\<User>\AppData\Local\agy\bin` และผูก Environment PATH ให้อัตโนมัติ)*

2. ปิดแล้วเปิดหน้าต่าง PowerShell ใหม่ (หรือเปิด VS Code) แล้วตรวจเช็กเวอร์ชัน:
   ```powershell
   agy --version
   ```

3. เมื่อพิมพ์คำสั่ง `agy` ใน Terminal ของ VS Code ในครั้งแรก ระบบจะให้ยืนยันตัวตนด้วย Google Account (เช่น บัญชี Google AI Pro) เมื่อยืนยันเสร็จจะเข้าสู่หน้าจอ CLI ทันที

---

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
สคริปต์จะสร้าง Directory Junction สำหรับ `skills/`, `agents/`, `tools/` และโฟลเดอร์ใน `plugins/` เข้าไปยัง `~/.gemini/config/` โดยอัตโนมัติ:
```powershell
Get-Item "$env:USERPROFILE\.gemini\config\skills" | Select-Object FullName, LinkType, Target
Get-Item "$env:USERPROFILE\.gemini\config\agents" | Select-Object FullName, LinkType, Target
Get-Item "$env:USERPROFILE\.gemini\config\tools" | Select-Object FullName, LinkType, Target
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
สามารถพิมพ์คำสั่งลัดคำเดียวใน PowerShell:
```powershell
Sync-Gemini
```
*(ฟังก์ชันนี้จะดึง `git pull origin main` และรัน `setup-junctions.ps1` อัปเดต Junctions ให้อัตโนมัติในคำสั่งเดียว)*

> [!TIP]
> **PowerShell Shortcuts ที่ติดตั้งไว้แล้ว:**
> - `a` → เรียก `agy` (Antigravity CLI)
> - `c` → เรียก `claude` (Claude Code CLI)
> - `Sync-Gemini` → ซิงค์การตั้งค่า Gemini ล่าสุด
> - `Doctor-Gemini` → ตรวจสุขภาพความพร้อมของระบบ Antigravity ใน 3 วินาที (`.\tools\doctor.ps1`)
> - `New-VibeProject` → สร้างโปรเจกต์ใหม่ Multi-File (Vite + ES Modules) ในคำสั่งเดียว (`.\tools\new-vibe-project.ps1`)
> - `Sync-Claude` → ซิงค์การตั้งค่า Claude
> *(หากเครื่องที่บ้านยังไม่มี ให้ก๊อปปี้โค้ดจาก `tools/powershell-profile-snippet.ps1` ไปวางใน `$PROFILE` ที่บ้าน)*

---

## 🗂️ 3. โครงสร้างไฟล์และหน้าที่ (Repository Architecture)

```text
gemini-config/
├── config.json             → การตั้งค่า Plugins, Remote Control Hostname, Dark Theme
├── hooks.json              → Life-cycle hooks (Windows SAPI Voice alerts & Security Gate)
├── mcp_config.json         → MCP Servers (Firebase, Puppeteer, BigQuery)
├── .geminiignore           → Ignore rules สำหรับ Gemini CLI
├── .gitignore              → Strict Gitignore (ตัด /brain, /logs, credentials, node_modules)
├── .prettierrc / .ignore   → มาตรฐานการจัดฟอร์แมตโค้ด
├── setup-junctions.ps1     → สคริปต์ติดตั้งและสร้าง Junction อัตโนมัติ (มี Per-plugin Fallback)
├── USER.md                 → ข้อมูลบริบทส่วนตัว พี่ A, สไตล์ Vibe Coding, กฎเหล็ก
├── tools/                  → เครื่องมือสนับสนุน CLI
│   ├── doctor.ps1          → สคริปต์วินิจฉัยสุขภาพระบบ Antigravity (14 จุดตรวจ)
│   ├── security-gate.ps1   → PreToolUse Hook ป้องกันไฟล์หลุดและคำสั่งอันตราย
│   ├── new-vibe-project.ps1→ สคริปต์สร้างโปรเจกต์ใหม่ Supasit.A Starter อัตโนมัติ
│   └── powershell-profile-snippet.ps1 → ชุดคำสั่งลัดสำหรับวางใน $PROFILE
├── branding/               → Brand Identity ชุด A(i)CODER 2025 & Supasit.A Studio (SVG/Fonts)
├── assets/                 → Assets องค์กร GC-M PTA (โลโก้บริษัทสำหรับ Web Tools)
├── design-lab/             → แม่แบบ Starter (Single HTML / Multi-File Vite) & Preview Kit
├── learning/               → บันทึกการเรียนรู้ Dev Roadmap & Antigravity CLI Cheatsheet
├── agents/                 → คลัง Subagent Prompts (sa-architect, sa-reviewer, sa-debugger ฯลฯ)
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
- [x] รองรับ Multi-machine อัตโนมัติ: หากเครื่องบ้านมี User profile ชื่ออื่น (เช่น `PC 4000D` แทน `26007294`) สคริปต์ `setup-junctions.ps1` จะแปลง Path ใน `mcp_config.json` ให้ตรงกับ `$env:USERPROFILE` ประจำเครื่องนั้นๆ ให้อัตโนมัติ
