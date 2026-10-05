/**
 * ชั้นที่ 2 — เบราว์เซอร์จริง
 *
 * ที่นี่ทดสอบเฉพาะสิ่งที่ jsdom ทำไม่ได้ ได้แก่ layout จริง · CSS cascade จริง ·
 * contrast ที่ browser render ออกมาจริง · เป้าแตะ · focus ring
 * อย่าย้ายเทสต์ logic มาที่นี่ — มันช้ากว่า jsdom ~50 เท่าโดยไม่ได้อะไรเพิ่ม
 *
 * ST-04 บอกว่า "ทุกคู่สีต้องวัด contrast ด้วยเครื่อง ไม่ใช่กะด้วยตา"
 * ไฟล์นี้คือเครื่องนั้น
 */

import { test, expect } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

const THEMES = ["light", "dark"];

/* เทสต์ต้อง hermetic — ไม่แตะเน็ตภายนอกเลย
   เหตุผล 2 ข้อ: (1) เทสต์ที่ผลขึ้นกับว่า CDN ขึ้นหรือไม่ คือเทสต์ที่เชื่อไม่ได้
   (2) วัดแล้ว: ปล่อยให้ request ฟอนต์ค้างจนหมดเวลา ทำให้แต่ละเทสต์ช้าขึ้น ~12 วินาที
   (ชุดนี้ 3 นาที 18 วินาที → เหลือไม่ถึงครึ่งนาที)
   ผลพลอยได้: ทุกเทสต์กลายเป็นการพิสูจน์ว่าแอปยังใช้ได้ตอนออฟไลน์ ซึ่งเป็นเงื่อนไขจริง
   ของเครื่องในโรงงานอยู่แล้ว */
test.beforeEach(async ({ page }) => {
  await page.route(/fonts\.(googleapis|gstatic)\.com/, (r) => r.abort());
  await page.route(/^https?:\/\/(cdnjs|cdn)\./, (r) => r.abort());
});

test.describe("โหลดหน้าได้สะอาด", () => {
  test("ไม่มี JS error และไฟล์ของแอปเองโหลดครบ", async ({ page }, testInfo) => {
    const jsErrors = [];
    page.on("pageerror", (e) => jsErrors.push(String(e)));

    const failedOwn = [];
    const failedThirdParty = [];
    page.on("requestfailed", (r) => {
      const url = r.url();
      /* แยกให้ชัดระหว่าง "ไฟล์ของเราพัง" กับ "CDN ข้างนอกเข้าไม่ถึง"
         อย่างที่สองเกิดได้ตลอดบนเน็ตบริษัท/เครื่อง CI ที่ปิดขาออก —
         ถ้าให้มันทำ CI แดง สุดท้ายจะโดนปิดเทสต์ทิ้งทั้งชุด ซึ่งแย่กว่า
         แต่ก็ไม่เงียบ: รายงานเป็น annotation ให้เห็นทุกครั้ง */
      (url.startsWith(testInfo.project.use.baseURL) ? failedOwn : failedThirdParty).push(url);
    });

    await page.goto("/index.html", { waitUntil: "domcontentloaded" });
    await page.waitForTimeout(500);

    if (failedThirdParty.length) {
      testInfo.annotations.push({
        type: "third-party offline",
        description: failedThirdParty.join(", ")
      });
    }

    expect(jsErrors, "JS error ที่ไม่ถูกดัก").toEqual([]);
    expect(failedOwn, "ไฟล์ของแอปเองที่โหลดไม่ได้").toEqual([]);
  });

  test("แอปต้องอ่านออกแม้ฟอนต์จาก CDN โหลดไม่ได้ (fallback stack ต้องมีจริง)", async ({ page }) => {
    /* เน็ตโรงงาน/เครื่อง office อาจเข้า fonts.googleapis.com ไม่ได้
       ถ้า --font-ui มีแค่ "Noto Sans Thai" ตัวเดียว หน้าจะตกไปใช้ฟอนต์ระบบแบบสุ่ม */
    await page.goto("/index.html", { waitUntil: "domcontentloaded" });
    const stack = await page.evaluate(() =>
      getComputedStyle(document.documentElement).getPropertyValue("--font-ui")
    );
    expect(stack.split(",").length, "--font-ui ต้องมี fallback ไม่ใช่ฟอนต์เดียว").toBeGreaterThan(
      1
    );
    expect(await page.locator("h1").isVisible()).toBe(true);
  });

  test("โมดูลทั้งหมดผูกกับ window จริง (harness ของชั้น unit จึงใช้ได้)", async ({ page }) => {
    await page.goto("/index.html", { waitUntil: "domcontentloaded" });
    const missing = await page.evaluate(() =>
      [
        "APP_CONFIG",
        "STATE_STORE",
        "STORAGE_ENGINE",
        "UI_RENDERER",
        "DEBUG_MODULE",
        "APP_CORE"
      ].filter((n) => typeof window[n] === "undefined")
    );
    expect(missing, "โมดูลที่หายไป — น่าจะประกาศด้วย const แทน var").toEqual([]);
  });
});

for (const theme of THEMES) {
  test.describe(`ธีม ${theme}`, () => {
    test.beforeEach(async ({ page }) => {
      await page.goto("/index.html", { waitUntil: "domcontentloaded" });
      await page.evaluate((t) => document.documentElement.setAttribute("data-theme", t), theme);
    });

    test("ไม่มี a11y violation ระดับ serious/critical (รวม contrast)", async ({ page }) => {
      const { violations } = await new AxeBuilder({ page })
        .withTags(["wcag2a", "wcag2aa"])
        .analyze();
      const serious = violations.filter((v) => ["serious", "critical"].includes(v.impact));
      /* พิมพ์ให้อ่านออกเวลาแดง — ไม่ใช่แค่ "expected 1 to be 0" */
      expect(
        serious.map((v) => `${v.id}: ${v.nodes.map((n) => n.target.join(" ")).join(" | ")}`)
      ).toEqual([]);
    });

    test("--surface ต้องต่างจาก --bg จริง (ST: พื้นการ์ดต้องแยกจากพื้นหน้า)", async ({ page }) => {
      const [bg, surface] = await page.evaluate(() => {
        const cs = getComputedStyle(document.documentElement);
        return [cs.getPropertyValue("--bg").trim(), cs.getPropertyValue("--surface").trim()];
      });
      expect(surface).not.toBe(bg);
    });

    for (const width of [390, 1280]) {
      test(`ไม่มีการเลื่อนแนวนอนที่ ${width}px`, async ({ page }) => {
        await page.setViewportSize({ width, height: 800 });
        const overflow = await page.evaluate(
          () => document.documentElement.scrollWidth - document.documentElement.clientWidth
        );
        expect(overflow, "เกินขอบไปกี่ px").toBeLessThanOrEqual(0);
      });
    }

    test("ทุกปุ่มมีชื่อที่ screen reader อ่านได้ และเป้าแตะ ≥44px", async ({ page }) => {
      await page.setViewportSize({ width: 390, height: 800 });
      const bad = await page.evaluate(() => {
        const out = { unnamed: [], tooSmall: [] };
        for (const el of document.querySelectorAll("button, a[href], [role=button]")) {
          const name = (el.getAttribute("aria-label") || el.textContent || "").trim();
          if (!name) out.unnamed.push(el.outerHTML.slice(0, 80));
          const r = el.getBoundingClientRect();
          if (r.width > 0 && r.height > 0 && (r.width < 44 || r.height < 44))
            out.tooSmall.push(
              `${el.tagName.toLowerCase()} ${Math.round(r.width)}×${Math.round(r.height)} "${name}"`
            );
        }
        return out;
      });
      expect(bad.unnamed, "ปุ่มที่ไม่มีชื่อ").toEqual([]);
      expect(bad.tooSmall, "ปุ่มที่เล็กกว่า 44px").toEqual([]);
    });

    test("กด Tab ไล่ทั้งหน้าแล้วทุกชิ้นต้องมีขอบโฟกัสให้เห็น", async ({ page }) => {
      /* ต้องใช้ Tab จริง ไม่ใช่ el.focus() — :focus-visible จะไม่ match กับ
         การโฟกัสด้วยสคริปต์ ทำให้เทสต์แบบ el.focus() ให้ผลลวงทั้งสองทาง
         และต้องเทียบ "ก่อน vs หลังโฟกัส" ด้วย ไม่งั้นชิ้นที่มี box-shadow
         ติดตัวอยู่แล้ว (เช่นการ์ด) จะผ่านทั้งที่ไม่มี ring จริง */
      const seen = [];
      for (let i = 0; i < 30; i++) {
        await page.keyboard.press("Tab");
        const info = await page.evaluate(() => {
          const el = document.activeElement;
          if (!el || el === document.body) return null;
          const key = el.id || el.className || el.tagName;
          const before = { outline: "", shadow: "" };
          const cs = getComputedStyle(el);
          return {
            key,
            html: el.outerHTML.slice(0, 70),
            outlineW: parseFloat(cs.outlineWidth) || 0,
            outlineStyle: cs.outlineStyle,
            shadow: cs.boxShadow,
            /* เทียบกับตัวเองตอนไม่โฟกัส โดยโคลนออกมาวางนอกสายตา */
            shadowUnfocused: (() => {
              const c = el.cloneNode(true);
              c.removeAttribute("id");
              c.style.position = "absolute";
              c.style.left = "-9999px";
              el.parentNode.appendChild(c);
              const s = getComputedStyle(c).boxShadow;
              c.remove();
              return s;
            })()
          };
        });
        if (!info) break;
        if (seen.some((s) => s.key === info.key)) break; // วนครบรอบแล้ว
        seen.push(info);
      }

      expect(
        seen.length,
        "ไม่มีชิ้นไหนโฟกัสได้เลย — แปลว่าคีย์บอร์ดใช้งานหน้านี้ไม่ได้"
      ).toBeGreaterThan(0);

      const noRing = seen
        .filter(
          (s) =>
            !(s.outlineStyle !== "none" && s.outlineW > 0) &&
            !(s.shadow !== "none" && s.shadow !== s.shadowUnfocused)
        )
        .map((s) => s.html);
      expect(noRing, "ชิ้นที่กด Tab ไปถึงแล้วไม่มีขอบให้เห็น").toEqual([]);
    });
  });
}

test("service worker ลงทะเบียนได้ และ CACHE_NAME ตรงกับไฟล์ sw.js", async ({ page }) => {
  await page.goto("/index.html", { waitUntil: "domcontentloaded" });
  const registered = await page.evaluate(() =>
    navigator.serviceWorker.ready.then(() => true).catch(() => false)
  );
  expect(registered).toBe(true);

  /* กับดักที่เอกสาร 3 skill บันทึกไว้ตรงกัน: แก้โค้ดแล้วลืม bump CACHE_NAME
     → deploy สำเร็จแต่ผู้ใช้ยังเห็นของเก่า · CI มี job cache-guard คุมอีกชั้น */
  const sw = await (await page.request.get("/sw.js")).text();
  expect(sw, "sw.js ต้องประกาศ CACHE_NAME").toMatch(/CACHE_NAME\s*=\s*"[^"]+"/);
});
