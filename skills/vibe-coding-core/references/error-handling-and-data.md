# Error Handling & Data Reference

> ส่วนหนึ่งของ `vibe-coding-core` — โหลดไฟล์นี้เมื่อทำ error handling หรือเปลี่ยน IndexedDB schema

---

## Error Taxonomy (8 Types)

```
Type 1 — NETWORK      : fetch fail · timeout · offline
Type 2 — AUTH         : token expired · unauthorized · forbidden
Type 3 — STORAGE      : IndexedDB quota · migration fail · corrupt data
Type 4 — SYNC         : Firestore conflict · dead letter · circuit open
Type 5 — AI           : Gemini rate limit · invalid key · hallucination
Type 6 — VALIDATION   : schema mismatch · type error · missing field
Type 7 — RENDER       : DOM error · component crash · null reference
Type 8 — UNKNOWN      : unhandled promise · global error boundary catch

ทุก type ต้อง: log → toast (user-friendly) → audit trail
```

---

## IndexedDB Migration Policy

```javascript
// Migration pattern — เพิ่ม version ทุกครั้งที่ schema เปลี่ยน
const DB_VERSION = 3; // ← เพิ่มทีละ 1 เสมอ

request.onupgradeneeded = (e) => {
  const db = e.target.result;
  const oldVersion = e.oldVersion;

  if (oldVersion < 1) { /* สร้าง store ใหม่ */ }
  if (oldVersion < 2) { /* เพิ่ม index */ }
  if (oldVersion < 3) { /* migrate data */ }
  // WHY: cascade migration — user ข้าม version ได้โดยไม่เสียข้อมูล
};
```
