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
├── .gitignore              → Strict Gitignore (ตัด /brain, /logs, credentials ออก)
├── setup-junctions.ps1     → สคริปต์ PowerShell สำหรับสร้าง Junctions และ Sync อัตโนมัติ
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

## 🛡️ Security & Privacy Guidelines
- **ห้าม Commit:** API Keys, Firebase Service Account JSON, Credentials, และ Session Data
- **`.gitignore`** ถูกตั้งค่าให้อัตโนมัติ ไม่แทร็กโฟลเดอร์ `brain/`, `antigravity-cli/`, `projects/` และนามสกุลคีย์ที่มีความเสี่ยง
