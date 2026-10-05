# ทดสอบ Single HTML File — วิธีทำงานและวิธีเขียนเพิ่ม

> ส่วนหนึ่งของ `vibe-coding-quality` §25.2 · ของจริงอยู่ที่ `design-lab/starter/tests/`

## harness ทำอะไร

`tests/harness/load-app.mjs` โหลด `index.html` **ตัวจริงที่ deploy** เข้า jsdom แล้วรัน
`<script>` ที่อยู่ในไฟล์ จากนั้นคืน `window` ที่โมดูลทั้ง 9 ผูกอยู่แล้ว

```js
const win = await ready(loadApp());
await mod(win, "STORAGE_ENGINE").put("records", { id: "FI-2104", value: 128.4 });
```

สิ่งที่ harness จัดให้ก่อนสคริปต์เริ่มรัน (`beforeParse`):

| อะไร | ทำไม |
|---|---|
| `indexedDB` = `new IDBFactory()` | IndexedDB จริงในหน่วยความจำ · instance ใหม่ทุกเทสต์ สถานะจึงไม่รั่วข้ามกัน |
| `matchMedia` ปลอม | คุมได้ว่า "ระบบตั้งธีมมืดอยู่" หรือไม่ — ไม่งั้นทดสอบธีม 3 สถานะไม่ได้ |
| `localStorage` ปลอม | ตั้งค่าที่ค้างอยู่ก่อนเปิดหน้าได้ · และจำลองโหมดส่วนตัวที่โยน error ได้ |
| `fetch` ที่ reject เสมอ | เทสต์ที่ผลขึ้นกับว่าเน็ตขึ้นหรือไม่ คือเทสต์ที่เชื่อไม่ได้ |

`runScripts: "dangerously"` รันเฉพาะ `<script>` ที่อยู่ในไฟล์ — jsdom ไม่ไปดึง `src` ภายนอกอยู่แล้ว
แท็ก Tailwind/Chart.js จาก CDN จึงถูกข้ามเงียบๆ เทสต์ทำงานออฟไลน์และเร็ว

## ตัวเลือกของ `loadApp()`

| ตัวเลือก | ใช้ทำอะไร |
|---|---|
| `theme: "dark"` | จำลองว่าระบบตั้งธีมมืด |
| `savedTheme: "dark"` | จำลองว่าผู้ใช้เคยเลือกธีมไว้แล้ว |
| `localStorageThrows: true` | จำลองโหมดส่วนตัว |
| `search: "?debug=1"` | เปิด DEBUG_MODULE |
| `idb: newIDB()` | ใช้ IndexedDB ก้อนเดิมข้ามการโหลด — **เงื่อนไขเดียวที่ทดสอบ migration ได้** |
| `transform: (html) => ...` | แก้ข้อความใน HTML ก่อนโหลด เช่นจำลอง bump `DB_VERSION` โดยไม่ต้องแตะไฟล์จริง |

## เขียนเทสต์ใหม่ — 3 คำถามก่อนเขียน

1. **กฎนี้เขียนไว้ที่ไหนแล้วหรือยัง** — ถ้ามีใน §8/§16 อยู่แล้วแต่ไม่มีอะไรบังคับ นั่นคือ
   ผู้สมัครที่ดีที่สุด (เทสต์ XSS คือแม่แบบ)
2. **มันควรอยู่ชั้นไหน** — ต้องดู layout/สี/ขนาดจริงไหม? ถ้าใช่ต้องเป็น e2e เท่านั้น
   ถ้าไม่ ให้อยู่ unit เพราะเร็วกว่า ~50 เท่า
3. **ทำอะไรให้มันแดง** — ถ้าตอบไม่ได้ แปลว่ายังไม่รู้ว่ากำลังทดสอบอะไร

## กับดักที่เจอมาแล้วจริง (อย่าทำซ้ำ)

**1. เทสต์ที่เทียบของสองอย่างที่มาจากแหล่งเดียวกัน**
เคยเขียนว่า `objectStoreNames` ต้องเท่ากับ `APP_CONFIG.STORES` — ลบ store ออกจาก config
แล้วเทสต์ยังผ่าน เพราะ DB ก็สร้างตาม config นั้น สองฝั่งหดตามกัน
→ แทนด้วยเทสต์ที่มีเงื่อนไขจากภายนอก: bump `DB_VERSION` แล้วข้อมูลเดิมต้องอยู่ครบ

**2. `el.focus()` ไม่ทำให้ `:focus-visible` ทำงาน**
`:focus-visible` match เฉพาะการโฟกัสด้วยคีย์บอร์ด → ต้องใช้ `page.keyboard.press("Tab")`
และต้องเทียบ "ก่อนโฟกัส vs หลังโฟกัส" ด้วย ไม่งั้นชิ้นที่มี `box-shadow` ติดตัวอยู่แล้วจะผ่านฟรี

**3. request ไปเน็ตภายนอกทำให้ e2e ช้าขึ้นเทสต์ละ ~13 วินาที**
ปล่อยให้ request ฟอนต์ค้างจนหมดเวลา = ชุดเทสต์ 3 นาที 18 วินาที
บล็อกทั้งหมดใน `test.beforeEach` = 9 วินาที และได้ผลพลอยได้เป็นการพิสูจน์ว่าแอปใช้ได้ตอนออฟไลน์

**4. แยก "ไฟล์ของเราพัง" ออกจาก "CDN ข้างนอกเข้าไม่ถึง"**
ถ้าให้ CDN ที่เข้าไม่ถึงทำ CI แดง สุดท้ายจะโดนปิดเทสต์ทิ้งทั้งชุด ซึ่งแย่กว่า
→ fail เฉพาะ request ที่เป็น origin ของแอปเอง · third-party รายงานเป็น annotation

**5. `const` ฆ่า harness เงียบๆ**
เปลี่ยน `var MODULE` เป็น `const MODULE` แล้วแอปยังทำงานปกติทุกอย่าง แต่โมดูลหลุดจาก `window`
→ `mod(win, "NAME")` จึงมีข้อความบอกสาเหตุนี้ไว้โดยเฉพาะ แทนที่จะโยน `undefined is not an object`

## ผลการลองจริงกับแอปของพี่ A (2026-09-02)

สำรวจแอปจริง ~10 ตัวเพื่อหาตัวมาทดสอบ harness พบภาพที่ชัดเจน:

| กลุ่มแอป | ลักษณะ | ตัวอย่าง |
|---|---|---|
| ย้ายไป Vite/ES-Modules แล้ว | `<script type="module" src="/src/main.js">` — มี `import`/`export` จริง | Monitor-log-sheet-boardman (Plant Log Analyzer — มี Vitest 146 เทสต์อยู่แล้ว ผ่านหมด), Monitor-Quality-PTA, IPS-Auto-Update |
| Single HTML File เก่าก่อนมาตรฐาน 9-module | โค้ดทั้งหมดอยู่ใน `document.addEventListener('DOMContentLoaded', () => {...})` — ไม่มีอะไรหลุดออกมาที่ `window` เลย ไม่ว่าจะ `var` หรือ `const` | Log-EQ-history, Dog-feeding-tracker, RAW-to-PV |
| React/Vite scaffold | `<div id="root"></div>` + `main.jsx` | ToDo-list- |

**ไม่มีแอปจริงตัวไหนใช้ `var MODULE = (function(){})()` แบบ 9-module เป๊ะๆ เลย** — เหตุผลตรงไปตรงมา: pattern นี้เพิ่งกลายเป็นมาตรฐานตอน Supasit.A Studio รอบที่ 4 (ปลายสิงหาคม 2569) ส่วนแอปจริงถูกสร้างก่อนหน้านั้นด้วยสไตล์ที่ต่างกันไปเรื่อยๆ ตามยุค — **นี่ไม่ใช่เรื่องผิดปกติ เป็นเรื่องคาดหมายได้**

### โหมดที่ 2 — DOM-driven (สำหรับแอปเก่าที่ไม่มีอะไรหลุดออกมาที่ window)

ทดสอบจริงกับ `Log-EQ-history` (796 บรรทัด, โค้ดทั้งหมดอยู่ในปิด DOMContentLoaded) — `mod(win, "NAME")`
ใช้ไม่ได้เลยเพราะไม่มีชื่อโมดูลให้ดึง แต่ **jsdom ยังทำงานกับแอปสไตล์นี้ได้เต็มรูปแบบ** แค่เปลี่ยนวิธี
ทดสอบจาก "เรียกโมดูลตรงๆ" เป็น "จำลองคลิกแล้วดู DOM":

```js
// ไม่มี mod(win, "STORAGE_ENGINE") ให้เรียก แต่คลิกปุ่มจริงแล้วดู DOM ได้ปกติ
const win = await ready(loadApp({ file: "index.html" })); // แอปเก่าไม่จำเป็นต้องมีโมดูล
const modal = win.document.getElementById("manager-modal");
expect(modal.hidden).toBe(true); // ปิดอยู่ก่อนคลิก

win.document.getElementById("open-manager-btn")
  .dispatchEvent(new win.MouseEvent("click", { bubbles: true }));
await new Promise((r) => setTimeout(r, 50)); // ให้ event handler แบบ async ทำงานจบ

expect(modal.hidden).toBe(false); // เปิดจริงหลังคลิก — พิสูจน์แล้วบนแอปจริง
```

**หลักการเลือกโหมด:**

| แอปแบบไหน | ใช้โหมดไหน |
|---|---|
| ใหม่ ตาม starter ปัจจุบัน (`var MODULE = ...`) | โหมด 1 — เรียกโมดูลตรงๆ ผ่าน `mod(win, "NAME")` |
| เก่า ก่อนมาตรฐาน 9-module (ไม่มีอะไรหลุดถึง window) | โหมด 2 — DOM-driven: หา element ด้วย id, จำลองคลิก, เช็คว่า DOM เปลี่ยนตามที่ควร |
| ไม่แน่ใจ | รัน `Object.keys(win).filter(k => /^[A-Z]/.test(k))` ดูว่ามีอะไรหลุดออกมาไหม ถ้าไม่มีเลย ให้ใช้โหมด 2 |

ข้อดีของโหมด 2: **ทดสอบพฤติกรรมที่ผู้ใช้เห็นจริง** ไม่ขึ้นกับว่าโค้ดข้างในเขียนแบบไหน — ใช้ได้กับ
แอปเก่าทุกยุคโดยไม่ต้อง refactor อะไรเลยเหมือนกับโหมด 1

## ย้าย harness ไปใช้กับแอปเดิม

```bash
cp -r design-lab/starter/tests design-lab/starter/tools \
      design-lab/starter/package.json design-lab/starter/vitest.config.mjs \
      design-lab/starter/playwright.config.mjs <โฟลเดอร์แอปเดิม>/
cd <โฟลเดอร์แอปเดิม> && npm ci && npm test
```

ที่มักสะดุดตอนไปเจอแอปจริง เรียงตามความถี่ที่คาดไว้:

1. โมดูลประกาศเป็น `const` → harness จะบอกเองพร้อมวิธีแก้
2. โค้ดเรียก global จาก CDN (`Chart`, `lucide`) ตอน init → เพิ่ม stub ใน `beforeParse`
3. เรียก API เบราว์เซอร์ที่ jsdom ไม่มี (`ResizeObserver`, `IntersectionObserver`)
   → เพิ่ม stub ใน `beforeParse` เช่นกัน
4. `APP_CORE.init()` ยิง network ตอนเปิด → `fetch` ที่ reject จะทำให้เห็นทันทีว่าไม่ได้ดัก error

**อย่าเริ่มจาก starter ที่สะอาดแล้วสรุปว่าใช้ได้** — ลองกับแอปที่ใช้งานจริงมากที่สุดก่อนเสมอ
