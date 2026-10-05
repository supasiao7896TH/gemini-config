/**
 * Contract suite — ทุกแอปที่ scaffold จาก starter ได้ชุดนี้ไปฟรี ไม่ต้องเขียนเอง
 *
 * เกณฑ์การเลือกว่าอะไรควรอยู่ในนี้: ต้องเป็นกฎที่ skill เขียนไว้เป็น "ร้อยแก้ว" อยู่แล้ว
 * แต่ไม่เคยมีอะไรบังคับ — เทสต์แปลงมันให้ทำให้ build แดงได้
 */

import { describe, it, expect } from "vitest";
import { loadApp, ready, mod, newIDB } from "../harness/load-app.mjs";

describe("STORAGE_ENGINE — IndexedDB", () => {
  it("สร้าง object store ครบตามที่ APP_CONFIG.STORES ประกาศไว้", async () => {
    const win = await ready(loadApp());
    const cfg = mod(win, "APP_CONFIG");
    const db = await mod(win, "STORAGE_ENGINE").open();
    expect(cfg.STORES.length).toBeGreaterThan(0);
    expect([...db.objectStoreNames].sort()).toEqual([...cfg.STORES].sort());
  });

  /* ความเสี่ยงจริงที่ error taxonomy ระบุไว้ (STORAGE type-3 "migration fail")
     migration เป็น forward-only ไม่มี down-migration ถ้าเพิ่ม store ตอน bump version
     แล้วเขียน onupgradeneeded ผิด ข้อมูลของผู้ใช้จะหายโดยไม่มีใครรู้จนกว่าจะสาย */
  it("bump DB_VERSION + เพิ่ม store ใหม่ แล้วข้อมูลเดิมต้องอยู่ครบ", async () => {
    const shared = newIDB();

    const v1 = await ready(loadApp({ idb: shared }));
    await mod(v1, "STORAGE_ENGINE").put("records", { id: "เก็บไว้นะ", value: 42 });

    /* จำลองแอปเวอร์ชันถัดไป: DB_VERSION 2 → 3 และเพิ่ม store "audit" */
    const v2 = await ready(
      loadApp({
        idb: shared,
        transform: (html) =>
          html
            .replace("DB_VERSION: 2", "DB_VERSION: 3")
            .replace(
              'STORES: ["records", "settings", "debugLog"]',
              'STORES: ["records", "settings", "debugLog", "audit"]'
            )
      })
    );

    const db2 = await mod(v2, "STORAGE_ENGINE").open();
    expect([...db2.objectStoreNames]).toContain("audit");
    const kept = await mod(v2, "STORAGE_ENGINE").get("records", "เก็บไว้นะ");
    expect(kept).toEqual({ id: "เก็บไว้นะ", value: 42 });
  });

  it("put → get คืนข้อมูลเดิมครบถ้วน", async () => {
    const win = await ready(loadApp());
    const S = mod(win, "STORAGE_ENGINE");
    await S.put("records", { id: "FI-2104", value: 128.4, note: "ปกติ" });
    expect(await S.get("records", "FI-2104")).toEqual({
      id: "FI-2104",
      value: 128.4,
      note: "ปกติ"
    });
  });

  it("put ซ้ำ id เดิม = ทับของเก่า ไม่ใช่เพิ่มแถวใหม่", async () => {
    const win = await ready(loadApp());
    const S = mod(win, "STORAGE_ENGINE");
    await S.put("records", { id: "TI-3312", value: 1 });
    await S.put("records", { id: "TI-3312", value: 2 });
    const all = await S.getAll("records");
    expect(all).toHaveLength(1);
    expect(all[0].value).toBe(2);
  });

  it("del ลบแล้ว get ต้องได้ undefined ไม่ใช่ throw", async () => {
    const win = await ready(loadApp());
    const S = mod(win, "STORAGE_ENGINE");
    await S.put("records", { id: "X", value: 1 });
    await S.del("records", "X");
    expect(await S.get("records", "X")).toBeUndefined();
  });

  it("อ่าน store ที่ไม่มีอยู่ → reject ไม่ใช่เงียบ", async () => {
    const win = await ready(loadApp());
    await expect(mod(win, "STORAGE_ENGINE").get("ไม่มีสโตร์นี้", "x")).rejects.toBeTruthy();
  });
});

describe("STATE_STORE — pub/sub", () => {
  it("set เรียก subscriber ทุกครั้ง และ unsubscribe แล้วต้องหยุดเรียก", async () => {
    const win = await ready(loadApp());
    const ST = mod(win, "STATE_STORE");
    let calls = 0;
    const off = ST.subscribe(() => calls++);
    ST.set({ loading: true });
    ST.set({ loading: false });
    off();
    ST.set({ loading: true });
    expect(calls).toBe(2);
  });

  it("set เป็นการ merge ไม่ใช่แทนที่ state ทั้งก้อน", async () => {
    const win = await ready(loadApp());
    const ST = mod(win, "STATE_STORE");
    ST.set({ records: [1, 2] });
    ST.set({ loading: true });
    expect(ST.get("records")).toEqual([1, 2]);
    expect(ST.get("loading")).toBe(true);
  });
});

describe("Security — กฎ §8 ที่เคยเป็นแค่ข้อความ", () => {
  it("UI_RENDERER.el() ไม่ตีความข้อความของผู้ใช้เป็น HTML (กัน XSS)", async () => {
    const win = await ready(loadApp());
    const node = mod(win, "UI_RENDERER").el("div", null, '<img src=x onerror="alert(1)">');
    /* ถ้ามีใครแอบเปลี่ยนไปใช้ innerHTML บรรทัดล่างจะเจอ <img> จริงและเทสต์แดงทันที */
    expect(node.querySelector("img")).toBeNull();
    expect(node.textContent).toContain("<img");
  });

  it("ไม่มี API key ฝังอยู่ในหน้า", async () => {
    const win = await ready(loadApp());
    expect(win.document.documentElement.outerHTML).not.toMatch(/AIza[0-9A-Za-z_-]{35}/);
  });
});

describe("ธีม — ต้องครบ 3 สถานะ", () => {
  it("ไม่เคยเลือกธีม = ไม่ stamp data-theme (ปล่อยให้ตามระบบ)", async () => {
    const win = await ready(loadApp());
    expect(win.document.documentElement.getAttribute("data-theme")).toBeNull();
  });

  it("เคยเลือกไว้ = ใช้ค่าที่บันทึก ไม่ใช่ค่าของระบบ", async () => {
    const win = await ready(loadApp({ savedTheme: "dark", theme: "light" }));
    expect(win.document.documentElement.getAttribute("data-theme")).toBe("dark");
  });

  it("localStorage โยน error (โหมดส่วนตัว) แล้วแอปต้องไม่ตาย", async () => {
    const win = await ready(loadApp({ localStorageThrows: true }));
    expect(mod(win, "APP_CORE")).toBeDefined();
    expect(win.document.getElementById("kpiRow")).not.toBeNull();
  });
});

describe("Error boundary + ปุ่มรายงานปัญหา", () => {
  it("error ที่ไม่ถูกดัก ทำให้ toast โผล่", async () => {
    const win = await ready(loadApp());
    expect(win.document.getElementById("errorToast").hidden).toBe(true);
    win.dispatchEvent(new win.ErrorEvent("error", { message: "พังโดยตั้งใจ" }));
    expect(win.document.getElementById("errorToast").hidden).toBe(false);
  });

  it("DEBUG_MODULE เก็บ log ไว้ให้แนบตอนรายงาน แม้ไม่ได้เปิด ?debug=1", async () => {
    const win = await ready(loadApp());
    win.dispatchEvent(new win.ErrorEvent("error", { message: "พังโดยตั้งใจ" }));
    expect(mod(win, "DEBUG_MODULE").recent().join("\n")).toContain("พังโดยตั้งใจ");
  });

  it("log() เขียน ring ลง STORAGE_ENGINE จริง ไม่ใช่แค่ memory", async () => {
    const win = await ready(loadApp());
    await mod(win, "DEBUG_MODULE").log("เก็บลง IndexedDB"); /* log() คืน promise ของ persist() */
    const rec = await mod(win, "STORAGE_ENGINE").get("debugLog", "ring");
    expect(rec.entries.join("\n")).toContain("เก็บลง IndexedDB");
  });

  it("reload แล้ว DEBUG_MODULE ยังเห็น log เดิมที่เคย persist ไว้", async () => {
    const shared = newIDB();

    const v1 = await ready(loadApp({ idb: shared }));
    await mod(v1, "DEBUG_MODULE").log("ของเก่าก่อน reload");

    const v2 = await ready(loadApp({ idb: shared }));
    /* init() เรียก hydrate() ให้อัตโนมัติแล้ว (fire-and-forget) — เรียกซ้ำแล้ว await
       เพื่อไม่ต้องพึ่งจังหวะเวลาของ load event ว่า hydrate เดิมจบหรือยัง */
    await mod(v2, "DEBUG_MODULE").hydrate();
    expect(mod(v2, "DEBUG_MODULE").recent().join("\n")).toContain("ของเก่าก่อน reload");
  });
});
