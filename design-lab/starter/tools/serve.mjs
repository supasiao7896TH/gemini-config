/**
 * static server เล็กๆ สำหรับให้ Playwright เปิดแอป
 *
 * เขียนเองแทนการใช้ `npx serve` ด้วยเหตุผล 3 ข้อ:
 *   1. ไม่ต้องโหลด package เพิ่ม — เครื่องที่เน็ตบริษัทกรองยังใช้ได้
 *   2. ทำงานบน Windows เหมือนกันเป๊ะ ไม่ต้องพึ่ง shell
 *   3. ต้องเสิร์ฟผ่าน http:// ไม่ใช่ file:// เพราะ service worker กับ IndexedDB
 *      มีพฤติกรรมต่างกันบน file:// จนทดสอบแล้วไม่ตรงกับของจริง
 *
 *   node tools/serve.mjs [port]
 */

import { createServer } from "node:http";
import { readFile, stat } from "node:fs/promises";
import { extname, join, normalize, resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const PORT = Number(process.argv[2] || process.env.PORT || 4173);

const TYPES = {
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".mjs": "text/javascript; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".webmanifest": "application/manifest+json; charset=utf-8",
  ".svg": "image/svg+xml",
  ".png": "image/png",
  ".ico": "image/x-icon",
  ".woff2": "font/woff2"
};

createServer(async (req, res) => {
  try {
    const url = new URL(req.url, "http://localhost");
    let path = decodeURIComponent(url.pathname);
    if (path.endsWith("/")) path += "index.html";

    /* กัน path traversal — normalize แล้วต้องยังอยู่ใต้ ROOT เท่านั้น */
    const file = normalize(join(ROOT, path));
    if (!file.startsWith(ROOT)) {
      res.writeHead(403).end("forbidden");
      return;
    }

    await stat(file);
    const body = await readFile(file);
    res.writeHead(200, {
      "content-type": TYPES[extname(file)] || "application/octet-stream",
      /* ปิด cache ทั้งหมด — ไม่งั้นเทสต์อาจผ่านเพราะได้ไฟล์เก่าจาก cache */
      "cache-control": "no-store"
    });
    res.end(body);
  } catch {
    res.writeHead(404, { "content-type": "text/plain; charset=utf-8" }).end("not found");
  }
}).listen(PORT, () => console.log(`serving ${ROOT} → http://localhost:${PORT}`));
