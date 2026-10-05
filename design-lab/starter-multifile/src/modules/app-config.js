/* 1 · APP_CONFIG — ค่าคงที่ที่โมดูลอื่นห้ามแก้ */
export const AppConfig = Object.freeze({
  APP_NAME: "ชื่อแอป",
  DB_NAME: "supasit_app",
  DB_VERSION: 2,
  STORES: ["records", "settings", "debugLog"],
  THEME_KEY: "app:theme",
  /* ใส่ .../issues/new ของ repo แอปนี้ — ว่างไว้ = ปุ่มรายงานปัญหาจะเงียบ */
  ISSUE_URL: ""
});
