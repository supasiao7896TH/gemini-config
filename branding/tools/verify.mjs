/**
 * Checks the built branding page and its exports.
 *
 *   node branding/tools/verify.mjs
 *
 * Run after tools/build.mjs. Exits non-zero on the first failure, so it
 * can gate a commit.
 */

import { readFileSync, existsSync, writeFileSync, mkdtempSync } from "node:fs";
import { fileURLToPath, pathToFileURL } from "node:url";
import { dirname, resolve, join } from "node:path";
import { execSync } from "node:child_process";
import { tmpdir } from "node:os";

const HERE = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(HERE, "..");
const PAGE = pathToFileURL(resolve(ROOT, "aicoder-mockups.html")).href;
const EXPORTS = resolve(ROOT, "exports");

let failures = 0;
const check = (name, ok, detail = "") => {
  console.log(`${ok ? "  ok  " : "FAIL  "}${name}${detail ? "  — " + detail : ""}`);
  if (!ok) failures++;
};

async function loadPlaywright() {
  try { return await import("playwright"); }
  catch {
    const root = execSync("npm root -g", { encoding: "utf8" }).trim();
    return await import(pathToFileURL(resolve(root, "playwright/index.js")).href);
  }
}
const pw = await loadPlaywright();
const chromium = pw.chromium ?? pw.default?.chromium;

/* PW_CHROMIUM_PATH — ทางออกสำหรับเครื่องที่ "มี Chromium อยู่แล้ว แต่คนละ build
   กับที่ Playwright เวอร์ชันนี้คาดไว้" เช่นเครื่องที่บริษัทบล็อกการดาวน์โหลด
   เบราว์เซอร์ หรือ CI container ที่ preinstall ไว้คนละ build
   ไม่ตั้ง = ใช้เบราว์เซอร์ที่ `npx playwright install chromium` โหลดมา ตามปกติ */
const executablePath = process.env.PW_CHROMIUM_PATH || undefined;
let browser;
try {
  browser = await chromium.launch(executablePath ? { executablePath } : {});
} catch (err) {
  console.error(
    "\nเปิด Chromium ไม่ได้ — รัน `npx playwright install chromium`\n" +
    "หรือถ้าเครื่องนี้มี Chromium อยู่แล้ว ให้ชี้ path เอง:\n" +
    "  PW_CHROMIUM_PATH=/path/to/chrome node branding/tools/verify.mjs\n"
  );
  throw err;
}

/* ── Exported SVGs ─────────────────────────────────────────────────── */

/* Only the animated exports build.mjs itself produces — matches
   __exportSVGs() in the template exactly. The static Studio marks
   (studio-badge-*.svg, studio-icon.svg) live in the same exports/ folder
   but come from a separate process and are never expected to flicker, so
   they don't belong in this loop. */
const EXPECTED_SVGS = ["d1-neon-arcade", "d2-crt-night"]
  .flatMap(dir => ["bare", "glow", "plate"].map(g => `${dir}-${g}.svg`));
const missing = EXPECTED_SVGS.filter(f => !existsSync(resolve(EXPORTS, f)));
check("six standalone SVGs exported", missing.length === 0, missing.join(", "));

for (const f of EXPECTED_SVGS) {
  const body = readFileSync(resolve(EXPORTS, f), "utf8");
  /* A standalone file has no :root to read a brand token from, so a
     surviving var(--sc-*) would render as black. The per-tube phase
     variables are a different matter — those are set inline on each tube
     and are supposed to be there. */
  check(`${f}: brand tokens resolved`, !body.includes("var(--sc-"));
  check(`${f}: carries its own keyframes`, body.includes("@keyframes sc-breathe"));
  check(`${f}: honours reduced motion`, body.includes("prefers-reduced-motion"));
}

/* ── The SVGs actually animate inside an <img> ─────────────────────── */

/* This is the claim that matters for a README: CSS animation runs when an
   SVG is loaded as an image, where scripts and external refs do not. */
{
  const dir = mkdtempSync(join(tmpdir(), "sc-anim-"));
  const target = "d2-crt-night-glow.svg";
  writeFileSync(join(dir, target), readFileSync(resolve(EXPORTS, target)));
  writeFileSync(join(dir, "t.html"),
    `<body style="margin:0;background:#000"><img src="${target}" width="1200"></body>`);

  const page = await browser.newPage({ viewport: { width: 1200, height: 300 } });
  await page.goto(pathToFileURL(join(dir, "t.html")).href);
  await page.waitForTimeout(1200);              // let warm-up finish
  const a = await page.screenshot();
  await page.waitForTimeout(900);
  const b = await page.screenshot();
  check("SVG animates inside an <img>", !a.equals(b));
  await page.close();
}

/* ── The page ──────────────────────────────────────────────────────── */

for (const scheme of ["light", "dark"]) {
  const page = await browser.newPage({ viewport: { width: 1280, height: 1000 }, colorScheme: scheme });
  const errors = [], external = [];
  page.on("pageerror", e => errors.push(String(e)));
  page.on("request", r => {
    const u = r.url();
    if (!u.startsWith("file:") && !u.startsWith("data:")) external.push(u);
  });
  await page.goto(PAGE);
  await page.evaluate(() => document.fonts.ready);

  const info = await page.evaluate(() => ({
    bg: getComputedStyle(document.body).backgroundColor,
    fonts: document.fonts.check('16px "SC Body"') &&
           document.fonts.check('16px "SC Display"') &&
           document.fonts.check('16px "SC Mono"'),
    hscroll: document.documentElement.scrollWidth > document.documentElement.clientWidth,
    tubes: document.querySelectorAll(".tube").length
  }));

  check(`${scheme}: no page errors`, errors.length === 0, errors.join(" | "));
  check(`${scheme}: no external requests`, external.length === 0, external.join(" | "));
  check(`${scheme}: all three faces loaded`, info.fonts);
  check(`${scheme}: no horizontal scroll`, !info.hscroll);
  check(`${scheme}: tubes rendered`, info.tubes > 60, `${info.tubes} tubes`);
  const expected = scheme === "dark" ? "rgb(18, 16, 23)" : "rgb(242, 240, 246)";
  check(`${scheme}: body ground resolves`, info.bg === expected, info.bg);
  await page.close();
}

/* ── Reduced motion leaves every sign lit ──────────────────────────── */
{
  const page = await browser.newPage({ viewport: { width: 1280, height: 900 }, reducedMotion: "reduce" });
  await page.goto(PAGE);
  await page.evaluate(() => document.fonts.ready);
  const running = await page.evaluate(() =>
    [...document.querySelectorAll(".tube, .tube-s, .tube-b")]
      .filter(el => el.getAnimations().length > 0).length);
  const dim = await page.evaluate(() =>
    [...document.querySelectorAll(".tube, .tube-s, .tube-b")]
      .filter(el => parseFloat(getComputedStyle(el).opacity) < 1).length);
  check("reduced motion: nothing animating", running === 0, `${running} still running`);
  check("reduced motion: every tube lit", dim === 0, `${dim} below full opacity`);
  await page.close();
}

/* ── Narrow viewport ───────────────────────────────────────────────── */
{
  const page = await browser.newPage({ viewport: { width: 390, height: 844 } });
  await page.goto(PAGE);
  const wide = await page.evaluate(() =>
    document.documentElement.scrollWidth > document.documentElement.clientWidth);
  check("390 px: page does not scroll sideways", !wide);
  await page.close();
}

await browser.close();

console.log(failures ? `\n${failures} check(s) failed` : "\nall checks passed");
process.exit(failures ? 1 : 0);
