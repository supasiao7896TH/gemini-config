---
name: deploy
description: รัน Deployment Checklist ของ Supasit.A ทีละข้อก่อนขึ้น production จริง (GitHub Pages / Cloudflare Workers) แล้วรายงานผลแต่ละข้อ
disable-model-invocation: true
---

# /deploy — Deployment Checklist

> เรียกด้วย `/deploy` เท่านั้น — ตั้ง `disable-model-invocation: true` เพื่อไม่ให้ auto-trigger
> กลางบทสนทนาโดยไม่ตั้งใจ (พี่ A อาจแค่ถามเกี่ยวกับ deploy โดยยังไม่พร้อมให้ลงมือจริง)

**ขั้นแรกสุด: รัน `/ตรวจ` ก่อนเสมอ — ไม่เขียว ไม่ deploy**
`npm run check` ต้อง exit 0 และ `sa-code-reviewer` ต้องไม่เหลือ 🔴
ถ้ายังไม่ผ่าน ให้หยุดแล้วรายงานว่าติดข้อไหน **ห้ามข้ามไปทำ checklist ต่อ**

**ขั้นที่สอง: ต้องเคยเปิด preview URL บนมือถือจริงแล้ว** (`/preview`)
ถ้ายังไม่เคย ให้เสนอทำก่อน — §24.5 บังคับข้อนี้ไว้ และตอนนี้ทำได้ *ก่อน* ขึ้น production แล้ว

**ขั้นที่สาม: ต้องรู้คำสั่ง rollback ก่อนกด deploy**
อ่าน `vibe-coding-quality/references/rollback-runbook.md` แล้วบอกพี่ A ว่าถ้าพัง
จะย้อนด้วยคำสั่งอะไร — ก่อนกด ไม่ใช่ตอนพัง

จากนั้นให้ Claude รัน **Deployment Checklist** ของ `vibe-coding-core` §17 ทีละข้อ
(อ่าน `vibe-coding-core/SKILL.md` §17 เต็มๆ ก่อนเริ่ม) — ติ๊กผ่าน/ไม่ผ่านแต่ละข้อพร้อมเหตุผลสั้นๆ
ไม่ใช่แค่บอกว่า "deploy เสร็จแล้ว" เฉยๆ

ถ้าโปรเจกต์นั้นใช้ stack แบบ Vite/multi-file (ดู `vibe-coding-multifile`) หรือ deploy ขึ้น
Cloudflare Workers (ดู `cloudflare-workers-deploy`) ให้ใช้ checklist เฉพาะของ skill นั้นแทน/เสริม
ข้อที่เกี่ยวกับ GitHub Pages ใน §17 — เลือก checklist ให้ตรงกับ stack จริงของโปรเจกต์ที่กำลังทำอยู่
ไม่ใช่รันทุก checklist พร้อมกันแบบเหมารวม

**หลังรันครบ:** สรุปให้พี่ A เห็นชัดว่าข้อไหนผ่าน ข้อไหนยังค้าง/ต้องทำเอง (เช่น ทดสอบบนมือถือจริง)
ก่อนถือว่า deploy เสร็จสมบูรณ์
