# Branding review checklist

Run this before shipping any change to the marks in this folder — a new
placement, a template edit, a new direction. Referenced from
[`README.md`](./README.md).

## Automated — `tools/verify.mjs`

Run `npm run brand:build && npm run brand:verify` and require exit code 0
before merging any change to `src/mockups.template.html` or `exports/`.
Both are now declared dependencies in the repo's `package.json`, so
`npm ci` is all the setup there is — and CI runs this same pair on every
push, so a stale export can no longer reach `main` unnoticed.

If the machine has Chromium already but Playwright refuses to launch it
(a corporate network that blocks the browser download, or a preinstalled
build that does not match this Playwright version), point at it directly:
`PW_CHROMIUM_PATH=/path/to/chrome npm run brand:build` — the same variable
works for both scripts.

One thing CI deliberately does **not** check: whether the committed PNGs
match a fresh build. They are browser screenshots, so every build produces
slightly different bytes even when the image is pixel-identical — measured
on 2026-09-02, `d1-neon-arcade.png` came out 349947, 350113 and 350116 bytes
on three runs of the same source. Only the SVGs and the generated HTML page
are compared, because those are built from the template as text and are
reproducible. The PNGs' actual content is still covered by `verify.mjs`,
which opens the real page in a browser.

It already covers:

- every brand token resolves to a literal in each exported SVG (a standalone
  file has no `:root` to read a CSS variable from)
- every export carries its own `<style>` with all three flicker keyframes
  and a `prefers-reduced-motion: reduce` rule
- the SVGs actually animate when loaded as an `<img>`, not just inline
- no external network requests from any export (CSP-safe by construction)
- all three directions (D1/D2/D3) load without error
- no horizontal scroll at 1280px or 390px
- both light and dark themes resolve
- reduced motion leaves every tube lit, not mid-flicker or blank

If `tools/verify.mjs` can't run (no Playwright/Chromium on the machine — see
`tools/build.mjs`'s header comment), the by-eye checks below are not a
substitute for the animation/CSP/reduced-motion checks above. Run the full
automated pass on a machine that has Chromium before calling a template
change done.

## By eye — things `verify.mjs` doesn't measure

- **Ground match, measured, not eyeballed.** Before placing `-bare` on any
  surface, compare that surface's actual `--bg` hex against the documented
  threshold — D1 needs a ground lighter than `#E8E4F2`, D2 needs one darker
  than `#1A1626` — component-by-component, not "looks about right." This is
  the same discipline the Studio design system's own ST-04 rule requires for
  its status colours; apply it here too.
- **Width before placement.** D1 ≥240px wide, D2 ≥280px wide, D3 full
  lockup ≥120px, D3 paw-only ≥16px. If the target spot is narrower than the
  mark's own documented minimum, don't shrink the mark to fit — use a Studio
  mark instead (see `branding/README.md`'s D4 section for which file).
- **System fit.** Neon (D1/D2) is the voice for hero/splash/external
  surfaces where the mark gets its own real estate. Studio (D4) is the voice
  for dense, in-app UI. Don't mix both systems inside one dense surface —
  pick the one that matches what's around it.
- **Clear space.** 2 pixel units on all sides for D1/D2, 1 keyline width for
  D3 — check nothing (text, another element) sits inside that margin.

## Process

- Edit `src/mockups.template.html` — never `aicoder-mockups.html` or
  `exports/*` directly; both are generated and get overwritten on the next
  build.
- After a template edit, rebuild before eyeballing anything: direct edits to
  `exports/*.svg` without rebuilding will silently drift from the template.
- If a change moves or resizes an element inside the lockup (paws, year
  mark, bar), re-check the "Minimum sizes" table in `README.md` — the
  numbers there are a claim about the built output, not a fixed spec, and go
  stale if the geometry changes without the doc changing with it.
