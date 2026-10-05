/* 6 · DEBUG_MODULE — เปิดด้วย ?debug=1 เท่านั้น production จึงเงียบสนิท
   แต่ ring buffer เก็บ log ไว้เสมอ เพื่อให้ปุ่ม "รายงานปัญหา" มีอะไรให้แนบ
   ตอนนี้ persist ผ่าน STORAGE_ENGINE ที่มีอยู่แล้ว (ไม่เปิด IndexedDB เส้นที่สอง)
   เพื่อให้ log คงอยู่ข้าม reload — ยังต้องกดปุ่มรายงานปัญหาเองเหมือนเดิม
   ไม่มีอะไรถูกส่งออกไปนอกเครื่องอัตโนมัติ */
import { StorageEngine } from "./storage-engine.js";

const STORE = "debugLog";
const RING_ID = "ring";
const MAX = 20; /* เก็บแค่ 20 รายการล่าสุด — พอให้ debug ไม่กินหน่วยความจำ */
let ring = [];

function on() {
  return new URLSearchParams(location.search).get("debug") === "1";
}

function persist() {
  StorageEngine.put(STORE, { id: RING_ID, entries: ring, updatedAt: Date.now() }).catch(
    () => {} /* log ต้องไม่มีวันทำแอปพัง แม้ IndexedDB จะเขียนไม่ได้ */
  );
}

function log(...args) {
  ring.push(`${new Date().toISOString().slice(11, 19)} ${args.join(" ")}`);
  if (ring.length > MAX) ring.shift();
  if (on()) console.log(...args);
  return persist(); /* คืน promise ไว้ให้เทสต์ await ได้ — ผู้เรียกจริงไม่ต้อง await */
}

function hydrate() {
  return StorageEngine.get(STORE, RING_ID)
    .then((rec) => {
      const persisted = (rec && rec.entries) || [];
      /* merge ไม่ใช่ replace — กัน race กับ log() ที่เกิดระหว่าง init() เดียวกัน */
      ring = persisted.concat(ring).slice(-MAX);
    })
    .catch(() => {});
}

export const DebugModule = {
  log,
  hydrate,
  recent: () => ring.slice(),
  version() {
    const m = document.querySelector('meta[name="app-version"]');
    return m ? m.content : "dev";
  }
};
