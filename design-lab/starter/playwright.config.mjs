import { defineConfig, devices } from "@playwright/test";

/* PW_CHROMIUM_PATH — เครื่องที่มี Chromium อยู่แล้วแต่โหลด build ของ Playwright ไม่ได้
   (เน็ตบริษัทกรอง / container ที่ preinstall ไว้คนละ build) ชี้ path เองได้
   ไม่ตั้ง = ใช้เบราว์เซอร์ที่ `npx playwright install chromium` โหลดมา ตามปกติ */
const executablePath = process.env.PW_CHROMIUM_PATH || undefined;

export default defineConfig({
  testDir: "tests/e2e",
  /* CI ช้ากว่าเครื่องตัวเอง แต่ไม่ควรเกินนี้ — ถ้าเกินแปลว่ามีอะไรผิดจริง ไม่ใช่แค่ช้า */
  timeout: 30_000,
  expect: { timeout: 5_000 },
  forbidOnly: !!process.env.CI,
  retries: 0, // ไม่ retry โดยตั้งใจ — เทสต์ที่ผ่านบ้างไม่ผ่านบ้าง คือเทสต์ที่ต้องแก้ ไม่ใช่ต้องรันซ้ำ
  reporter: process.env.CI ? [["github"], ["list"]] : [["list"]],
  use: {
    baseURL: "http://localhost:4173",
    /* ฟอนต์จาก CDN ไม่เกี่ยวกับสิ่งที่เทสต์ตรวจ และบนเน็ตที่กรองขาออกมันจะค้าง
       จนกว่าจะหมดเวลา ทำให้ทุกเทสต์ช้าขึ้นเทสต์ละ ~13 วินาที */
    navigationTimeout: 15_000,
    launchOptions: executablePath ? { executablePath } : {},
    screenshot: "only-on-failure"
  },
  projects: [{ name: "chromium", use: { ...devices["Desktop Chrome"] } }],
  webServer: {
    command: "node tools/serve.mjs 4173",
    url: "http://localhost:4173/index.html",
    reuseExistingServer: !process.env.CI,
    timeout: 20_000
  }
});
