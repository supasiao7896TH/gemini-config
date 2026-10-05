/**
 * A(i)CODER branding build.
 *
 *   node branding/tools/build.mjs          build HTML + export PNGs
 *   node branding/tools/build.mjs --html   build HTML only (skip the browser)
 *
 * Step 1 inlines the OFL fonts into the template as data URIs, because the
 * artifact CSP blocks every external host — a linked webfont would fall back
 * silently. Step 2 screenshots each hero lockup at 2x with Playwright.
 *
 * Chromium is already on disk (PLAYWRIGHT_BROWSERS_PATH). Do not run
 * `playwright install`.
 */

import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { fileURLToPath, pathToFileURL } from "node:url";
import { dirname, resolve } from "node:path";
import { execSync } from "node:child_process";

const HERE = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(HERE, "..");

const TEMPLATE = resolve(ROOT, "src/mockups.template.html");
const OUTPUT   = resolve(ROOT, "aicoder-mockups.html");
const EXPORTS  = resolve(ROOT, "exports");

const FONTS = {
  __TEKTUR__:          "fonts/Tektur-Medium.ttf",
  __INSTRUMENT_REG__:  "fonts/InstrumentSans-Regular.ttf",
  __INSTRUMENT_BOLD__: "fonts/InstrumentSans-Bold.ttf",
  __DMMONO__:          "fonts/DMMono-Regular.ttf"
};

const SHOTS = [
  ["#d1-hero", "d1-neon-arcade.png"],
  ["#d2-hero", "d2-crt-night.png"],
  ["#d3-hero", "d3-street-sticker.png"]
];

/* ── 1. Inline the fonts ─────────────────────────────────────────── */

let html = readFileSync(TEMPLATE, "utf8");

for (const [token, file] of Object.entries(FONTS)) {
  if (!html.includes(token)) throw new Error(`template is missing token ${token}`);
  const b64 = readFileSync(resolve(ROOT, file)).toString("base64");
  html = html.replaceAll(token, b64);
}

writeFileSync(OUTPUT, html);
console.log(`built  ${OUTPUT}  (${(html.length / 1024).toFixed(0)} KB)`);

if (process.argv.includes("--html")) process.exit(0);

/* ── 2. Export the hero lockups ──────────────────────────────────── */

/* Prefer a project-local playwright; fall back to a global install, which
   ESM will not find on its own (it ignores NODE_PATH). */
async function loadPlaywright() {
  try {
    return await import("playwright");
  } catch {
    const globalRoot = execSync("npm root -g", { encoding: "utf8" }).trim();
    const entry = resolve(globalRoot, "playwright/index.js");
    return await import(pathToFileURL(entry).href);
  }
}

const pw = await loadPlaywright();
// A CJS playwright imported by path lands under .default; a package-resolved
// one exposes the named export directly.
const chromium = pw.chromium ?? pw.default?.chromium;
if (!chromium) throw new Error("could not load playwright's chromium");

mkdirSync(EXPORTS, { recursive: true });

/* PW_CHROMIUM_PATH — เครื่องที่มี Chromium อยู่แล้วแต่โหลด build ของ Playwright ไม่ได้
   (เน็ตบริษัทกรอง / container ที่ preinstall ไว้คนละ build) ชี้ path เองได้
   ตัวเลือกเดียวกับใน verify.mjs */
const executablePath = process.env.PW_CHROMIUM_PATH || undefined;
const browser = await chromium.launch(executablePath ? { executablePath } : {});
const page = await browser.newPage({
  viewport: { width: 1400, height: 1000 },
  deviceScaleFactor: 2
});

await page.goto("file://" + OUTPUT);
await page.evaluate(() => document.fonts.ready);
// The scroll-reveal starts sections at opacity 0; force them visible so a
// screenshot never catches a half-faded stage.
await page.evaluate(() => document.querySelectorAll(".rise").forEach(el => el.classList.add("in")));

/* Shoot the plate variant: a PNG has no surface to sit on, so the static
   fallback has to carry its own ground. The page keeps its glow default. */
for (const dir of ["d1", "d2"]) {
  await page.click(`.ground-pick[data-for="${dir}"] button[data-g="plate"]`);
}

for (const [selector, name] of SHOTS) {
  const path = resolve(EXPORTS, name);
  await page.locator(selector).screenshot({ path, animations: "disabled" });
  console.log(`shot   ${path}`);
}

/* ── 3. Export the standalone animated SVGs ──────────────────────── */

/* Pulled off the same renderer the page uses, so an exported file can
   never disagree with what was approved on screen. Each one carries its
   own <style>, which is what lets it flicker inside an <img> — a README
   can point straight at it. */

const svgs = await page.evaluate(() => window.__exportSVGs());

for (const [name, markup] of Object.entries(svgs)) {
  const path = resolve(EXPORTS, `${name}.svg`);
  writeFileSync(path, markup.replace(/\n\s+/g, "\n").trim() + "\n");
  console.log(`svg    ${path}`);
}

await browser.close();
