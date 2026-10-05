# Design System Reference — "Supasit.A Studio"

> ส่วนหนึ่งของ `vibe-coding-core` — โหลดไฟล์นี้เมื่อเขียน CSS หรือออกแบบ UI
> อัปเดต 2569-08-28: มาตรฐานถาวรของ Supasit.A — **แทนที่ "Instrument Grade" เดิมทั้งหมด**
>
> **ที่มา (ต่างจาก 3 รอบก่อนตรงนี้):** รอบนี้พี่ A เลือกจาก**หน้าจอจริง**ไม่ใช่จากเอกสาร
> เทียบ 3 ทิศทางบน markup ชุดเดียวกัน (Material 3 Expressive · Apple HIG · เว็บทูลสมัยใหม่)
> แล้วเลือกเป็นสูตรผสม: **โครงจากเว็บทูลสมัยใหม่ · ปุ่มแคปซูลจาก Apple · โทนน้ำเงินหมึก**
>
> **ของจริงที่กดเล่นได้อยู่ที่ `claude-config/design-lab/preview-kit.html`**
> **ไฟล์ตั้งต้นสำหรับเริ่มแอปใหม่:** Multi-File (ค่าเริ่มต้น) → `claude-config/design-lab/starter-multifile/` ·
> Single HTML File (ข้อยกเว้น) → `claude-config/design-lab/starter/`
> แก้ token ต้องแก้ที่ preview kit แล้วดูของจริงก่อนเสมอ — ห้ามอนุมัติจากเอกสารเปล่าอีก

---

## ST-0 · แนวคิด (อ่านก่อนใช้ token อื่น)

```
"เครื่องมือที่ใช้ทำงานจริง ไม่ใช่หน้าจอโชว์" — สะอาด อ่านง่าย ไม่แข็งทื่อ
วางตัวเหมือนเว็บทูลระดับโลก (Linear · Notion · Vercel) ไม่ใช่แอปมือถือ ไม่ใช่หน้าจอโรงงาน

4 กติกาที่เป็นเอกลักษณ์:
  ST-01  สีแบรนด์ต้องห่างจากสีสถานะอย่างน้อย 50 องศาบนวงล้อสี
  ST-02  ความลึกมาจากเส้น 1px + เงาบางชั้นเดียว ไม่ใช่เงาหนาหรือ neumorphism
  ST-03  ปุ่มเป็นแคปซูล การ์ดมุม 13px — ความต่างนี้ทำให้ "สิ่งที่กดได้" แยกออกจาก "สิ่งที่อ่าน"
  ST-04  ทุกคู่สีต้องวัด contrast ด้วยเครื่อง ไม่ใช่กะด้วยตา
```

**ST-01 มาจากบทเรียนจริง** — ระบบ 3 รอบก่อนใช้สีแบรนด์ teal hue 173–175° เหมือนกันหมด (ห่างกัน 2°)
ทั้งที่รื้อโครง/ฟอนต์/เงาไปหมดแล้ว ความรู้สึก "แอปดูซ้ำกัน" จึงไม่เคยหาย
และ teal เดิมยังห่างจากเขียว `ok` แค่ 25° ซึ่งเหลือ **5°** ในสายตาคนตาบอดสีเขียว-แดง (~8% ของผู้ชาย)
→ ปุ่ม "บันทึก" กับ chip "ปกติ" กลายเป็นสีเดียวกัน ขัดกับกติกา "สีบอกสถานะ" ที่ตั้งไว้เอง

```
❌ ตัดออกถาวร: neumorphism · gradient-text · .breathing · .pulse-dot ·
   สีแยกหมวดหมู่ · การบังคับ monospace กับตัวเลข (ดูเหตุผลใน ST-2)
```

---

## ST-1 · Spacing — 4pt Grid

```
ค่าที่อนุญาต: 4 · 6 · 8 · 10 · 12 · 14 · 16 · 18 · 20 · 24 · 32 · 44 · 64px
Page padding : 16px (มือถือ) · 20-24px (แท็บเล็ต/เดสก์ท็อป)
Card padding : 18px (ค่ามาตรฐาน) · 14px (แน่น) · 22px (โปร่ง)
Section gap  : 24px (มือถือ) · 28px (เดสก์ท็อป)
Grid gap     : 10px (มือถือ) · 12px (เดสก์ท็อป)

โหมดความแน่น: คูณด้วยตัวแปร --d (0.82 = แน่น · 1 = สบายตา ← ค่ามาตรฐานที่พี่ A เลือก)
```

## ST-2 · Typography — Noto Sans Thai

```
ตระกูลฟอนต์ (บังคับ):
  ทุกอย่าง : "Noto Sans Thai", system-ui, -apple-system, sans-serif

โหลดผ่าน Google Fonts (CSP ต้อง allow fonts.googleapis.com + fonts.gstatic.com):
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Sans+Thai:wght@300;400;500;600;700&display=swap">

Scale (ฐาน --body = 15px × --d):
  h1      : clamp(24px, 3.4vw, 32px) / 600 / letter-spacing -.018em / line-height 1.18
  h2      : body × 1.18 / 600
  body    : 15px / 400 / line-height 1.6
  caption : body × .85 / 400 / var(--text-3)
  label   : body × .85 / 500 / var(--text-2)
  eyebrow : body × .78 / 600 / letter-spacing .1em / UPPERCASE / var(--accent-2)

RULES:
  ✓ heading ใส่ text-wrap: balance
  ✓ ข้อความยาวจำกัด max-width: 62ch
  ✓ ตัวเลขที่เรียงกันในแนวตั้ง (ตาราง/KPI) ใส่ font-variant-numeric: tabular-nums
  ✗ ห้ามใช้ font-weight 800/900
  ✗ ห้ามบังคับ monospace กับตัวเลข
```

> **ทำไมเลิกบังคับ monospace (กฎ IG-01 เดิม):** วัดจริงบนเบราว์เซอร์แล้ว
> **ตัวเลขของ Noto Sans Thai กว้างเท่ากันทุกตัวอยู่แล้ว** — `1111` กับ `8888` ได้ 92px เท่ากันเป๊ะ
> ทั้งเปิดและปิด `tabular-nums` ทศนิยมจึงเรียงตรงคอลัมน์โดยไม่ต้องพึ่งฟอนต์ mono
> กฎเดิมที่บังคับ IBM Plex Mono จึงแก้ปัญหาที่ฟอนต์นี้ไม่มี — ยังใส่ `tabular-nums` ไว้เพื่อความปลอดภัยเวลา fallback

## ST-3 · Border Radius

```
--r-sm:  6px   (chip · badge · ไอคอนกล่องเล็ก)
--r-md:  9px   (input · select · เมนู · การ์ดย่อย)
--r-lg: 13px   (การ์ดหลัก · ตาราง)
--r-xl: 16px   (modal · sheet)
--r-btn: 999px (ปุ่มทุกตัว — แคปซูล)
--r-pill:999px (chip สถานะ)

ST-03: ปุ่มแคปซูล + การ์ดมุม 13px คือความต่างที่ตั้งใจ
"สิ่งที่กดได้" มนสุด "สิ่งที่อ่าน" มนน้อยกว่า ตาจึงแยกออกโดยไม่ต้องพึ่งสี
```

## ST-4 · Color System — น้ำเงินหมึก (ห้าม hardcode hex นอกเหนือจากนี้)

**Light (ค่าเริ่มต้น — พี่ A ใช้สว่างเป็นหลัก)**
```
--bg:            #F7F9FC   พื้นหน้า (neutral เอียงน้ำเงินเล็กน้อย)
--surface:       #FFFFFF   พื้นการ์ด — ต้องต่างจาก --bg เสมอ
--surface-2:     #EDF1F9   พื้นรอง (หัวตาราง · hover)
--surface-3:     #DFE6F3   พื้นลึกสุด (track ของ meter · avatar)
--border:        #D6DEEE   เส้น hairline ปกติ
--border-strong: #B2BFD8   เส้นเน้น · ขอบ input · hover

--text:          #131829   ตัวหนังสือหลัก
--text-2:        #414A60   ตัวหนังสือรอง · label
--text-3:        #5F6980   caption

--accent:        #1D4ED8   สิ่งที่กดได้ · ปุ่มหลัก · ลิงก์ · เส้นกราฟหลัก
--accent-hover:  #173DA8
--on-accent:     #FFFFFF   ตัวหนังสือบนพื้น accent
--accent-soft:   #DFE6FA   พื้นอ่อนของ accent (ปุ่มรอง · nav ที่เลือกอยู่)
--accent-soft-text: #15389C

--accent-2:      #8A6410   ข้อมูลอ้างอิง · eyebrow · รหัสอุปกรณ์ (ไม่ใช่สิ่งที่กดได้)
--accent-2-soft: #FBEFCF   --accent-2-text: #6B4E08

--ok:   #1A7444  --ok-soft:   #D6F0E1   อยู่ในเกณฑ์
--warn: #8A5A08  --warn-soft: #FBEBCF   ต้องเฝ้าระวัง
--crit: #B3261E  --crit-soft: #FBDEDB   ต้องแก้ทันที
--on-crit: #FFFFFF                      ตัวหนังสือบนพื้น crit ทึบ

--shadow-1: 0 1px 2px rgba(15,25,50,.06)
--shadow-2: 0 4px 16px rgba(15,25,50,.11)     ← ใช้เฉพาะ hover / modal
```

**Dark (ออกแบบแยก ไม่ใช่ invert)**
```
--bg:#0E1219 · --surface:#161C27 · --surface-2:#1D2431 · --surface-3:#262F40
--border:#242C3A · --border-strong:#38455A
--text:#E6EAF3 · --text-2:#B0B9CB · --text-3:#868FA3
--accent:#7FA8FF · --accent-hover:#A6C3FF · --on-accent:#141B29
--accent-soft:#1C2538 · --accent-soft-text:#DFE9FF
--accent-2:#E0B85C · --accent-2-soft:#332708 · --accent-2-text:#F0D69A
--ok:#5FD08D  --ok-soft:#0F2E1D
--warn:#E0AE52 --warn-soft:#32250A
--crit:#F0938A --crit-soft:#3A1512 --on-crit:#3A0F0A   ← ไม่ใช่ขาว! ดูหมายเหตุ
--shadow-1: 0 1px 2px rgba(0,0,0,.5) · --shadow-2: 0 4px 18px rgba(0,0,0,.55)
```

> **ทำไมต้องมี `--on-crit`:** ในธีมมืด `--crit` เป็นแซลมอนอ่อน ตัวเลขสีขาวบนพื้นนั้นได้ contrast แค่ **2.27:1**
> (เจอตอนตรวจ badge นับจำนวน) แต่ละธีมจึงต้องเลือกสีตัวอักษรบนพื้น crit เอง → แก้แล้วได้ 7.38:1

**กติกาการใช้สี:**
```
accent   = สิ่งที่กดได้ / interactive เท่านั้น
accent-2 = ข้อมูลอ้างอิง · eyebrow · รหัส (ไม่ใช่สิ่งที่กดได้ ไม่ใช่สถานะ)
ok/warn/crit = สถานะเท่านั้น — ห้ามเอาไปแยกหมวดหมู่ข้อมูล

ST-01 · ก่อนเปลี่ยนสี accent ต้องเช็คระยะ hue จากสีสถานะก่อนเสมอ:
  ปัจจุบัน accent(224°) ห่างจาก ok(148°) = 76°  ✅
  เกณฑ์ขั้นต่ำ 50° — น้อยกว่านี้คนตาบอดสีจะแยกปุ่มกับสถานะไม่ออก

โทนสำรองที่ตรวจแล้วผ่านทั้งหมด (อยู่ใน preview kit กดเทียบได้):
  กรมท่าอมเทา #334E68 (61°) · ฟ้าเข้ม #0369A1 (53°) · ม่วงพลัม #7B2D8E (140°)
```

## ST-5 · Surface — การ์ดเส้นบาง

```css
.card {
  background: var(--surface);           /* ต่างจาก --bg เสมอ */
  border: 1px solid var(--border);      /* ST-02 ความลึกมาจากเส้น */
  border-radius: var(--r-lg);
  box-shadow: var(--shadow-1);          /* เงาบางชั้นเดียว */
  padding: 18px;
  transition: box-shadow .16s cubic-bezier(.4,0,.2,1), border-color .16s;
}
.card.hoverable:hover { box-shadow: var(--shadow-2); transform: translateY(-2px); }

/* กัน grid item ขยายจนดันหน้าเลื่อนแนวนอน — min-width ของ grid item เป็น auto ไม่ใช่ 0 */
.content, .content > section, .grid > *, .card, .tbl-wrap { min-width: 0; }
```

## ST-6 · ปุ่มและช่องกรอก

```css
.btn {
  font-size: 14px; font-weight: 600;
  padding: 10px 20px; min-height: 44px;       /* ST-13 เป้าแตะ */
  border-radius: var(--r-btn);                 /* แคปซูล */
  border: 1px solid transparent; cursor: pointer;
  display: inline-flex; align-items: center; justify-content: center; gap: 8px;
  transition: background .16s cubic-bezier(.4,0,.2,1), transform .16s;
}
.btn:active { transform: scale(.97); }         /* จังหวะกด — ไม่ใช้เงานูน */
.btn:focus-visible { outline: none; box-shadow: 0 0 0 3px color-mix(in srgb, var(--accent) 20%, transparent); }

.btn-primary { background: var(--accent); color: var(--on-accent); }
.btn-soft    { background: var(--accent-soft); color: var(--accent-soft-text); }
.btn-outline { background: transparent; color: var(--text); border-color: var(--border-strong); }
.btn-ghost   { background: transparent; color: var(--text-2); }
.btn-danger  { background: var(--crit-soft); color: var(--crit); }
.btn-sm      { min-height: 36px; padding: 7px 14px; }
@media (max-width: 720px) { .btn-sm { min-height: 44px; padding: 11px 16px; } }

.field :is(input, select, textarea) {
  font-size: 14.3px; width: 100%; min-height: 46px; padding: 12px 14px;
  background: var(--surface); color: var(--text);
  border: 1px solid var(--border-strong); border-radius: var(--r-md);
}
.field :is(input,select,textarea):focus {
  outline: none; border-color: var(--accent);
  box-shadow: 0 0 0 3px color-mix(in srgb, var(--accent) 20%, transparent);
}
.field.err :is(input,textarea) { border-color: var(--crit); }
```

## ST-7 · Data Display

```css
.kpi .k-val { font-size: 30px; font-weight: 700; letter-spacing: -.02em;
  display: flex; align-items: baseline; flex-wrap: wrap; font-variant-numeric: tabular-nums; }
.kpi .k-unit { font-size: 12px; color: var(--text-3); margin-left: 4px; white-space: nowrap; }

.tbl-wrap { overflow-x: auto; border: 1px solid var(--border); border-radius: var(--r-lg); background: var(--surface); }
thead th { font-size: 12px; font-weight: 600; color: var(--text-2); background: var(--surface-2);
  padding: 12px 16px; border-bottom: 1px solid var(--border); white-space: nowrap; text-align: left; }
tbody td { padding: 13px 16px; font-size: 13.8px; border-bottom: 1px solid var(--border); }
tbody tr:hover td { background: var(--surface-2); }
td.num { text-align: right; font-variant-numeric: tabular-nums; }

.chip { display: inline-flex; align-items: center; gap: 5px; padding: 4px 10px;
  border-radius: var(--r-pill); font-size: 11.7px; font-weight: 600; white-space: nowrap; }
.c-ok{background:var(--ok-soft);color:var(--ok)}      .c-warn{background:var(--warn-soft);color:var(--warn)}
.c-crit{background:var(--crit-soft);color:var(--crit)} .c-ref{background:var(--accent-2-soft);color:var(--accent-2-text)}
```

## ST-8 · Dark / Light — ต้องครบ 3 สถานะ

```css
:root { /* ...ชุด light เต็มตาม ST-4... */ }

@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) { /* ...ชุด dark เต็ม... */ }
}
:root[data-theme="dark"] { /* ...ชุด dark เต็ม (ซ้ำ เพื่อให้ผู้ใช้ override ชนะ)... */ }
```
```
⚠️ ไม่ทำ = แอปพังในบางเครื่อง:
  ✓ body ต้องมี background: var(--bg) เสมอ
  ✓ ทุกสีมาจาก token — ห้ามประกาศสีไว้ใน @media หรือ [data-theme] เท่านั้น
  ✓ "ไม่ stamp data-theme เลย" = ตามระบบ — อย่าเผลอ stamp ค่าเริ่มต้นทับ
  ✓ อ่าน/เขียน localStorage ต้องอยู่ใน try/catch เสมอ
```

## ST-9 · Motion

```css
--dur: .16s;  --ease: cubic-bezier(.4,0,.2,1);   /* เร็ว สั้น ไม่เรียกร้องความสนใจ */
@keyframes fadeIn { from {opacity:0} to {opacity:1} }
@keyframes slideUp { from {opacity:0;transform:translateY(8px)} to {opacity:1;transform:none} }
@media (prefers-reduced-motion: reduce) { * { transition:none !important; animation:none !important; } }
```

## ST-10 · Icons

```
Lucide icon set (ไม่ใช้ emoji) — vendor ไว้ที่ public/vendor/lucide.js
ขนาด 16px (ในปุ่ม) · 18px (ทั่วไป) · 20px (nav) · stroke-width 1.9
ไอคอนที่เป็นเนื้อหาต้องมี aria-label ที่ตัวปุ่ม และไอคอนเองใส่ aria-hidden="true"
```

## ST-11 · PWA — บังคับทุกแอป

```
manifest.webmanifest (theme_color = #F7F9FC) · sw.js cache-first · <link rel="manifest">
<meta name="theme-color" content="#F7F9FC" media="(prefers-color-scheme: light)">
<meta name="theme-color" content="#0E1219" media="(prefers-color-scheme: dark)">
apple-mobile-web-app-capable
Single HTML File: sw.js เขียนมือ — bump CACHE_NAME ทุกครั้งที่แก้ไฟล์
Multi-File: manifest + service worker สร้างโดย vite-plugin-pwa (ตั้งใน vite.config.js) — ไม่มี CACHE_NAME
            และ index.html "ห้ามเขียน" <link rel="manifest"> เอง (ปลั๊กอินแทรกให้แล้ว)
→ ของพร้อมใช้อยู่ใน design-lab/starter-multifile/ (Multi-File) · design-lab/starter/ (Single HTML)
```

## ST-12 · Chart — Chart.js ผูกกับ token

```
ใช้ design-lab/starter/chart-theme.js (Single HTML) หรือ
design-lab/starter-multifile/src/modules/chart-theme.js (Multi-File — export ชื่อ ChartTheme)
ที่อ่านสีจาก CSS variable โดยตรง
สลับธีมแล้วเรียก CHART_THEME.refresh(chart) (Single HTML) / ChartTheme.refresh(chart) (Multi-File) กราฟจะเปลี่ยนตามเอง
เส้นหลัก = --accent · เส้นเปรียบเทียบ = --accent-2 · เส้นขีดจำกัด = ok/warn/crit
แกน/grid = --text-3 / --border · ฟอนต์แกน Noto 11px
ต้องเก็บ instance แล้วเรียก .destroy() ก่อนสร้างใหม่ทุกครั้งที่ re-render
```

## ST-13 · Accessibility — ข้อบังคับที่ตรวจด้วยเครื่องได้

```
[ ] contrast ≥ 4.5:1 ทุกคู่สี ทั้งสว่างและมืด — วัดจากสีที่ browser render จริง ไม่ใช่กะเอา
[ ] เป้าแตะบนมือถือ ≥ 44px ทุกปุ่ม/ลิงก์/ตัวเลือก
[ ] ปุ่มไอคอนล้วนต้องมี aria-label · svg ข้างในใส่ aria-hidden="true"
[ ] :focus-visible ต้องมีที่ทุกชิ้นที่โฟกัสได้ (ปุ่ม · field · ลิงก์ nav · tab · เมนู · accordion)
[ ] ไม่มีการเลื่อนแนวนอน ทั้งจอคอมและมือถือ
[ ] ระยะ hue ระหว่าง accent กับสีสถานะ ≥ 50° (ST-01)
```

## ST-14 · ส่วนประกอบมาตรฐาน

มีให้ครบใน `design-lab/preview-kit.html` หน้า "คลังส่วนประกอบ" — คัดลอกไปใช้ อย่าประดิษฐ์ใหม่:

```
tabs · segmented control · dropdown menu · pagination · tooltip · notification badge ·
accordion · การ์ดที่กดได้ทั้งใบ · progress/meter · breadcrumb · checkbox/radio ·
ช่องค้นหาพร้อมไอคอน · avatar group · toast 3 ระดับ · empty state · skeleton ·
modal/sheet · bottom nav · กราฟเส้น/แท่ง/วงแหวน/แท่งซ้อนชั้น
```

## ST-15 · A(i)CODER Badge (Brand Dock)

```
เปลี่ยนเป็นแถบล่างถาวร (.brand-dock) ตั้งแต่ 2569-08-29 — แทนที่ทั้งป้ายมุมขวาล่างแบบนิ่ง (.aicoder-badge เดิม)
และกรอบ #bootSplash แบบครั้งเดียวตอนบูตที่เคยแยกกันมาก่อนหน้านี้ ตอนนี้รวมเป็นกลไกเดียว
ใช้ไฟล์ neon: assets/d1-neon-arcade-bare.svg (สว่าง) · assets/d2-crt-night-bare.svg (มืด) — ไม่ใช่ studio-badge-*.svg อีกต่อไป
ตำแหน่ง: position fixed · เต็มความกว้างจอ ชิดล่าง (left:0; right:0; bottom:0) — ไม่ใช่มุมขวาล่างแบบเดิม
ความสูง: 100px + env(safe-area-inset-bottom) · เครื่องหมายในแถบกว้างคงที่ 280px — ผ่านขั้นต่ำของทั้ง D1 (≥240px) และ D2 (≥280px) พร้อมกัน
พื้นของแถบอ่าน token เดียวกับแอป (var(--surface)/var(--border)/var(--shadow-1)) จึงกลืนกับธีมแอปเสมอ ไม่ต้องเขียน [data-theme="dark"] เพิ่ม
สลับสว่าง/มืดด้วย [data-theme] / prefers-color-scheme ตัวเดียวกับปุ่ม "ธีม" บน topbar
กะพริบตลอดเวลาโดยไม่ต้องมี JS: .tube strike-in (2.6s) เล่นครั้งเดียวตอนแถบถูก mount เข้าหน้า (ให้ผลแบบ boot splash เดิมในตัว)
  แล้ว .tube-s/.tube-b (infinite) กะพริบต่อเนื่องไปตลอดที่หน้ายังเปิดอยู่
main ต้องเพิ่ม padding-bottom ให้พ้นแถบ: calc(100px + env(safe-area-inset-bottom) + 24px) desktop / +16px มือถือ
favicon/PWA icon ใช้ studio-icon.svg เท่านั้นเหมือนเดิม (คนละ requirement — ไม่เกี่ยวกับรอบนี้)
studio-badge-light.svg / studio-badge-dark.svg ยังมีบทบาท แต่จำกัดเฉพาะฝังนอกแอปแบบ static (README badge, screenshot) เท่านั้น
✅ ชุด neon (d1-neon-arcade-bare / d2-crt-night-bare) คือ badge มาตรฐานของทุกแอปแล้ว — ไม่ใช่ของต้องห้ามอีกต่อไป
```

---

## Migration — แอปเดิมที่ใช้ Instrument Grade / Tactile Plant UI

| ของเดิม | เปลี่ยนเป็น |
|---|---|
| teal `#0B4F4A` / `#12857C` / `#0d9488` | `--accent: #1D4ED8` (ST-01 ต้องห่างจากสีสถานะ) |
| `--ground` | `--bg` |
| IBM Plex Sans Thai + IBM Plex Mono | Noto Sans Thai อย่างเดียว |
| บังคับ mono กับตัวเลข (IG-01) | ตัดกฎทิ้ง — เหลือแค่ `tabular-nums` (ดู ST-2) |
| `.tag-strip` (IG-02) | `.eyebrow` + `.c-ref` chip |
| ขอบคม radius 4/6/10 | 6/9/13/16 + ปุ่มแคปซูล |
| `.btn` มุม 6px | `--r-btn: 999px` |
| ไม่มี `--on-crit` | เพิ่ม `--on-crit` ทั้งสองธีม |
| Brass `#8A6D28` | `--accent-2: #8A6410` (บทบาทเดิม: ข้อมูลอ้างอิง) |

> **แอปเดิมไม่ต้องรีบย้าย** — ย้ายเมื่อแอปนั้นถูกแก้ครั้งใหญ่อยู่แล้ว
> แต่**แอปใหม่ทุกตัวเริ่มจาก starter เท่านั้น** — Multi-File → `design-lab/starter-multifile/` ·
> Single HTML File → `design-lab/starter/`
