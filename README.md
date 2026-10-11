# gemini-config

Master repo สำหรับ Config, Plugins, Hooks, และ Skills ของ **Google Antigravity / Gemini CLI** สำหรับ Supasit.A (พี่ A)  
ใช้สำหรับ Sync การตั้งค่าและสภาพแวดล้อมระหว่างเครื่อง (ที่ทำงาน GC-M PTA + เครื่องส่วนตัว)

> **Single Source of Truth** สำหรับ Gemini / Antigravity Tools โดยแยกอิสระจาก [`claude-config`](https://github.com/supasiao7896TH/claude-config) เพื่อป้องกัน Schema ชนกัน และป้องกัน Git Bloat จาก Brain/Session Cache

---

## 🏗️ โครงสร้าง Repository

```text
gemini-config/
├── config.json             → การตั้งค่า Plugins และ Environment ทั่วไป
├── hooks.json              → Life-cycle hooks (เช่น Voice alerts บน Windows SAPI)
├── mcp_config.json         → การตั้งค่า MCP Servers (Firebase, Notebooks, Visualizations)
├── .geminiignore           → Global Ignore Pattern สำหรับ Gemini CLI
├── .gitignore              → Strict Gitignore (ตัด /brain, /logs, credentials, node_modules)
├── .prettierrc / .ignore   → มาตรฐานการจัดฟอร์แมตโค้ด
├── setup-junctions.ps1     → สคริปต์ PowerShell สำหรับสร้าง Junctions และ Sync อัตโนมัติ
├── USER.md                 → ข้อมูลบริบทส่วนตัว พี่ A, สไตล์ Vibe Coding, กฎเหล็ก
├── branding/               → Brand Identity ชุด A(i)CODER 2025 & Supasit.A Studio (SVG/Fonts)
├── assets/                 → Assets องค์กร GC-M PTA (โลโก้บริษัทสำหรับ Web Tools)
├── design-lab/             → แม่แบบ Starter (Single HTML / Multi-File Vite) & Preview Kit
├── learning/               → บันทึกการเรียนรู้ Dev Roadmap & Web App Scaling Techniques
├── agents/                 → คลัง Subagent Prompts (sa-architect, sa-reviewer, sa-debugger ฯลฯ)
├── plugins/                → สำหรับ ~/.gemini/config/plugins/
│   ├── android-cli-plugin/
│   ├── chrome-devtools-plugin/
│   ├── firebase/
│   ├── google-antigravity-sdk/
│   ├── modern-web-guidance-plugin/
│   └── user-profile/       → กฎเหล็กประจำตัว (rules/AGENTS.md) และ Persona
├── skills/                 → สำหรับ ~/.gemini/config/skills/
│   ├── accidental-data-loss-prevention/
│   ├── bigquery-sql/
│   ├── dataform-bigquery/
│   ├── dbt-bigquery/
│   ├── pta-*/              → PTA Domain Skills (Exapilot, DCS, Kaizen, Safety)
│   ├── vibe-coding-*/      → Web Architecture Skills (Core, Multifile, Firebase)
│   └── ...
└── sidecars/               → Sidecars configuration
```

---

## 🚀 วิธีติดตั้งบนเครื่องใหม่ (ทำครั้งเดียวต่อเครื่อง)

### ขั้นตอนที่ 0: ติดตั้ง Antigravity CLI (`agy`) (หากยังไม่มีในเครื่อง)
เปิด PowerShell แล้วรันคำสั่ง:
```powershell
irm https://antigravity.google/cli/install.ps1 | iex
```
*(จากนั้นปิดแล้วเปิด PowerShell ใหม่เพื่อโหลด PATH)*

---

### วิธีที่ 1: รันผ่านสคริปต์อัตโนมัติ (แนะนำที่สุด 🌟)

เปิด PowerShell แล้วรันคำสั่ง:

```powershell
git clone https://github.com/supasiao7896TH/gemini-config.git "$env:USERPROFILE\A(i)CODER2025TH\gemini-config"
cd "$env:USERPROFILE\A(i)CODER2025TH\gemini-config"
.\setup-junctions.ps1
```

สคริปต์จะ:
1. สร้าง Junction สำหรับ `skills/` และ `plugins/` เข้าไปยัง `~/.gemini/config/`
2. สำรองโฟลเดอร์เดิมไว้ให้อัตโนมัติหากมีอยู่แล้ว
3. ซิงค์ `config.json`, `hooks.json`, `mcp_config.json`, `.geminiignore`

---

### วิธีที่ 2: ตั้งค่าด้วยมือ (Manual Setup)

```powershell
# 1. Clone repo
git clone https://github.com/supasiao7896TH/gemini-config.git "$env:USERPROFILE\A(i)CODER2025TH\gemini-config"

# 2. ผูก Junction สำหรับ Skills & Plugins
New-Item -ItemType Junction -Path "$env:USERPROFILE\.gemini\config\skills" -Target "$env:USERPROFILE\A(i)CODER2025TH\gemini-config\skills"
New-Item -ItemType Junction -Path "$env:USERPROFILE\.gemini\config\plugins" -Target "$env:USERPROFILE\A(i)CODER2025TH\gemini-config\plugins"

# 3. คัดลอก Config Files
Copy-Item "$env:USERPROFILE\A(i)CODER2025TH\gemini-config\config.json" "$env:USERPROFILE\.gemini\config\config.json"
Copy-Item "$env:USERPROFILE\A(i)CODER2025TH\gemini-config\hooks.json" "$env:USERPROFILE\.gemini\config\hooks.json"
Copy-Item "$env:USERPROFILE\A(i)CODER2025TH\gemini-config\mcp_config.json" "$env:USERPROFILE\.gemini\config\mcp_config.json"
Copy-Item "$env:USERPROFILE\A(i)CODER2025TH\gemini-config\.geminiignore" "$env:USERPROFILE\.gemini\.geminiignore"
```

---

## 🔄 Daily Workflow (การซิงค์ข้อมูลประจำวัน)

- **เมื่อมีการปรับปรุง Skill หรือ Config ในโฟลเดอร์นี้:**
  ```powershell
  cd "$env:USERPROFILE\A(i)CODER2025TH\gemini-config"
  git add .
  git commit -m "feat: update skills and configurations"
  git push origin main
  ```
- **เมื่อสลับไปทำงานอีกเครื่อง:**
  ```powershell
  cd "$env:USERPROFILE\A(i)CODER2025TH\gemini-config"
  git pull origin main
  ```
  *(เนื่องจากผูก Directory Junction ไว้แล้ว ข้อมูลใน Gemini CLI จะอัปเดตตามทันทีโดยไม่ต้อง Copy ใหม่)*

---

## ⚡ PowerShell Shortcuts & CLI Tools

โปรเจกต์นี้มาพร้อมสคริปต์สนับสนุนในโฟลเดอร์ `tools/` และชุดคำสั่งลัดที่ติดตั้งใน `$PROFILE`:

| คำสั่ง / เครื่องมือ | หน้าที่ | วิธีเรียกใช้งาน |
| :--- | :--- | :--- |
| `a` | เรียก Antigravity CLI ทันใจ | `a` (ย่อมาจาก `agy`) |
| `c` | เรียก Claude Code CLI ทันใจ | `c` (ย่อมาจาก `claude`) |
| `Sync-Gemini` | ดึงโค้ดล่าสุดจาก GitHub และอัปเดต Junctions อัตโนมัติ | `Sync-Gemini` |
| `Doctor-Gemini` | วินิจฉัยสุขภาพระบบ Antigravity ครบ 14 จุดตรวจ | `Doctor-Gemini` หรือ `.\tools\doctor.ps1` |
| `New-VibeProject` | สั่งสร้างโปรเจกต์ใหม่ Supasit.A Starter (Multi-File) ในคำสั่งเดียว | `New-VibeProject -ProjectName my-app` |
| `security-gate.ps1` | PreToolUse Hook คอยดักจับไฟล์ความลับและคำสั่งอันตราย | ทำงานอัตโนมัติผ่าน `hooks.json` |
| `voice-alert.ps1` | Lifecycle Hook แจ้งเตือนเสียง Start / Stop (SAPI Speech) | ทำงานอัตโนมัติผ่าน `hooks.json` |
| `statusline.ps1` | Dynamic Terminal Status Bar สไตล์ Supasit.A Studio | กำหนดผ่าน `statusLine` ใน `settings.json` หรือ `/statusline` |

---

## 🛡️ Security & Privacy Guidelines
- **ห้าม Commit:** API Keys, Firebase Service Account JSON, Credentials, และ Session Data
- **`.gitignore`** ถูกตั้งค่าให้อัตโนมัติ ไม่แทร็กโฟลเดอร์ `brain/`, `antigravity-cli/`, `projects/` และนามสกุลคีย์ที่มีความเสี่ยง
- **Security Gate:** ดักจับคำสั่งที่แตะไฟล์ Sensitive หรือคำสั่ง Destructive ผ่าน Hook อัตโนมัติ
  — `setup-junctions.ps1` เขียน path ของ gate เป็น **path เต็ม (ใส่เครื่องหมายคำพูด)** ลง `~/.gemini/config/hooks.json` เพราะ `.\tools\...` ใช้ได้เฉพาะเมื่อ cwd ของ hook คือโฟลเดอร์ config · ยังไม่ได้ยืนยันว่า Antigravity เรียก hook ตัวนี้จริงใน session ให้ลอง `cat .env` แล้วดูว่าถูกถามหรือไม่
- **ห้ามใส่ `C:\Users\<ชื่อ>` (HOME) หรือ `~/.claude` ใน `trustedWorkspaces`** ของ `~/.gemini/antigravity-cli/settings.json` — ไม่งั้น Antigravity จะแก้ settings/hook ของ Claude Code ได้โดยไม่ผ่าน gate ใดๆ (ถอดออกแล้ว 2026-10-11)
- **hooks.json มีที่เดียว:** `hooks.json` ที่ root repo เท่านั้น (ห้ามวางสำเนาใน `plugins/*/hooks.json` — Antigravity โหลดทั้งสองแล้ว hook ชื่อซ้ำ ทำให้ error ซ้ำ ~3,600 ครั้งเมื่อ 4–10 ต.ค.)

## 🧭 เจ้าของไฟล์ (ใครเขียนที่ไหน — กันสองเครื่องมือทับกัน)

| ตำแหน่ง | เจ้าของ (เขียนได้ผู้เดียว) | ฝั่งนี้ต้อง |
|---|---|---|
| `~/.gemini/**`, `~/GEMINI.md`, shortcut Startup `PTA1-Workspace.lnk` | **gemini-config** (`setup-junctions.ps1`) | — |
| `~/.claude/**` (settings.json, CLAUDE.md, USER.md, skills/, agents/) | **claude-config** (`tools/bootstrap.ps1`) | **ห้ามเขียน/ลบ** — `bootstrap.ps1` ของ repo นี้เรียก bootstrap ของ claude-config ให้แทน |
| ไฟล์ที่ทั้งสอง repo ถือสำเนา (`USER.md`, skills `pta-*` / `vibe-coding-*`) | ต้นฉบับอยู่ที่ **claude-config** | แก้ที่ต้นฉบับก่อนแล้วค่อยตามมาที่นี่ (ยังไม่มีตัวตรวจ drift อัตโนมัติข้าม repo) |

กฎ: สคริปต์ห้าม `Remove-Item` / `Copy-Item -Force` ลงโฟลเดอร์ของเจ้าของอีกฝั่ง · ก่อนเปลี่ยนชื่อ/ย้ายไฟล์ที่อีกฝั่งอ่านอยู่ ให้ `grep` อีก repo ก่อน (บทเรียน 2026-10-11: การแยก `CLAUDE.md` ฝั่ง claude-config เกือบทำให้ bootstrap ตรงนี้ทับกฎส่วนกลางทิ้ง)

