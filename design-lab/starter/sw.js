/* Service Worker — cache-first สำหรับ app shell
   bump CACHE_NAME ทุกครั้งที่แก้ไฟล์ ไม่งั้นเครื่องที่เคยเปิดจะยังเห็นของเก่า */
var CACHE_NAME = "supasit-studio-v4";
var SHELL = ["./", "./index.html", "./chart-theme.js", "./assets/icon.svg", "./manifest.webmanifest",
  "./assets/d1-neon-arcade-bare.svg", "./assets/d2-crt-night-bare.svg"];

self.addEventListener("install", function (e) {
  e.waitUntil(caches.open(CACHE_NAME).then(function (c) { return c.addAll(SHELL); }).then(function () { return self.skipWaiting(); }));
});

self.addEventListener("activate", function (e) {
  e.waitUntil(caches.keys().then(function (keys) {
    return Promise.all(keys.filter(function (k) { return k !== CACHE_NAME; }).map(function (k) { return caches.delete(k); }));
  }).then(function () { return self.clients.claim(); }));
});

self.addEventListener("fetch", function (e) {
  if (e.request.method !== "GET") return;
  e.respondWith(caches.match(e.request).then(function (hit) {
    return hit || fetch(e.request).then(function (res) {
      /* เก็บเฉพาะของตัวเอง — คำขอข้ามโดเมน (ฟอนต์/CDN) ปล่อยผ่าน ไม่ยัดลง cache */
      if (res.ok && new URL(e.request.url).origin === location.origin) {
        var copy = res.clone();
        caches.open(CACHE_NAME).then(function (c) { c.put(e.request, copy); });
      }
      return res;
    }).catch(function () { return caches.match("./index.html"); });
  }));
});
