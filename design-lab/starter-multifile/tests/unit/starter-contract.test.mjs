/**
 * Contract suite — เทียบเท่า design-lab/starter/tests/unit/starter-contract.test.mjs
 * (Single HTML File) ทุกเคส แค่พอร์ตวิธีโหลดจาก "parse index.html เข้า jsdom" มาเป็น
 * "import ES module ตรงๆ" — ดู tests/setup.mjs และ tests/harness/mount.mjs สำหรับกลไกที่ต่างกัน
 */

import { readFileSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { describe, it, expect, vi, afterEach } from "vitest";
import { mount } from "../harness/mount.mjs";
import { AppConfig } from "../../src/modules/app-config.js";
import { UiRenderer } from "../../src/modules/ui-renderer.js";
import { AppCore } from "../../src/modules/app-core.js";
import { DebugModule } from "../../src/modules/debug-module.js";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "../..");
const CONFIG_PATH = "../../src/modules/app-config.js";
const ENGINE_PATH = "../../src/modules/storage-engine.js";
const DEBUG_PATH = "../../src/modules/debug-module.js";

/**
 * import storage-engine.js สดใหม่ทุกครั้ง — จำเป็นเพราะโมดูลเก็บ `dbp` (promise ที่ open()
 * แล้ว) เป็น state ระดับโมดูล ถ้า import ค้างจากเทสต์ก่อนหน้า มันจะชี้ไปที่ indexedDB ก้อนเก่า
 * ที่ tests/setup.mjs เพิ่งสร้างทับไปแล้ว — ไม่ใช่บั๊กของโค้ดแอป แต่เป็นเงื่อนไขของการทดสอบ
 * โมดูลแบบ singleton ที่ต้อง handle เอง (ไม่มีปัญหานี้ตอนรันจริงในเบราว์เซอร์เพราะหน้าโหลด
 * ครั้งเดียว ไม่มี "indexedDB ก้อนใหม่ทุก 10ms" แบบเทสต์)
 */
async function freshStorageEngine(configOverrides) {
  vi.resetModules();
  if (configOverrides) {
    vi.doMock(CONFIG_PATH, async () => {
      const actual = await vi.importActual(CONFIG_PATH);
      return { AppConfig: { ...actual.AppConfig, ...configOverrides } };
    });
  }
  const mod = await import(ENGINE_PATH);
  return mod.StorageEngine;
}

async function freshStateStore() {
  vi.resetModules();
  const mod = await import("../../src/modules/state-store.js");
  return mod.StateStore;
}

/* เหตุผลเดียวกับ freshStorageEngine() — DEBUG_MODULE import ตรงจาก storage-engine.js
   ต้องเป็น "generation" เดียวกัน (resetModules ครั้งเดียวกัน) ถึงจะชี้ globalThis.indexedDB
   ก้อนเดียวกับที่เทสต์นี้เพิ่งสร้างใน beforeEach */
async function freshDebugModule() {
  vi.resetModules();
  const mod = await import(DEBUG_PATH);
  return mod.DebugModule;
}

afterEach(() => {
  vi.doUnmock(CONFIG_PATH);
});

describe("StorageEngine — IndexedDB", () => {
  it("สร้าง object store ครบตามที่ AppConfig.STORES ประกาศไว้", async () => {
    const S = await freshStorageEngine();
    const db = await S.open();
    expect(AppConfig.STORES.length).toBeGreaterThan(0);
    expect([...db.objectStoreNames].sort()).toEqual([...AppConfig.STORES].sort());
  });

  /* ความเสี่ยงจริงที่ error taxonomy ระบุไว้ (STORAGE type-3 "migration fail")
     migration เป็น forward-only ไม่มี down-migration ถ้าเพิ่ม store ตอน bump version
     แล้วเขียน onupgradeneeded ผิด ข้อมูลของผู้ใช้จะหายโดยไม่มีใครรู้จนกว่าจะสาย */
  it("bump DB_VERSION + เพิ่ม store ใหม่ แล้วข้อมูลเดิมต้องอยู่ครบ", async () => {
    const S1 = await freshStorageEngine();
    await S1.put("records", { id: "เก็บไว้นะ", value: 42 });

    /* จำลองแอปเวอร์ชันถัดไป: DB_VERSION 2 → 3 และเพิ่ม store "audit"
       ใช้ indexedDB ก้อนเดิม (ไม่ผ่าน beforeEach ใหม่ เพราะยังอยู่ใน it() เดียวกัน) */
    const S2 = await freshStorageEngine({
      DB_VERSION: 3,
      STORES: ["records", "settings", "debugLog", "audit"]
    });
    const db2 = await S2.open();
    expect([...db2.objectStoreNames]).toContain("audit");
    expect(await S2.get("records", "เก็บไว้นะ")).toEqual({ id: "เก็บไว้นะ", value: 42 });
  });

  it("put → get คืนข้อมูลเดิมครบถ้วน", async () => {
    const S = await freshStorageEngine();
    await S.put("records", { id: "FI-2104", value: 128.4, note: "ปกติ" });
    expect(await S.get("records", "FI-2104")).toEqual({
      id: "FI-2104",
      value: 128.4,
      note: "ปกติ"
    });
  });

  it("put ซ้ำ id เดิม = ทับของเก่า ไม่ใช่เพิ่มแถวใหม่", async () => {
    const S = await freshStorageEngine();
    await S.put("records", { id: "TI-3312", value: 1 });
    await S.put("records", { id: "TI-3312", value: 2 });
    const all = await S.getAll("records");
    expect(all).toHaveLength(1);
    expect(all[0].value).toBe(2);
  });

  it("del ลบแล้ว get ต้องได้ undefined ไม่ใช่ throw", async () => {
    const S = await freshStorageEngine();
    await S.put("records", { id: "X", value: 1 });
    await S.del("records", "X");
    expect(await S.get("records", "X")).toBeUndefined();
  });

  it("อ่าน store ที่ไม่มีอยู่ → reject ไม่ใช่เงียบ", async () => {
    const S = await freshStorageEngine();
    await expect(S.get("ไม่มีสโตร์นี้", "x")).rejects.toBeTruthy();
  });
});

describe("StateStore — pub/sub", () => {
  it("set เรียก subscriber ทุกครั้ง และ unsubscribe แล้วต้องหยุดเรียก", async () => {
    const ST = await freshStateStore();
    let calls = 0;
    const off = ST.subscribe(() => calls++);
    ST.set({ loading: true });
    ST.set({ loading: false });
    off();
    ST.set({ loading: true });
    expect(calls).toBe(2);
  });

  it("set เป็นการ merge ไม่ใช่แทนที่ state ทั้งก้อน", async () => {
    const ST = await freshStateStore();
    ST.set({ records: [1, 2] });
    ST.set({ loading: true });
    expect(ST.get("records")).toEqual([1, 2]);
    expect(ST.get("loading")).toBe(true);
  });
});

describe("Security — กฎ §8 ที่เคยเป็นแค่ข้อความ", () => {
  it("UiRenderer.el() ไม่ตีความข้อความของผู้ใช้เป็น HTML (กัน XSS)", () => {
    const node = UiRenderer.el("div", null, '<img src=x onerror="alert(1)">');
    /* ถ้ามีใครแอบเปลี่ยนไปใช้ innerHTML บรรทัดล่างจะเจอ <img> จริงและเทสต์แดงทันที */
    expect(node.querySelector("img")).toBeNull();
    expect(node.textContent).toContain("<img");
  });

  it("ไม่มี API key ฝังอยู่ใน index.html", () => {
    const html = readFileSync(resolve(ROOT, "index.html"), "utf8");
    expect(html).not.toMatch(/AIza[0-9A-Za-z_-]{35}/);
  });
});

describe("ธีม — ต้องครบ 3 สถานะ", () => {
  it("ไม่เคยเลือกธีม = ไม่ stamp data-theme (ปล่อยให้ตามระบบ)", () => {
    mount();
    AppCore.initTheme();
    expect(document.documentElement.getAttribute("data-theme")).toBeNull();
  });

  it("เคยเลือกไว้ = ใช้ค่าที่บันทึก ไม่ใช่ค่าของระบบ", () => {
    mount();
    localStorage.setItem(AppConfig.THEME_KEY, "dark");
    AppCore.initTheme();
    expect(document.documentElement.getAttribute("data-theme")).toBe("dark");
  });

  it("localStorage โยน error (โหมดส่วนตัว) แล้วแอปต้องไม่ตาย", () => {
    mount();
    const real = window.localStorage;
    Object.defineProperty(window, "localStorage", {
      configurable: true,
      get() {
        throw new DOMException("localStorage ถูกปิดในโหมดส่วนตัว", "SecurityError");
      }
    });
    try {
      expect(() => AppCore.init()).not.toThrow();
      expect(document.getElementById("kpiRow")).not.toBeNull();
    } finally {
      Object.defineProperty(window, "localStorage", { configurable: true, value: real });
    }
  });
});

describe("Error boundary + ปุ่มรายงานปัญหา", () => {
  it("error ที่ไม่ถูกดัก ทำให้ toast โผล่", () => {
    mount();
    AppCore.installErrorBoundary();
    expect(document.getElementById("errorToast").hidden).toBe(true);
    window.dispatchEvent(new window.ErrorEvent("error", { message: "พังโดยตั้งใจ" }));
    expect(document.getElementById("errorToast").hidden).toBe(false);
  });

  it("DebugModule เก็บ log ไว้ให้แนบตอนรายงาน แม้ไม่ได้เปิด ?debug=1", () => {
    mount();
    AppCore.installErrorBoundary();
    window.dispatchEvent(new window.ErrorEvent("error", { message: "พังโดยตั้งใจ" }));
    expect(DebugModule.recent().join("\n")).toContain("พังโดยตั้งใจ");
  });

  it("log() เขียน ring ลง StorageEngine จริง ไม่ใช่แค่ memory", async () => {
    const D = await freshDebugModule();
    await D.log("เก็บลง IndexedDB"); /* log() คืน promise ของ persist() ให้เทสต์ await ได้ */
    const S = await freshStorageEngine();
    const rec = await S.get("debugLog", "ring");
    expect(rec.entries.join("\n")).toContain("เก็บลง IndexedDB");
  });

  it("hydrate() merge ของเดิมกับ log() ที่เกิดระหว่างรอ hydrate ไม่ให้หาย", async () => {
    /* จำลองสถานการณ์จริงใน init(): hydrate() ถูกเรียกก่อนแต่ไม่ await แล้ว log()
       อื่นเกิดตามมาก่อน hydrate() จะ resolve เสร็จ (เช่น log "พร้อมใช้งาน" ท้าย init()) */
    const S = await freshStorageEngine();
    await S.put("debugLog", { id: "ring", entries: ["ของเก่าก่อน reload"] });

    const D = await freshDebugModule();
    const hydrating = D.hydrate();
    D.log("log ระหว่างรอ hydrate");
    await hydrating;

    const all = D.recent().join("\n");
    expect(all).toContain("ของเก่าก่อน reload");
    expect(all).toContain("log ระหว่างรอ hydrate");
  });
});
