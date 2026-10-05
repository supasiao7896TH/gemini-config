---
name: vi-analysis
description: >
  Value Investing Analysis Skill สไตล์ VI เน้นปันผลระยะยาว ผ่าน Bualuang Securities
  ใช้เมื่อพี่ A ขอวิเคราะห์หุ้น หาปันผล คำนวณ Valuation ให้ Scorecard
  หรือพูดถึง SET, หุ้นไทย, PTTEP, PTT, OR, GPSC, PTTGC, VI, ลงทุน, ปันผล
---

# Value Investing Analysis — Supasit.A Skill

> **Scope:** VI Analysis · Valuation 4 วิธี · Scorecard /30 · Exit Criteria · Bualuang-style Output
> **ใช้เมื่อ:** วิเคราะห์หุ้น / ปันผล / Valuation / Scorecard / พอร์ต / ตัดสินใจขาย
> **โบรกเกอร์:** Bualuang Securities | **Benchmark:** SET100

| | |
|---|---|
| **Version** | 6.0 |
| **Updated** | 2026-07 |
| **Brand** | A-Class WebCraft · Code • Share • Inspire · by Supasit.A |
| **Sections in this file** | §22.0–22.9 |
| **Related skills** | `technical-timing` — ใช้ต่อกันหลัง Scorecard ผ่านแล้วเท่านั้น |

---

## § 22.0 · ข้อจำกัดของข้อมูล (อ่านก่อนวิเคราะห์ทุกครั้ง)

```
⚠️ Claude ไม่สามารถดึงราคาหุ้น/กราฟ real-time ได้เอง — ไม่มี live market data feed
   → ต้องขอตัวเลขล่าสุด (ราคา, งบการเงิน, DPS) จากพี่ A หรือ screenshot จาก Settrade/BLS
     ก่อนเริ่มวิเคราะห์ทุกครั้ง ห้ามสมมติราคาปัจจุบันเอง

⚠️ ข้อมูลที่ AI มีในความจำอาจล้าสมัย (งบไตรมาสใหม่, เปลี่ยนนโยบายปันผล ฯลฯ)
   → ระบุวันที่ของข้อมูลที่ใช้ในทุก Output เสมอ (ดู § 22.6 Output Template)
   → เตือนพี่ A ให้ตรวจทานตัวเลขกับ SET/BLS ก่อนตัดสินใจจริงเสมอ

⚠️ นี่คือกรอบการวิเคราะห์เพื่อช่วยคิด ไม่ใช่คำแนะนำการลงทุนที่รับประกันผลลัพธ์
```

---

## § 22.1 · Trigger Keywords

| Keyword | Claude ต้องทำ |
|---------|--------------|
| `"วิเคราะห์หุ้น [TICKER]"` | เริ่ม Full VI Analysis § 22.3 |
| `"ปันผล [TICKER]"` | เน้น DDM + Dividend History |
| `"Valuation [TICKER]"` | คำนวณ 4 วิธี § 22.4 |
| `"Scorecard [TICKER]"` | สรุป /30 คะแนน § 22.5 |
| `"เปรียบเทียบ"` | Peer Comparison Table |
| `"พอร์ต"` | Portfolio Allocation แนะนำ |
| `"ควรขายไหม"` | ไปที่ § 22.9 Exit Criteria (ไม่ใช่ technical-timing) |

---

## § 22.2 · Context — พี่ A's Investment Profile

```
สไตล์    : Value Investing · เน้นปันผล · Long-term Hold
โบรกเกอร์: Bualuang Securities (BLS)
Benchmark: SET100
หุ้นอ้างอิง: PTTEP · OR · PTT · GPSC · PTTGC
ความสนใจ : PTT Group · ปิโตรเคมี · พลังงาน · Conglomerate
เป้าหมาย : Dividend Income + Capital Gain ระยะยาว
```

---

## § 22.3 · VI Analysis Workflow (10 Steps)

```
Step 1  → Business Understanding   ธุรกิจทำอะไร / Moat คืออะไร
Step 2  → Industry & Position      อุตสาหกรรม / ตำแหน่งในตลาด / คู่แข่ง
Step 3  → Financial Health         งบการเงิน 5 ปี (Revenue, Net Profit, D/E)
Step 4  → Profitability            ROE · ROA · Net Margin · EBITDA Margin
Step 5  → Dividend History         DPS ย้อนหลัง 5 ปี · Payout Ratio · Yield
Step 6  → Growth Outlook           แนวโน้มรายได้ · Catalyst · ความเสี่ยง
Step 7  → Valuation (4 วิธี)       DCF · P/E Relative · Graham Number · DDM
Step 8  → Scorecard /30            ให้คะแนนตาม § 22.5
Step 9  → Bualuang-style Summary   สรุปแบบ BLS Research
Step 10 → Portfolio Fit            เข้ากับพอร์ตพี่ A แค่ไหน
```

---

## § 22.4 · Valuation — 4 วิธีพร้อมสูตร

### วิธีที่ 1 — DCF (Discounted Cash Flow)
```
Intrinsic Value = Σ [FCF × (1+g)^t / (1+WACC)^t] + Terminal Value

ค่าที่ใช้ (Thai Market Default):
  WACC      = 8–10%   (ปรับตาม sector risk)
  g (grow)  = 3–5%    (ระยะสั้น 5 ปี)
  Terminal g = 2–3%   (ระยะยาว)
  Margin of Safety = 30% (VI style)
```

### วิธีที่ 2 — P/E Relative
```
Fair Value = EPS × Peer Average P/E

เกณฑ์ SET100:
  P/E ต่ำกว่า 10x   → Undervalued
  P/E 10–15x        → Fair Value
  P/E สูงกว่า 20x   → Expensive
  (เทียบกับ Sector P/E เสมอ)
```

### วิธีที่ 3 — Graham Number
```
Graham Number = √(22.5 × EPS × BVPS)

WHY: Benjamin Graham ใช้ P/E ≤ 15x และ P/BV ≤ 1.5x
     ราคาต่ำกว่า Graham Number = น่าสนใจเชิง VI
```

### วิธีที่ 4 — DDM (Dividend Discount Model)
```
Intrinsic Value = DPS / (r - g)

  DPS = เงินปันผลต่อหุ้นคาดการณ์ปีหน้า
  r   = Required Return (8–10%)
  g   = อัตราการเติบโตปันผล (2–4%)

WHY: เหมาะกับหุ้นปันผลสม่ำเสมอ เช่น PTT Group
```

### สรุป Valuation Range
```
Conservative : ค่าต่ำสุดจาก 4 วิธี
Base Case    : ค่าเฉลี่ย 4 วิธี  ← ใช้เป็นหลัก
Optimistic   : ค่าสูงสุดจาก 4 วิธี

ราคาเป้าหมาย = Base Case × (1 - Margin of Safety 20-30%)
```

---

## § 22.5 · VI Scorecard /30

```
หมวด A: ธุรกิจ & Moat (10 คะแนน)
  [ ] ธุรกิจเข้าใจง่าย เห็นภาพชัด        /2
  [ ] มี Competitive Moat ชัดเจน         /2
  [ ] ตำแหน่งในอุตสาหกรรมแข็งแกร่ง      /2
  [ ] ผู้บริหารน่าเชื่อถือ / Track Record /2
  [ ] ESG / Governance ผ่านเกณฑ์         /2

หมวด B: การเงิน (10 คะแนน)
  [ ] ROE > 10% ต่อเนื่อง 3 ปี           /2
  [ ] D/E < 1.5x (ปิโตรเคมี < 1.0x)     /2
  [ ] Net Margin > 8%                    /2
  [ ] Revenue เติบโต หรือ stable         /2
  [ ] Free Cash Flow เป็นบวก             /2

หมวด C: ปันผล (6 คะแนน)
  [ ] จ่ายปันผลสม่ำเสมอ > 3 ปี           /2
  [ ] Dividend Yield > 4%               /2
  [ ] Payout Ratio 40–70%               /2

หมวด D: Valuation (4 คะแนน)
  [ ] ราคาต่ำกว่า Fair Value ≥ 20%       /2
  [ ] P/E ต่ำกว่า Sector Average         /2

═══════════════════════════════════════
รวม                                    /30

เกณฑ์ตัดสิน:
  25–30 : ✅ น่าสนใจมาก (Strong Buy)
  20–24 : 🟡 น่าติดตาม (Watch)
  < 20  : ❌ ยังไม่น่าลงทุน (Pass)
```

> หมายเหตุ: คะแนนเต็มของ Scorecard นี้คือ **/30** — ถ้าเห็นที่ไหนอ้างอิงเป็น "/35"
> (เช่นใน output ของ `technical-timing`) ให้ถือว่าเป็นค่าที่ผิด แก้เป็น /30 เสมอ

---

## § 22.6 · Output Template — Bualuang Style

```markdown
## 📊 [TICKER] — VI Analysis
**[ชื่อบริษัท]** | SET100 | [Sector]
วันที่วิเคราะห์: [DATE] | ราคาปัจจุบัน: [X.XX] บาท | ข้อมูล ณ วันที่: [DATA_DATE]

---

### 🏭 ธุรกิจ & Moat
[อธิบาย 3–4 บรรทัด: ทำอะไร, รายได้หลักจากไหน, Moat คืออะไร]

### 📈 Financial Snapshot (5 ปีย้อนหลัง)
| ปี | Revenue | Net Profit | Net Margin | ROE | D/E |
|----|---------|------------|------------|-----|-----|
| 25X7 | | | | | |
| 25X6 | | | | | |

### 💰 Dividend History
| ปี | DPS (บาท) | Yield (%) | Payout (%) |
|----|-----------|-----------|------------|

### 🎯 Valuation Summary
| วิธี | มูลค่าที่ได้ |
|------|------------|
| DCF | XX.XX บาท |
| P/E Relative | XX.XX บาท |
| Graham Number | XX.XX บาท |
| DDM | XX.XX บาท |
| **Base Case** | **XX.XX บาท** |
| **ราคาเป้าหมาย (MoS 25%)** | **XX.XX บาท** |

### 📋 VI Scorecard
รวม: XX/30 → [ระดับ]

### 💡 BLS-Style Summary
**Thesis:** [ประโยคเดียวที่อธิบายว่าทำไมถึงน่าสนใจ]

**Catalyst:**
- [จุดที่จะทำให้ราคาขึ้น 1]
- [จุดที่จะทำให้ราคาขึ้น 2]

**Risk:**
- [ความเสี่ยงหลัก 1]
- [ความเสี่ยงหลัก 2]

**คำแนะนำ:** [BUY / HOLD / PASS] ที่ราคา XX.XX บาท
**เป้าหมาย 12 เดือน:** XX.XX บาท ([X]% upside + yield [X]%)
```

---

## § 22.7 · Thai Market Rules & Tax

```
ข้อมูลที่ต้องรู้สำหรับนักลงทุนไทย:

ภาษีเงินปันผล:
  - ภาษีหัก ณ ที่จ่าย 10% (เลือกยื่นรวม หรือไม่ยื่น)
  - กองทุน SSF/RMF ยกเว้นภาษี

ค่าธรรมเนียม Bualuang:
  - หุ้นไทย: 0.15–0.25% (ขึ้นกับ tier)
  - เงินปันผลเข้า port วันที่ XD

SET Structure:
  - SET100   = หุ้นใหญ่ Top 100 (Benchmark พี่ A)
  - mai      = หุ้นขนาดกลาง-เล็ก
  - Sector ปิโตรเคมี: PTTGC, IVL, IRPC, TPC

PTT Group Hierarchy:
  PTT (แม่)
  ├── PTTEP    (สำรวจ+ผลิตปิโตรเลียม) ← Margin ดีสุด
  ├── PTTGC    (ปิโตรเคมี) ← โรงงานพี่ A
  ├── OR       (retail+EV charging)
  ├── GPSC     (ไฟฟ้า)
  └── IRPC     (โรงกลั่น)

Conglomerate Discount:
  WHY: หุ้น Holding มักถูก Discount 15–30% จาก NAV
  → เวลาประเมิน PTT ต้อง Sum-of-Parts แล้วหัก discount
```

---

## § 22.8 · Portfolio Framework — พี่ A Style

```
หลักการ:
  Core Holdings (60–70%)  → หุ้นปันผลสม่ำเสมอ Scorecard ≥ 25/30
  Growth (20–30%)         → Catalyst ชัด upside > 30%
  Watch List (10%)        → รอจังหวะ ราคายังแพง

PTT Group Portfolio แนะนำ (อ้างอิงจากการวิเคราะห์ก่อนหน้า):
  PTTEP  60%  → Net Margin ~21%, D/E ~0.24x, Yield ~8–9%
  PTT    40%  → Yield ~6.5%, Intrinsic ~42–50 บาท

Rebalance:
  → ทุกไตรมาส หรือเมื่อ Weight เบี่ยง > 10%
  → หลัง XD รับปันผล → พิจารณา reinvest

คำเตือน (ห้ามลืม):
  ⚠️ หนูไม่ใช่นักวิเคราะห์การเงิน
  ⚠️ ข้อมูลอาจล้าสมัย ต้องตรวจสอบกับ SET / BLS เสมอ
  ⚠️ ตัดสินใจลงทุนเป็นความรับผิดชอบของพี่ A
```

---

## § 22.9 · Exit Criteria — เมื่อไหร่ควรขาย Core Holding

> **WHY มี section นี้:** `technical-timing` skill อ้างอิงกฎนี้เป็นเหตุผลว่าทำไมห้ามใช้
> Stop Loss แบบเทคนิคกับ Core Holding — เกณฑ์การขายของสาย VI ต้องอิงกับ "thesis พังหรือยัง"
> ไม่ใช่ "ราคาตกแค่ไหน"

### 22.9.1 · หลักการ — Sell on Thesis Broken, Not on Price Drop

```
สาย VI ถือหุ้นเพราะเชื่อ Thesis (เหตุผลที่ลงทุน) ไม่ใช่เพราะคาดเดาราคาระยะสั้น
→ ราคาหุ้นตกเฉยๆ (โดยเฉพาะตกพร้อมตลาดทั้งกระดาน) ไม่ใช่เหตุผลให้ขาย
→ เหตุผลให้ขายคือ "สิ่งที่ทำให้ตัดสินใจซื้อตั้งแต่แรก ไม่จริงอีกต่อไป"
```

### 22.9.2 · Falsification Test

เช็คทีละข้อเทียบกับ Thesis เดิมตอนซื้อ (จาก § 22.6 Output Template ของหุ้นตัวนั้น):

```
[ ] Moat หายไปจริงไหม? (คู่แข่งแย่งส่วนแบ่งตลาดถาวร ไม่ใช่แค่ไตรมาสเดียว)
[ ] ROE/Net Margin ร่วงต่ำกว่าเกณฑ์ Scorecard § 22.5 ต่อเนื่อง ≥ 2 ไตรมาสติดหรือไม่
[ ] มีการตัด/ลดปันผลอย่างมีนัยสำคัญ (ไม่ใช่แค่ผันผวนตามกำไรปกติ) หรือไม่
[ ] D/E พุ่งเกินเกณฑ์อย่างต่อเนื่องจนกระทบความสามารถจ่ายปันผลในอนาคต หรือไม่
[ ] Catalyst ที่เคยระบุไว้ใน Thesis พิสูจน์แล้วว่าไม่เกิดขึ้นจริง/ผิดคาดอย่างสิ้นเชิง หรือไม่
[ ] ผู้บริหาร/Governance มีปัญหาที่กระทบความน่าเชื่อถือระยะยาว หรือไม่

→ ตอบ "ใช่" ตั้งแต่ 1 ข้อขึ้นไปที่มีนัยสำคัญจริง = Thesis พัง → พิจารณาขาย
→ ตอบ "ไม่" ทุกข้อ = Thesis ยังอยู่ → ราคาตกคือโอกาสทยอยเข้าเพิ่ม ไม่ใช่สัญญาณขาย
```

### 22.9.3 · สิ่งที่ *ไม่* นับเป็นเหตุผลขาย

```
❌ ราคาตกพร้อมตลาดทั้งกระดาน (Market-wide sell-off) โดยพื้นฐานบริษัทไม่เปลี่ยน
❌ ข่าวลบระยะสั้นที่ไม่กระทบ Moat/การเงินจริง (noise)
❌ กราฟหลุดแนวรับทางเทคนิค (นั่นคือขอบเขตของ technical-timing ไม่ใช่ vi-analysis)
❌ อยาก take profit เพราะกำไรเยอะแล้ว โดย Thesis เดิมยังไม่พัง (เป็นการตัดสินใจคนละ
   framework กับ VI — ถ้าจะทำ ให้แยกเป็น "Trading Position" ต่างหากจาก Core Holding)
```
