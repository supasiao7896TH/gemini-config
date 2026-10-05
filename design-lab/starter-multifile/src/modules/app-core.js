/* 7 · APP_CORE — ประกอบทุกอย่างเข้าด้วยกัน
   ฟังก์ชันที่นี่แตะแต่ document/window/localStorage ของแวดล้อมที่รันอยู่จริง (browser จริง
   ตอน production, jsdom ตอนเทสต์) — ไม่ผูกกับ window ก้อนใดก้อนหนึ่งโดยเฉพาะเหมือนตอน
   Single HTML File เพราะไม่จำเป็นอีกต่อไป: ES module import ตรงๆ ได้อยู่แล้ว */
import { AppConfig } from "./app-config.js";
import { UiRenderer } from "./ui-renderer.js";
import { DebugModule } from "./debug-module.js";

function currentTheme() {
  const t = document.documentElement.getAttribute("data-theme");
  if (t) return t;
  return matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
}

function applyTheme(t) {
  document.documentElement.setAttribute("data-theme", t);
  /* localStorage โยน error ได้ในโหมดส่วนตัว — ต้องอยู่ใน try/catch เสมอ */
  try {
    localStorage.setItem(AppConfig.THEME_KEY, t);
  } catch {
    /* โหมดส่วนตัว/localStorage ถูกปิด — ธีมยังใช้ได้ แค่ไม่จำข้ามเซสชัน */
  }
}

function initTheme() {
  let saved = null;
  try {
    saved = localStorage.getItem(AppConfig.THEME_KEY);
  } catch {
    /* เช่นเดียวกับข้างบน */
  }
  if (saved) document.documentElement.setAttribute("data-theme", saved); /* ไม่ stamp = ตามระบบ */
}

/* Global Error Boundary — §2 ระบุว่าต้องมี */
function installErrorBoundary() {
  function report(kind, detail) {
    DebugModule.log(`[${kind}]`, detail);
    const box = document.getElementById("errorToast");
    const txt = document.getElementById("errorToastText");
    if (txt) txt.textContent = "เกิดข้อผิดพลาด — กดรายงานปัญหาได้ค่ะ";
    if (box) box.hidden = false;
  }

  /* ปุ่มรายงานปัญหา = เปิด GitHub issue ที่กรอกไว้ให้แล้ว
     ไม่ต้องมี backend · ไม่มีค่าใช้จ่าย · ไม่มีข้อมูลออกจากเครื่องจนกว่าผู้ใช้จะกดเอง
     ตั้ง AppConfig.ISSUE_URL เป็น .../issues/new ของ repo แอปนั้น */
  const btn = document.getElementById("reportBtn");
  if (btn) {
    btn.addEventListener("click", () => {
      const body =
        "**เกิดอะไรขึ้น:** \n\n**กดอะไรก่อนหน้านั้น:** \n\n" +
        `---\nเวอร์ชัน: ${DebugModule.version()}` +
        `\nเบราว์เซอร์: ${navigator.userAgent}` +
        `\n\nlog ล่าสุด:\n\`\`\`\n${DebugModule.recent().join("\n")}\n\`\`\``;
      const url = AppConfig.ISSUE_URL;
      if (!url) {
        DebugModule.log("ยังไม่ได้ตั้ง AppConfig.ISSUE_URL");
        return;
      }
      window.open(
        `${url}?title=${encodeURIComponent("[bug] ")}&body=${encodeURIComponent(body)}`,
        "_blank",
        "noopener"
      );
    });
  }
  window.addEventListener("error", (e) => report("error", e.message));
  window.addEventListener("unhandledrejection", (e) => {
    report("promise", (e.reason && e.reason.message) || String(e.reason));
  });
}

function init() {
  DebugModule.hydrate(); /* fire-and-forget — init() ต้องยัง sync เหมือนเดิม */
  installErrorBoundary();
  initTheme();
  document.getElementById("themeBtn").addEventListener("click", () => {
    applyTheme(currentTheme() === "dark" ? "light" : "dark");
  });

  /* ข้อมูลตัวอย่าง — ลบทิ้งแล้วต่อกับ StorageEngine ของจริง */
  UiRenderer.render({
    kpis: [
      { label: "ตัวชี้วัดที่ 1", value: "1,842", unit: "หน่วย", note: "ปกติ", tone: "c-ok" },
      { label: "ตัวชี้วัดที่ 2", value: "96.4", unit: "หน่วย", note: "เฝ้าระวัง", tone: "c-warn" },
      { label: "ตัวชี้วัดที่ 3", value: "99.1", unit: "%", note: "ปกติ", tone: "c-ok" },
      { label: "ตัวชี้วัดที่ 4", value: "3", unit: "รายการ", note: "ต้องแก้", tone: "c-crit" }
    ],
    records: [
      {
        tag: "FI-2104",
        name: "รายการตัวอย่างที่หนึ่ง",
        value: "128.40",
        status: "ปกติ",
        tone: "c-ok"
      },
      {
        tag: "TI-3312",
        name: "รายการตัวอย่างที่สอง",
        value: "214.80",
        status: "เฝ้าระวัง",
        tone: "c-warn"
      }
    ]
  });

  DebugModule.log("พร้อมใช้งาน", AppConfig.APP_NAME);
}

export const AppCore = { init, currentTheme, applyTheme, initTheme, installErrorBoundary };
