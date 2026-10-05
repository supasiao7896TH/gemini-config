import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    /* environment: "node" โดยตั้งใจ — เราสร้าง JSDOM เองใน harness เพื่อคุม
       indexedDB/matchMedia/localStorage ต่อเทสต์ ถ้าให้ vitest สร้างให้
       ทุกเทสต์จะใช้ window ก้อนเดียวกันและสถานะจะรั่วข้ามเทสต์ */
    environment: "node",
    include: ["tests/unit/**/*.test.mjs"],
    testTimeout: 10000
  }
});
