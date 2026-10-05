---
name: pta-plant-reference
description: >
  ข้อมูลอ้างอิงกลางของโรงงาน GC-M PTA (บริษัท, ที่ตั้ง, กระบวนการผลิตหลัก, ตัวอย่าง
  equipment/instrument tag, ข้อมูลผู้ใช้งาน) ใช้เป็น context พื้นฐานประกอบ skill อื่นในตระกูล
  PTA Mastermind (pta-process-diagnostic, pta-kaizen-writer, pta-safety-observation,
  pta-exapilot-logic, pta-pi-datalink-excel, pta-industry-insight) แนบ skill นี้ไว้ในทุก
  Project ที่เกี่ยวกับงานโรงงาน PTA เพื่อให้ Claude รู้จักบริบทโรงงานโดยไม่ต้องอธิบายซ้ำทุกครั้ง
---

# PTA Plant Reference — GC-M PTA

> **บทบาทของไฟล์นี้:** เป็น "แหล่งความจริงเดียว" (single source of truth) สำหรับข้อมูลโรงงานที่
> skill อื่นในตระกูล PTA Mastermind ใช้ร่วมกัน — ป้องกันปัญหา equipment tag/บริบทไม่ตรงกันระหว่าง
> skill (เช่นที่เคยเจอตอนรีวิว vibe-coding skill family ในบัญชีนี้: แต่ละไฟล์ลอกข้อมูลชุดเดียวกันไป
> เขียนซ้ำ แล้วแก้ไม่ครบทุกที่จนข้อมูลเพี้ยนไปคนละทาง)

---

## บริษัทและที่ตั้ง

```
บริษัท : GC-M PTA (PTA Business Unit)
ที่ตั้ง  : นิคมอุตสาหกรรมมาบตาพุด จ.ระยอง
สินค้า  : ผง PTA (Purified Terephthalic Acid)
```

## กระบวนการผลิตหลัก

```
p-Xylene + Air
      │
      ▼
  Oxidation ──────────► CTA (Crude Terephthalic Acid)
      │
      ▼
  Hydrogenation ───────► Purification
      │
      ▼
  PTA (Purified Terephthalic Acid)
```

หมวดหมู่พื้นที่/ระบบหลักที่ปรากฏในเอกสารของพี่ A:
- **Oxidation** — Reactor, Compressor
- **Purification** — Dryer, Filter, Hydrogenation
- **Conveying** — ระบบลำเลียงผง PTA
- **Utilities** — Boiler, Cooling Tower, N2 system

## ผู้ใช้งาน

```
ชื่อ      : Supasit Aoothai
ตำแหน่ง   : Boardman PTA Unit 1
Section  : Production 1
Division : Production
บทบาทเสริม: Lead Auditor (งาน Safety Observation)
```

## ตัวอย่าง Equipment / Instrument Tag ที่เคยใช้อ้างอิง

> ⚠️ **สำคัญ:** ตารางนี้เป็นแค่ "ตัวอย่างที่เคยปรากฏ" ในเอกสารของพี่ A ไม่ใช่ tag legend
> ทางการที่มาจาก P&ID จริง — Claude ไม่ควรเดา/แต่งเติมความหมายของ tag ที่ไม่เคยเห็น หรือยืนยัน
> ว่า tag ใดผูกกับอุปกรณ์ใดโดยไม่มีพี่ A ยืนยัน โดยเฉพาะงาน Safety/Kaizen ที่ต้องระบุอุปกรณ์ถูกตัว
> พี่ A ควรเพิ่ม/แก้ตารางนี้ให้ตรงกับ P&ID จริงของหน่วยเมื่อมีเวลา

สังเกตว่าเอกสารเดิมของพี่ A ใช้ tag 2 รูปแบบที่ **ไม่ใช่ชุดเดียวกัน แต่ไม่ขัดแย้งกัน** — เป็นคนละ
numbering series ตามธรรมเนียมโรงงาน (equipment tag สำหรับเครื่องจักร vs instrument tag
สำหรับเครื่องมือวัด/ควบคุม):

| รูปแบบ | ตัวอย่างที่เคยเห็น | ใช้บ่อยใน |
|---|---|---|
| Equipment tag | PM-101, PM-102, PD-101, CP-101, CP-xxx, TTK-400 | Kaizen, Safety Observation |
| Instrument/Controller tag | TD-201, PD-301, PP-102, FIC-2201A | Exapilot |

หมวดงานที่พบบ่อย (จาก Safety Observation):
```
Rotating Equipment : PM-xxx, CP-xxx
Confined Space      : Vessel, Tank, Pit
Working at Height   : Scaffold, Platform
Chemical             : Acetic Acid, Para-Xylene, Catalyst
Electrical           : Panel, MCC, Transformer
Valve Operation      : Line up, Blow down
งานทั่วไป            : Housekeeping, PPE, Barricade
```

## ระบบ/แพลตฟอร์มที่เกี่ยวข้อง

```
DCS              : Yokogawa
Automation Logic : Exapilot (Operator-Guided Automation)
Data Historian    : OSIsoft PI System (PI Data Archive + PI Asset Framework)
Safety Reporting  : IBM Lotus Notes (Safety Observation Report)
กลุ่มบริษัท       : PTTGC / SCG (ใช้ประกอบ Affiliated Insight — ข่าวองค์กรที่กระทบการดำเนินงาน)
```
