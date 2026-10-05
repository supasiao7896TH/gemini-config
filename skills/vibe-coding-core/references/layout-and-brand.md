# Layout & Brand Identity Reference — "Supasit.A Studio"

> ส่วนหนึ่งของ `vibe-coding-core` — โหลดไฟล์นี้เมื่อออกแบบ layout หรือตรวจ brand compliance
> อัปเดต 2569-08-28: คู่กับ `design-system.md` (Supasit.A Studio) — **แทนที่ Instrument Grade เดิม**
> ของจริงที่กดเล่นได้: `claude-config/design-lab/preview-kit.html` · ไฟล์ตั้งต้น: `design-lab/starter-multifile/` (Multi-File, ค่าเริ่มต้น) · `design-lab/starter/` (Single HTML File)

---

## Layout Guide

พี่ A ตอบว่าอุปกรณ์ **"แล้วแต่โปรเจกต์"** — ระบบนี้จึงไม่บังคับ mobile-first หรือ desktop-first
แต่กำหนด **โครงกลางโครงเดียวที่พลิกได้ทั้งสองทาง** โดยไม่ต้องออกแบบใหม่

```
Topbar (บังคับทุกขนาดจอ):
  sticky top-0 · พื้น = --bg ที่ blur (color-mix 85% + backdrop-filter: blur(8px))
  border-bottom: 1px solid var(--border)
  ซ้าย: กล่องโลโก้ 30px (พื้น --accent, มุม --r-sm) + ชื่อแอป 600 letter-spacing -.018em
  ขวา: ปุ่มสลับธีม (.btn .btn-ghost — ต้องมี aria-label)
  ❌ ห้าม gradient-text · ห้ามจุดสถานะกะพริบ

Sidebar (PC/Desktop ≥720px):
  พื้น = --bg เดียวกับหน้า · border-right: 1px solid var(--border)
  เมนู: Lucide icon 18-20px + label · active = --accent-soft-text บนพื้น --accent-soft
  hover = พื้น --surface-2 · ต้องมี :focus-visible ring (ST-13)

Bottom Nav (Mobile ≤720px):
  position: sticky bottom-0 · พื้น --bg ที่ blur · border-top: 1px solid var(--border)
  icon 18px + label 11px · active = --accent-soft-text บนพื้น --accent-soft
  แต่ละปุ่มสูง ≥ 48px · เผื่อ safe-area: padding-bottom: env(safe-area-inset-bottom)
  ต้องมี :focus-visible ring · วางไม่ทับ A(i)CODER badge

KPI Tile:
  .card + .k-label + .k-val (tabular-nums) + .k-unit + chip สถานะ
  รหัสอุปกรณ์/ที่มาของข้อมูลใช้ .c-ref chip (สีอำพัน) หรือ .eyebrow เหนือหัวเรื่อง
  ❌ ไม่ใช้แถบสีตามหมวดหมู่ — สีสงวนไว้ให้สถานะ (ST-04)

Grid:
  KPI: repeat(auto-fit, minmax(165px, 1fr)) · จอ ≥760px บังคับ repeat(4, minmax(0,1fr))
  มือถือ ≤720px: repeat(2, minmax(0,1fr)) gap 10px
  ⚠️ ทุก grid item ต้องมี min-width: 0 ไม่งั้นตารางกว้างจะดันหน้าเลื่อนแนวนอน

Section:
  gap ระหว่าง section: 22px (mobile) → 28px (desktop)
  คั่นด้วยระยะห่างและการ์ด ไม่ใช้พื้นสีสลับ

Content width:
  max-width: 1080px · padding: 16px (mobile) → 20-24px (desktop)
  ข้อความยาว max-width: 62ch
```

---

## Brand Identity (Supasit.A × Studio)

```
Eyebrow (ป้ายกำกับเหนือหัวเรื่อง):
  .eyebrow — body×.78 · 600 · letter-spacing .1em · UPPERCASE · สี --accent-2 (อำพัน)
  ใช้บอกที่มา/หมวดของหน้า เช่น "UNIT 100 · กะเช้า"

ป้ายรหัสอ้างอิงในตาราง/การ์ด:
  .chip.c-ref — พื้น --accent-2-soft ตัวอักษร --accent-2-text
  ใช้กับรหัสจริงเท่านั้น (tag อุปกรณ์ · เลขเอกสาร) ห้ามสร้างรหัสปลอมมาใส่

Header ของแอป:
  พื้น --bg ที่ blur 8px + เส้นล่าง hairline
  ปุ่มสลับธีมใช้ .btn .btn-ghost พร้อม aria-label

A(i)CODER Badge — Brand Dock (บังคับทุกแอป, เปลี่ยนเป็นแถบล่างถาวร 2569-08-29):
  ที่มา: claude-config/branding/ (README.md หัวข้อ "D4 — Studio")
  ใช้ assets/d1-neon-arcade-bare.svg บนพื้นสว่าง · assets/d2-crt-night-bare.svg บนพื้นมืด (ไม่ใช่ studio-badge-*.svg อีกต่อไป — ไฟล์นั้นเหลือแค่ฝังนอกแอปแบบ static)
  พื้นของแถบ = var(--surface) + var(--border) + var(--shadow-1) ของแอปเอง (เหมือน .card) จึงกลืนกับธีมแอปอัตโนมัติ ไม่ต้องเขียน [data-theme="dark"] เพิ่ม
  ตำแหน่ง: fixed เต็มความกว้างจอ ชิดล่าง (ไม่ใช่มุมขวาล่างแบบเดิม) · สูง 100px + env(safe-area-inset-bottom) · เครื่องหมายในแถบกว้าง 280px (ผ่านขั้นต่ำ D1 ≥240px และ D2 ≥280px พร้อมกัน)
  main ต้องเผื่อ padding-bottom ให้พ้นแถบ (ดู design-lab/starter-multifile/index.html หรือ design-lab/starter/index.html)
  กะพริบตลอดเวลา (ไม่ใช่แค่ตอนบูตเหมือนเดิม): .tube strike-in เล่นครั้งเดียวตอนแถบถูกโหลดเข้าหน้า (แทนที่ #bootSplash เดิมได้ในตัว) แล้ว .tube-s/.tube-b (infinite) กะพริบต่อเนื่องไปตลอด — ไม่ต้องมี JS ควบคุมเลย
  favicon/PWA icon: studio-icon.svg เท่านั้น (ตัว A เป็นเส้น อ่านออกที่ 16px) — ไม่เปลี่ยนจากเดิม
  ✅ ชุด neon (d1-neon-arcade-bare / d2-crt-night-bare) คือ badge มาตรฐานของทุกแอปแล้ว — ไม่ใช่ของต้องห้ามอีกต่อไป
  ของพร้อมใช้: index.html ของทั้ง design-lab/starter-multifile/ และ design-lab/starter/ มี .brand-dock แบบ inline ให้แล้ว

Icons: Lucide เท่านั้น stroke-width 1.9 — ห้าม emoji เป็นไอคอนของปุ่ม/nav
       ปุ่มไอคอนล้วนต้องมี aria-label และ svg ข้างในใส่ aria-hidden="true"

Micro-interactions (ดู design-system.md ST-9):
  - fade-in / slide-up เมื่อการ์ดโหลดครั้งแรก
  - hover การ์ด: เงาขึ้นชั้น --shadow-2 + ยก 2px
  - ปุ่มกด: transform scale(.97) — จังหวะกดอยู่ตรงนี้ ไม่ใช้เงานูน
  - ❌ ห้าม: breathing, pulse, gradient, parallax, ambient animation
```

---

## Voice & Copy (ส่วนของแบรนด์ที่ไม่ใช่ภาพ)

```
เขียนจากฝั่งผู้ใช้ ไม่ใช่ฝั่งระบบ:
  ❌ "Sync config ล้มเหลว (error 503)"
  ✅ "บันทึกขึ้นคลาวด์ไม่สำเร็จ — ข้อมูลยังอยู่ในเครื่อง ลองใหม่อีกครั้งได้เลย"

ปุ่มบอกสิ่งที่จะเกิดขึ้นจริง: "บันทึกค่า" → toast "บันทึกแล้ว"
ข้อความ error บอกว่าเกิดอะไรและแก้ยังไง — ไม่ขอโทษ ไม่คลุมเครือ
หน่วยวัดเขียนแยกจากตัวเลขเสมอ (196.85 °C ไม่ใช่ 196.85°C ติดกัน)
```

---

## Reference Implementation

**`claude-config/design-lab/preview-kit.html`** — ของจริงที่กดเล่นได้ ไม่ใช่ภาพนิ่ง
มีทุก component ของระบบ · สลับธีม 3 สถานะ · สลับโทนสีสำรอง · กรอบมือถือ 390px ในตัว

**`claude-config/design-lab/starter-multifile/`** — ไฟล์ตั้งต้นของ Multi-File (ค่าเริ่มต้น)
token ครบ · โมดูล ES ไฟล์ละโมดูลใน `src/modules/` · PWA ผ่าน vite-plugin-pwa · badge · ธีม Chart.js · Vitest + Playwright

**`claude-config/design-lab/starter/`** — ไฟล์ตั้งต้นของ Single HTML File (ข้อยกเว้น)
token ครบ · 9 โมดูล IIFE · PWA · badge · ธีม Chart.js · CSP

> **กติกาถาวรตั้งแต่รอบนี้:** จะแก้ design system ต้องแก้ที่ preview kit แล้วดูของจริงก่อน
> ห้ามอนุมัติจากเอกสารเปล่า — 3 รอบก่อนหน้าล้มเพราะทำแบบนั้น
