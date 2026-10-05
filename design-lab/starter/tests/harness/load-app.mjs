/**
 * โหลด index.html ตัวจริงเข้า jsdom แล้วคืน window ที่รันสคริปต์ในหน้าเสร็จแล้ว
 *
 * ทำไมต้องทดสอบ "ไฟล์ที่ deploy จริง" ไม่ใช่โค้ดที่คัดลอกออกมา:
 * มาตรฐาน Supasit.A คือ Single HTML File — ถ้าแยก logic ออกไปอีกไฟล์เพื่อให้ import ได้
 * สิ่งที่เทสต์ผ่านจะไม่ใช่สิ่งที่ผู้ใช้เปิด และไม่มีใครสังเกตเห็นตอนมัน drift ออกจากกัน
 *
 * ข้อจำกัดที่ต้องรู้: jsdom ไม่มี layout engine และไม่มี CSS cascade จริง
 * → contrast · เป้าแตะ 44px · horizontal scroll · focus ring · service worker
 *   ทดสอบที่นี่ไม่ได้ ต้องไปที่ tests/e2e (Playwright) เท่านั้น
 */

import { readFileSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { JSDOM } from "jsdom";
import { IDBFactory, IDBKeyRange } from "fake-indexeddb";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "../..");

/**
 * สร้าง IndexedDB ก้อนใหม่ — ส่งก้อนเดิมกลับเข้า loadApp({ idb }) ได้
 * เพื่อจำลอง "ผู้ใช้คนเดิมเปิดแอปเวอร์ชันใหม่" ซึ่งเป็นเงื่อนไขเดียวที่ทดสอบ
 * migration ของ DB_VERSION ได้จริง
 */
export const newIDB = () => new IDBFactory();

export function loadApp(opts = {}) {
  const {
    file = "index.html",
    theme = "light",
    savedTheme = null,
    localStorageThrows = false,
    search = "",
    idb = null,
    /** แก้ข้อความใน HTML ก่อนโหลด — ใช้จำลองการแก้โค้ดโดยไม่ต้องแตะไฟล์จริง */
    transform = null
  } = opts;

  const store = new Map();
  if (savedTheme) store.set("app:theme", savedTheme);

  let html = readFileSync(resolve(ROOT, file), "utf8");
  if (transform) html = transform(html);

  const dom = new JSDOM(html, {
    url: "https://app.test/" + search,
    /* รันเฉพาะ <script> ที่อยู่ในไฟล์ — jsdom ไม่ไปดึง src ภายนอกอยู่แล้ว
       เทสต์จึงทำงานออฟไลน์และไม่ขึ้นกับว่า CDN ล่มหรือเปล่า */
    runScripts: "dangerously",
    pretendToBeVisual: true,
    beforeParse(window) {
      /* IndexedDB ของจริงในหน่วยความจำ — ปกติสร้างใหม่ทุกครั้ง เทสต์จึงไม่ปนกัน
         ส่ง idb เข้ามาเมื่อจงใจอยากให้ข้อมูลอยู่ข้ามการโหลด (เทสต์ migration) */
      window.indexedDB = idb || new IDBFactory();
      window.IDBKeyRange = IDBKeyRange;
      window.structuredClone = structuredClone;

      window.matchMedia = (q) => ({
        matches: theme === "dark" && q.includes("dark"),
        media: q,
        onchange: null,
        addEventListener() {},
        removeEventListener() {},
        addListener() {},
        removeListener() {},
        dispatchEvent: () => false
      });

      if (localStorageThrows) {
        Object.defineProperty(window, "localStorage", {
          configurable: true,
          get() {
            throw new DOMException("localStorage ถูกปิดในโหมดส่วนตัว", "SecurityError");
          }
        });
      } else {
        Object.defineProperty(window, "localStorage", {
          configurable: true,
          value: {
            getItem: (k) => (store.has(k) ? store.get(k) : null),
            setItem: (k, v) => store.set(k, String(v)),
            removeItem: (k) => store.delete(k),
            clear: () => store.clear()
          }
        });
      }

      /* ปิดเน็ตโดยตั้งใจ — เทสต์ที่ต้องพึ่ง network คือเทสต์ที่เชื่อถือไม่ได้ */
      window.fetch = () => Promise.reject(new Error("network ถูกปิดในเทสต์"));
    }
  });

  return dom.window;
}

/** รอจนสคริปต์ในหน้ารันเสร็จ (DOMContentLoaded → APP_CORE.init) */
export function ready(win) {
  return new Promise((res) => {
    if (win.document.readyState === "complete") res(win);
    else win.addEventListener("load", () => res(win));
  });
}

/**
 * ดึงโมดูลออกมา พร้อมข้อความบอกสาเหตุที่ชัดเจนเมื่อหาไม่เจอ
 *
 * เหตุผลที่ต้องมีฟังก์ชันนี้: ตอนเอา harness ไปใช้กับแอปเดิม สาเหตุที่พังบ่อยที่สุด
 * คือมีคนเปลี่ยน `var MODULE = ...` เป็น `const MODULE = ...` — const ที่ top-level
 * ไม่ผูกกับ window ทำให้เทสต์มองไม่เห็น ทั้งที่แอปยังทำงานปกติทุกอย่าง
 * ถ้าไม่บอกไว้ตรงนี้ จะเสียเวลาไล่หาสาเหตุนานมาก
 */
export function mod(win, name) {
  const m = win[name];
  if (m === undefined) {
    const found = Object.keys(win).filter((k) => /^[A-Z][A-Z_]{2,}$/.test(k));
    throw new Error(
      `ไม่พบโมดูล ${name} บน window\n` +
        `  · ถ้าแอปประกาศเป็น "const ${name} = ..." ให้เปลี่ยนเป็น "var ${name} = ..."\n` +
        `    (const ที่ top-level ไม่ผูกกับ window — แอปยังทำงานได้ แต่เทสต์มองไม่เห็น)\n` +
        `  · <script type="module"> ก็ไม่ผูกกับ window เช่นกัน\n` +
        `  · โมดูลที่หน้านี้มีจริง: ${found.join(", ") || "(ไม่พบเลย)"}`
    );
  }
  return m;
}
