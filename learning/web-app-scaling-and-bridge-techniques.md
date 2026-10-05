# เทคนิคแก้ปัญหา Web App โต + เชื่อมกับระบบ local (Excel/Filesystem)

> รวบรวมจากบทสนทนาจริงกับ Claude — วันที่ 2026-08-11 ระหว่างทำโปรเจกต์ Plant Log Analyzer (`D:\Monitor log sheet boardman`) แก้ปัญหา performance ตอนข้อมูลสะสมหลายวัน + ต่อยอด Excel Bridge ให้ auto-import/auto-archive เอง — เทคนิคพวกนี้ใช้ได้กับโปรเจกต์ Vibe Coding อื่นที่มี pattern คล้ายกัน (local-first IndexedDB, ต้องคุยกับ Excel/ไฟล์บนเครื่อง)

---

## 1. แยก "คำนวณข้อมูลใหม่" ออกจาก "กรอง/เรียงเพื่อแสดงผล"

**ปัญหาที่เจอ:** ฟังก์ชันเดียว (`STATE._deriveAbnormal`) ทำ 2 งานรวดเดียว — คำนวณ flag ที่หนัก (ต้อง loop ทุก record) + กรอง/เรียงเพื่อโชว์ผล — ทำให้ทุกครั้งที่ผู้ใช้แค่คลิกเปลี่ยน filter (ไม่ได้แก้ข้อมูลเลย) ก็คำนวณ flag ใหม่หมดทั้งชุดโดยไม่จำเป็น ยิ่งข้อมูลสะสมเยอะยิ่งหน่วง

**วิธีแก้ที่ใช้ได้ทั่วไป:** แยกเป็น 2 phase ชัดเจน แล้วให้ trigger ต่างกัน:
- **Phase คำนวณ (หนัก)** — รันเฉพาะตอน "ข้อมูลต้นทางเปลี่ยนจริง" (import ใหม่, แก้ limit/config)
- **Phase กรอง/เรียง (เบา)** — รันได้ทุกครั้งที่ user เปลี่ยนมุมมอง (filter, sort, search) โดยใช้ผลจาก phase คำนวณล่าสุด ไม่ต้องคำนวณซ้ำ

**สัญญาณที่บอกว่าโปรเจกต์อื่นน่าจะมีปัญหาแบบนี้:** ฟังก์ชันที่ผูกกับ state-change event เดียวแต่ทำงานหลายอย่างไม่สัมพันธ์กัน (compute + filter + sort ในฟังก์ชันเดียว) — ให้เช็คว่า trigger ไหนจริงๆ ต้องการ "คำนวณใหม่" กับ trigger ไหนแค่ต้องการ "แสดงผลใหม่จากของเดิม"

---

## 2. Bound การ render ที่โตไม่รู้จบ (ไม่ใช่แค่ cap จำนวน — คิดเรื่อง UX ที่ยังเข้าถึงของเก่าได้ด้วย)

แถบ "Time Breakdown" สร้างปุ่ม 1 อันต่อ 1 timestamp ที่เคย import โดยไม่มี cap — พอสะสมหลายเดือนกลายเป็นปุ่มเป็นร้อย ทำ 2 อย่างพร้อมกัน:
- Default โชว์แค่ N รายการล่าสุด (constant ตั้งชื่อชัดเจน เช่น `DEFAULT_TIME_BREAKDOWN_DAYS`)
- ของเก่ากว่านั้น**ไม่ทิ้ง** แค่ย้ายไปอยู่หลัง dropdown/control แยก ที่ query แบบ lazy (สร้าง option ตอนเปิดเท่านั้น ไม่ต้อง render ทุกครั้ง)

หลักคิด: การจำกัดการแสดงผลไม่ควรแปลว่า "ข้อมูลเก่าเข้าถึงไม่ได้อีกแล้ว" — แค่ทำให้ทางเข้าถึงของเก่าเป็น opt-in แทน default

---

## 3. IndexedDB schema migration แบบปลอดภัย (รองรับทั้ง fresh install และ upgrade จากเวอร์ชันเก่า)

เพิ่ม index ใหม่ในระบบที่มี user ใช้อยู่แล้วจริง (ห้ามสมมติว่าทุกคนเริ่มจาก DB ว่าง) — pattern ที่ปลอดภัย:

```js
let store;
if (!db.objectStoreNames.contains(NAME)) {
    store = db.createObjectStore(NAME, { keyPath: 'id' }); // fresh install
} else {
    store = e.target.transaction.objectStore(NAME); // upgrade จากเวอร์ชันเก่า
}
if (!store.indexNames.contains('newIndex')) {
    store.createIndex('newIndex', 'newIndex', { unique: false });
}
```

Guard ด้วย `indexNames.contains`/`objectStoreNames.contains` ทุกจุด กัน error ตอน migration รันซ้ำ (เช่น user เปิดหลาย tab พร้อม upgrade) — และเลือก field ที่จะทำ index ให้เป็น**ตัวเลข sortable จริง** (เช่น epoch timestamp) ไม่ใช่ string แสดงผล (เช่น "DD/MM/YYYY") ที่ sort ผิดถ้าเทียบตรงๆ

---

## 4. เว็บแอปต้องคุยกับ Excel/ไฟล์บนเครื่อง → สร้าง "Local Bridge" เอง อย่าฝืน browser sandbox

**บริบท:** browser sandbox ห้ามเว็บแอปอ่าน/เขียนไฟล์ในเครื่องหรือคุมโปรแกรม desktop โดยตรง (ตั้งใจ ป้องกันเว็บอันตราย) ถ้าโปรเจกต์ต้องเชื่อมกับ Excel/ไฟล์จริงที่มี state ซับซ้อน (สูตรเชื่อม live data, ต้องเปิดโปรแกรมเดิมอยู่) มี 2 ทางหลัก:

| ทาง | ใช้เมื่อ | ข้อจำกัด |
|---|---|---|
| **File System Access API** (`showDirectoryPicker()`) | ต้องการ auto บ้าง ยอมรับ popup ขอสิทธิ์ 1 ครั้ง/session ได้ | Chrome/Edge เท่านั้น ไม่ fully silent |
| **Local Bridge** (โปรแกรมเล็กรันบนเครื่อง user เอง คุยกับเว็บผ่าน `localhost` HTTP) | ต้องการอัตโนมัติเต็มรูปแบบ ไม่มี popup เลย, ต้องคุมโปรแกรม desktop จริง (COM automation) | ต้องมีโปรแกรมรันค้างไว้ตลอด (ตั้ง autostart ผ่าน Task Scheduler ได้) |

**Pattern ของ Local Bridge ที่ใช้ได้ซ้ำ** (ในโปรเจกต์นี้คือ PowerShell + `System.Net.HttpListener`, ภาษาอื่นก็ใช้หลักการเดียวกันได้):

- เช็ค `Origin` header กับ allow-list ก่อนประมวลผลทุก request เสมอ (กันเว็บอื่นแอบยิง request มาที่ bridge บนเครื่องเดียวกัน) — request ที่ไม่มี Origin header (curl/script local) อนุโลมผ่านได้ เพราะเว็บอื่นทำแบบนั้นไม่ได้อยู่แล้ว
- **Path ที่ bridge จะอ่าน/เขียนไฟล์ ต้องตั้งค่าไว้ในตัวสคริปต์เอง ห้ามรับจากฝั่งเบราว์เซอร์เด็ดขาด** แม้จะดูสะดวกกว่าก็ตาม — ถ้ารับ path จาก request จะกลายเป็นช่องโหว่ให้เว็บไหนก็ได้ (ที่ผ่าน origin check ได้ หรือแม้แต่ script อื่นบนเครื่อง) สั่งอ่าน/เขียนไฟล์ตามใจ
- Response ทุก route ใช้ envelope เดียวกันเสมอ (เช่น `{status: 'ok'|'error'|...}`) ยกเว้นกรณีตั้งใจส่ง binary/ไฟล์จริง (ต้อง document ให้ชัดว่า route ไหนพิเศษ และฝั่ง client ต้องเช็ค `Content-Type` ก่อนตัดสินใจ parse แบบไหน)
- ฝั่ง client (JS) ที่คุยกับ bridge: **คืนเป็น status string/object เสมอ ไม่ throw** — bridge ไม่ได้เปิดอยู่เป็นสถานะปกติที่ต้องรองรับเงียบๆ ไม่ใช่ error รุนแรงที่ต้อง alert ผู้ใช้ทุกครั้ง ใส่ timeout (`AbortController`) กันค้างถ้า bridge ไม่ตอบ

---

## 5. อ่านไฟล์ที่โปรแกรมอื่นอาจกำลังเขียนอยู่พร้อมกัน (sharing violation)

ถ้าไฟล์เป้าหมายถูกโปรแกรมอื่นเปิด/เขียนสด (เช่น Excel + PI Datalink refresh ตามเวลา) การอ่านไฟล์แบบปกติเสี่ยงชน error ช่วงสั้นๆ ตอนโปรแกรมนั้น save:

- เปิดไฟล์แบบระบุ sharing mode เอง (.NET: `FileShare.ReadWrite`) แทนฟังก์ชันอ่านไฟล์ทั่วไปที่เลือก sharing mode ไม่ได้ — เพิ่มโอกาสอ่านสำเร็จแม้มีโปรแกรมอื่นเปิดพร้อมกัน
- ดัก error code เฉพาะเจาะจง (Windows sharing violation = HRESULT `0x80070020` / `-2147024864`) แล้วแปลงเป็นสถานะที่ caller เข้าใจ (เช่น `'file-locked'`) แทนที่จะโยน exception ดิบ
- **ไม่ต้องมี retry logic ซับซ้อน** ถ้า caller เป็นระบบที่ poll ซ้ำอยู่แล้วเป็นระยะ (เช่นทุก 5 นาที) — แค่คืนสถานะ `file-locked` แล้วปล่อยให้รอบถัดไปลองใหม่เองพอ ประหยัดโค้ดกว่าเขียน retry-with-backoff เอง

---

## 6. ก่อนออกแบบระบบอัตโนมัติ ต้องถามจน "รู้ routine จริง" ไม่ใช่แค่ "โจทย์ที่ตั้งไว้ตอนแรก"

โจทย์เริ่มต้น ("ให้ Web App ไปดึงไฟล์ Excel จาก D: เอง") ถ้าออกแบบตามนั้นตรงๆ จะผิดตั้งแต่ต้น — พอถามรายละเอียดจริงถึงเจอว่า:
- ไม่มีไฟล์ใหม่ทุกวัน มีไฟล์เดียวที่ผู้ใช้เปลี่ยนชื่อ/วันที่เองรายวัน (ไม่ใช่ pattern "ไฟล์ใหม่มาถึง" แต่เป็น "ไฟล์เดิมถูกแก้สด")
- มี routine เช็คความครบถ้วนด้วยตา (4 รอบเวลา/วัน) ที่ระบบช่วยแทนได้ดีกว่า
- ปลายทางที่ผู้ใช้พูดถึงตอนแรก ("เก็บไว้ที่ D:") จริงๆ คือคนละที่กับที่ทำอยู่จริง (SharePoint) — ถ้าไม่ถามซ้ำจะไปทำงานผิด scope (ต่อ SharePoint API ซึ่งใหญ่กว่ามาก ต้องขอสิทธิ์ IT)

**บทเรียน:** งานที่เกี่ยวกับ "automate สิ่งที่คนทำมือทุกวัน" ต้องขอให้ผู้ใช้เล่า routine จริงทีละขั้นตอนก่อนเริ่มออกแบบเสมอ ไม่ใช่ design จากประโยคเดียวที่บรรยายไว้ตอนแรก — คำถามที่ช่วยได้: "ตอนนี้ทำแบบนี้ทุกวันยังไงบ้าง ทีละขั้นตอน" แล้วเทียบ automation ที่เสนอกับ routine จริงทุกขั้น ไม่ใช่แค่ขั้นที่พูดถึงตอนแรก

---

## 7. เขียนขอบเขต "อยู่ในรอบนี้ / ตั้งใจไม่ทำรอบนี้" ลงในแผนตรงๆ

พอเจอว่างานจริงมีส่วนที่ใหญ่กว่าที่ขอมาก (เช่น SharePoint API integration) — แทนที่จะทำทั้งหมดหรือเงียบๆ ตัดทิ้ง ให้เสนอแยก scope ชัดเจนพร้อมเหตุผล (เช่น "ต้องขอสิทธิ์ IT ก่อน ควรแยกเป็นโปรเจกต์ต่างหาก") แล้วให้ผู้ใช้เลือกเอง — เขียนทั้ง 2 ฝั่งไว้ในเอกสารแผนงานตรงๆ ("ขอบเขตที่ตกลงกันแล้ว" / "นอกขอบเขตรอบนี้ (เจตนา)") กันงานลามหรือถูกเข้าใจผิดว่าลืมทำ

---

## 8. เข้าถึง private GitHub repo ได้แม้ WebFetch/API ใช้ไม่ได้ — ใช้ `git` CLI ตรงๆ

`WebFetch`/GitHub REST API ไม่มี auth ติดไปด้วย เจอ 404 กับ private repo เสมอ แต่ `git` ผ่าน credential ที่แคชไว้ในเครื่อง (Windows Credential Manager) ใช้ได้ปกติ — เช็คก่อนด้วย `git ls-remote <url>` (read-only, ไม่ต้อง clone) ถ้าเข้าได้ ค่อย shallow-clone มาดูของจริง:

```bash
git clone --no-checkout --filter=blob:none <url> <dest>   # ไม่ดึง blob/checkout ก่อน ประหยัดเวลา
cd <dest> && git fetch origin main <other-branch>
git show origin/main:path/to/file                          # อ่านไฟล์เดียวโดยไม่ checkout ทั้ง repo
git ls-tree -r --long origin/main -- path/                 # list ไฟล์/ขนาดในโฟลเดอร์ ไม่ต้อง checkout
```

เช็ค branch อื่นที่ไม่ใช่ `main` ด้วยเสมอถ้าชื่อ branch สื่อว่าเกี่ยวข้อง (เช่น `claude/xxx-mockup-designs`) — บาง repo เนื้อหาจริงที่ต้องการอยู่ branch draft ที่ยังไม่ merge ไม่ใช่ `main`

---

## 9. ใช้ Explore/Plan subagent สำรวจ+ออกแบบ ก่อนเขียนโค้ดจริงในงานที่มีหลายจุดเชื่อมกัน

งานที่แตะหลายไฟล์/หลาย layer พร้อมกัน (state management + IndexedDB + UI + external script) เสี่ยงพลาดจุดเชื่อมที่มองไม่เห็นถ้าอ่านทีละไฟล์เอง — วิธีที่ช่วยได้จริงในเซสชันนี้:
1. ยิง Explore agent หลายตัวคู่ขนาน (คนละหัวข้อ ไม่ทับกัน) ให้รายงานกลับมาเป็น **fact ที่มี line number/exact behavior** ไม่ใช่บทสรุปกว้างๆ
2. เอา fact ที่ได้ทั้งหมดไปสรุปเป็น brief ให้ Plan agent ออกแบบ implementation จริง (ชื่อฟังก์ชัน, ตำแหน่งไฟล์, edge case) แทนที่จะออกแบบเองจากความจำ
3. Plan agent ที่ดีจะ**คืน "judgment call" ที่ต้องเลือก** แยกออกมาให้เห็นชัด (ไม่ตัดสินใจเงียบๆ) — เอาไปให้ user confirm หรือเลือก default ที่ปลอดภัยไว้ในแผนเลย
