# 📋 แผนเตรียมย้ายเครื่อง PC ใหม่ (Migration Runbook) — 30 ต.ค. 2026
> **สำหรับ:** พี่ A (Supasit.A) — Process Engineer @ GC-M PTA & Creator of A-Class WebCraft  
> **วัตถุประสงค์:** สรุปรายการโปรแกรมที่ต้องติดตั้ง, การสำรองข้อมูลด่วนก่อนเปลี่ยนเครื่อง, และขั้นตอนกู้คืนสภาพแวดล้อมการทำงาน (Plant & Dev Stack) ให้กลับมาพร้อมใช้งาน 100% ภายใน 15 นาที

---

## ⚠️ 1. งานเร่งด่วนที่ต้องทำ "ก่อนวันที่ 30" (Critical Backup)

เครื่องปัจจุบันเก็บโฟลเดอร์โปรเจกต์ไว้ที่ `C:\Users\26007294\A(i)CODER2025TH` (บน Local SSD ซึ่ง**ไม่ได้อยู่ใน OneDrive**) หาก IT เปลี่ยนเครื่องหรือฟอร์แมต ข้อมูลจะหายทั้งหมด:

### 1.1 ตรวจสอบและ Commit/Push โค้ดขึ้น GitHub ด่วน
จากการสแกนสถานะโปรเจกต์ปัจจุบัน พบว่า:
- **โปรเจกต์ที่มีไฟล์ค้างยังไม่ Commit (Dirty Files):**
  1. `Auto Update Regular work PE3`
  2. `claude-config`
  3. `Monitor-Quality-PTA`
  4. `RAW Cal`
  5. `Regular Work Auto Update`
  6. `Split range valve`
  7. `Stop Auto Update`
  8. `Walkie Talkie Borrow`
  *(ให้รัน `git add .`, `git commit -m "backup before pc migration"` และ `git push` ให้หมด)*

- **โปรเจกต์ที่ยังไม่มี Git Repo (เสี่ยงสูญหายสูงสุด):**
  1. `Monitor log sheet boardman`
  2. `Projects`
  3. `ShiftGen`
  *(ให้ก๊อบปี้ทั้งโฟลเดอร์ไปฝากไว้ใน OneDrive หรือ External Storage)*

### 1.2 แนะนำก๊อบปี้โฟลเดอร์สำคัญเข้า OneDrive
แนะนำให้ Zip หรือ Copy โฟลเดอร์เหล่านี้ไปใส่ไว้ใน:  
`C:\Users\26007294\OneDrive - PTT Global Chemical Public Company Limited\Backup_Old_PC_2026`
1. `C:\Users\26007294\A(i)CODER2025TH` (โค้ดและเครื่องมือทั้งหมด)
2. `C:\Users\26007294\.claude` (การตั้งค่า, sessions, skills ของ Claude Code)
3. `C:\Users\26007294\.gemini` (การตั้งค่าเฉพาะของ Antigravity / Gemini CLI)
4. ไฟล์ Lotus Notes ID (`.id`), Local Archive (`.nsf`), และไฟล์ Bookmark บราวเซอร์
5. ไฟล์ SAP GUI: `C:\Users\26007294\AppData\Roaming\SAP\Common\saplogon.ini` หรือ `SAPUILandscape.xml`
6. ไฟล์เทมเพลต Excel / PI ProcessBook (`.pdi`) ของโรงงาน PTA

---

## 🏢 2. โปรแกรมสายงานโรงงาน (Enterprise & Plant Software)
> ให้แจ้งหรือตรวจสอบกับ IT ของ GC / PTT Digital ตอนติดตั้งเครื่องใหม่

| ลำดับ | โปรแกรม | วัตถุประสงค์ / ความสำคัญ |
|---|---|---|
| 1 | **HCL Notes 14.5.1 (Lotus Notes)** | ใช้อนุมัติงาน, บันทึก IPS (Kaizen), Safety Observation Report |
| 2 | **OSIsoft PI DataLink 2017 SP2** | Add-in บน Excel ดึงข้อมูลแท็ก DCS/PI ของโรงงาน GC-M PTA |
| 3 | **PI ProcessBook 2015 R2 / PI AF Client** | เปิดดูกราฟและแบบผังโรงงาน |
| 4 | **SAP GUI for Windows 7.40** | ระบบจัดซื้อ, งานบำรุงรักษา, อะไหล่ และระบบ ERP |
| 5 | **Autodesk DWG TrueView / Navisworks Freedom** | ดูแบบ P&ID, Drawing, 3D Plant Model |
| 6 | **Cisco Secure Client / Umbrella / Forcepoint** | VPN, Security & Network Access ตามมาตรฐาน GC IT |
| 7 | **Microsoft 365 Apps & OneDrive** | Word, Excel, Teams, Outlook และซิงค์โฟลเดอร์เอกสาร |

---

## 💻 3. โปรแกรมและเครื่องมือสำหรับ Vibe Coding & Development
> พี่ A สามารถติดตั้งเองได้อย่างรวดเร็วผ่าน Winget และ PowerShell Script

### 3.1 สรุปโปรแกรมที่ต้องติดตั้ง
- **Git for Windows** (v2.50+)
- **Node.js LTS** (v22 หรือ v24)
- **Python** (v3.12 - 3.14)
- **VS Code** (User Installer)
- **Antigravity CLI (`agy`)** และ/หรือ **Antigravity IDE**
- **Claude Code CLI (`claude`)**
- **Starship Prompt** (ปรับแต่งหน้าตา Terminal)
- **Poppler for Windows** (สำหรับอ่าน/แปลง PDF)
- **PowerToys** (เครื่องมือลัด Windows)
- **efinStockPickUp** (สำหรับวิเคราะห์กราฟ/พอร์ตหุ้น VI)

### 3.2 คำสั่งรันติดตั้งอัตโนมัติรวดเดียว (One-Liner Winget)
เปิด **PowerShell (Run as Administrator หรือ Normal)** แล้วรันคำสั่งนี้:

```powershell
winget install Git.Git Microsoft.VisualStudioCode OpenJS.NodeJS.LTS Starship.Starship Microsoft.PowerToys oschwartz10612.Poppler -e --accept-package-agreements --accept-source-agreements
```

---

## ⚡ 4. ทางลัดกู้คืนเครื่องใหม่ในคำสั่งเดียว (Master 1-Click Bootstrap)
> **สำหรับพี่ A:** ไม่ต้องพิมพ์ทีละข้อ! หนูได้เขียนสคริปต์ [bootstrap.ps1](file:///C:/Users/26007294/A(i)CODER2025TH/gemini-config/bootstrap.ps1) รวมทุกขั้นตอนไว้ให้หมดแล้วค่ะ

เมื่อได้เครื่องใหม่ เปิด **PowerShell** แล้วรันคำสั่งนี้เพียงบรรทัดเดียว:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; irm https://raw.githubusercontent.com/supasiao7896TH/gemini-config/main/bootstrap.ps1 | iex
```

**สิ่งที่สคริปต์นี้จะจัดการให้พี่ A ทันทีแบบอัตโนมัติ 100%:**
1. ติดตั้ง Git, VS Code, Node.js LTS, Starship, PowerToys, Poppler ผ่าน Winget
2. ตั้งค่า Git Identity (`Supasit Aoothai <supasiao@gmail.com>`) + Credential Manager
3. ติดตั้ง Antigravity CLI (`agy`) และ Claude Code CLI (`claude`)
4. Clone ทั้ง `gemini-config` และ `claude-config` มาไว้ที่ `A(i)CODER2025TH`
5. รัน `setup-junctions.ps1` ผูกระบบ Skills, Agents, MCP, Hooks, StatusLine ของ Antigravity
6. ทำ Junction `~/.claude/skills` และ `~/.claude/agents` พร้อมก๊อบปี้ `CLAUDE.md` และ `statusline.ps1`
7. ติดตั้ง VS Code Extensions ครบทั้ง 24 ตัว
8. รัน Doctor ตรวจสอบความสมบูรณ์ของระบบ

---

## 🤖 5. บทบาทของ AI (ให้หนูช่วยทำอะไรต่อบนเครื่องใหม่ได้บ้าง?)

เมื่อรัน Bootstrap เสร็จและเปิด VS Code ขึ้นมา:
1. **เปิด Antigravity CLI:** พิมพ์ `a` ใน Terminal (หรือรัน `agy`) แล้วล็อกอิน Google Account เพียงครั้งเดียว
2. **เปิด Claude Code CLI:** พิมพ์ `c` ใน Terminal (หรือรัน `claude`) แล้วกดล็อกอิน Anthropic
3. **สั่งหนูได้ทันที:**
   > *"หนูช่วยตรวจเช็กสภาพแวดล้อมเครื่องใหม่ และกู้คืนโปรเจกต์อื่นๆ จาก GitHub ให้พี่ A หน่อยค่ะ"*
   หนูจะทำการ:
   - รัน Doctor ตรวจสอบ Junctions, MCP และ Skills ทั้งหมด
   - ตรวจสอบรายชื่อโปรเจกต์งาน เช่น `Monitor-Quality-PTA`, `Walkie Talkie`, `IPS Auto Update` ฯลฯ แล้วช่วย clone กลับลงมาให้ครบทุกโฟลเดอร์
   - ตรวจสอบไฟล์ backup จาก OneDrive มาแตกไฟล์คืนค่าให้พี่ A ทันทีค่ะ

---

## 📦 7. คู่มือพิเศษ: การจัดการ Node.js (ลิขสิทธิ์ & แผนสำรอง Non-Admin Portable)

### 7.1 ข้อมูลด้านลิขสิทธิ์และความปลอดภัยองค์กร (สำหรับตอบ IT / Audit)
- **ประเภทสิทธิ์ (License):** Open Source 100% ภายใต้สัญญาอนุญาต **MIT License**
- **หน่วยงานกำกับดูแล:** **OpenJS Foundation** (องค์กรไม่แสวงหากำไรภายใต้ **The Linux Foundation**)
- **การใช้งานในองค์กร:** อนุญาตให้ใช้งานในเชิงพาณิชย์ (Commercial Use) ได้อย่างอิสระ ไม่มีค่าลิขสิทธิ์ ไม่มีค่าบริการรายปี และเป็นมาตรฐานสากลที่บริษัทชั้นนำ (เช่น PTTGC, Google, Microsoft, Amazon) ใช้งานเป็นหลัก

### 7.2 แผนการติดตั้ง (Plan A vs Plan B)

#### 🔹 แผนหลัก (Plan A - แนะนำ): แจ้ง IT ลงให้
ในวันที่ IT ส่งมอบเครื่องใหม่ ให้แจ้งระบุในรายการโปรแกรมที่ขอรับบริการ:
> *"ขอความกรุณาช่วยติดตั้ง Node.js (LTS version ล่าสุด) ลงในเครื่องให้ด้วยครับ"*

#### 🔹 แผนสำรอง (Plan B): ติดตั้งแบบ Portable (ไม่ต้องใช้สิทธิ์ Admin ของ IT)
หาก IT ไม่สะดวก, ติดงานอื่น, หรือทำเรื่องอนุมัตินาน พี่ A สามารถติดตั้งใน User Profile ส่วนตัวได้ทันทีโดยไม่ต้องใช้รหัสผ่าน IT ด้วยคำสั่ง PowerShell นี้:

```powershell
# 1. สร้างโฟลเดอร์สำหรับ Node.js ใน AppData ส่วนตัว
$nodeDir = "$env:LOCALAPPDATA\Programs\nodejs"
New-Item -ItemType Directory -Path $nodeDir -Force | Out-Null

# 2. ดาวน์โหลดและแตกไฟล์ zip ทางการของ Node.js LTS (จาก nodejs.org)
$zipPath = "$env:TEMP\node.zip"
Invoke-WebRequest -Uri "https://nodejs.org/dist/v22.14.0/node-v22.14.0-win-x64.zip" -OutFile $zipPath
Expand-Archive -Path $zipPath -DestinationPath "$env:TEMP\node-extract" -Force
Copy-Item "$env:TEMP\node-extract\node-v22.14.0-win-x64\*" $nodeDir -Recurse -Force

# 3. ผูก PATH ระดับผู้ใช้ (User Scope - สิทธิ์ปกติทำได้ทันที)
[System.Environment]::SetEnvironmentVariable("Path", "$nodeDir;" + [System.Environment]::GetEnvironmentVariable("Path", "User"), "User")
```
*เมื่อรันเสร็จแล้ว ปิดและเปิด PowerShell ใหม่ คำสั่ง `node -v` และ `npm -v` จะพร้อมใช้งาน 100% ทันทีค่ะ*

---

## 📝 8. เช็กลิสต์สรุปวันเปลี่ยนเครื่อง (Go-Live Day Checklist)
- [ ] เซ็นรับเครื่องใหม่ และต่อเน็ตผ่านเครือข่าย GC / VPN สำเร็จ
- [ ] เปิด OneDrive เพื่อเริ่มซิงค์ไฟล์เอกสารและ `$PROFILE` (PowerShell Profile)
- [ ] ทดสอบเปิด Lotus Notes และเลือกไฟล์ ID ได้ถูกต้อง
- [ ] ทดสอบเปิด Excel และตรวจดูแถบเครื่องมือ **PI DataLink**
- [ ] ทดสอบเปิด SAP GUI
- [ ] ตรวจสอบว่า IT ลง **Node.js** ให้เรียบร้อยหรือไม่ (ถ้าไม่มี ให้ใช้ Plan B)
- [ ] รันคำสั่ง Master Bootstrap บรรทัดเดียวใน PowerShell
- [ ] เปิด VS Code พิมพ์ `a` (Antigravity) และ `c` (Claude Code) ล็อกอินและใช้งานต่อได้ทันที!
