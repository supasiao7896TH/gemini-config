# CI/CD Templates

> ส่วนหนึ่งของ `vibe-coding-quality` §25.4
> **ของจริงที่ copy ไปใช้ได้เลยอยู่ที่ `design-lab/starter/.github/workflows/`**
> ไฟล์นี้อธิบายว่าแต่ละ job มีไว้ทำไม — อย่าคัดลอก YAML จากที่นี่ ให้ copy จาก starter
> เพื่อไม่ให้มี 2 แหล่งที่ drift ออกจากกัน

## ทำไม workflow ใน `design-lab/starter/.github/` ไม่ทำงานใน claude-config

GitHub อ่าน `.github/workflows/` **เฉพาะที่ root ของ repo** เท่านั้น ไฟล์ที่ฝังอยู่ลึกลงไป
จึงเป็นแค่ข้อความธรรมดา และจะ "มีชีวิต" ทันทีที่โฟลเดอร์ถูก copy ไปเป็น repo ของตัวเอง
— ทำให้เก็บ template ไว้ที่เดียวกับโค้ดตั้งต้นได้โดยไม่ต้องมี scaffolder แยก

## `ci.yml` — 3 job

### `check`
`npm ci` → `playwright install chromium` → `npm run check`
คือ gate หลัก ไม่เขียวไม่ deploy

### `cache-guard`
```bash
git diff --name-only HEAD^ HEAD | grep -qx 'index.html' || exit 0
git diff HEAD^ HEAD -- sw.js | grep -q '^+.*CACHE_NAME' \
  || { echo "::error::index.html เปลี่ยนแต่ CACHE_NAME ไม่ถูก bump"; exit 1; }
```

5 บรรทัด ปิดบักที่ **เอกสาร 3 skill บันทึกตรงกันว่าเกิดซ้ำ** — "deploy สำเร็จแต่หน้าเว็บ
ยังเป็นโค้ดเก่า" ซึ่งเสียเวลาไล่หาสาเหตุทุกครั้งเพราะทุกอย่างดูเหมือนสำเร็จหมด

ข้อจำกัดที่ต้องรู้: เทียบแค่ `HEAD^..HEAD` ถ้า push ทีเดียวหลาย commit
โดยที่ commit แรกแก้ `index.html` และ commit สุดท้ายไม่แก้ มันจะไม่จับ
— รับได้ เพราะกรณีที่เกิดจริงคือ "แก้แล้วลืม bump" ใน commit เดียว

### `deploy`
`needs: [check, cache-guard]` + `if: github.ref == 'refs/heads/main' && github.event_name == 'push'`

ลำดับใน job นี้สำคัญ:
1. **ฝัง build stamp** — `<meta name="app-version" content="<sha7> <วันที่>">`
   ทำให้ตอบคำถาม "แก้แล้วขึ้นจริงหรือยัง" ด้วยเครื่องได้ และปุ่มรายงานปัญหามีเวอร์ชันให้แนบ
2. `versions upload` แล้วค่อย `versions deploy` — แยก 2 ขั้นเพื่อให้ preview กับ production
   ใช้กลไกเดียวกัน ต่างกันแค่ขั้นที่สอง
3. **`curl` URL จริงแล้ว grep หา sha** — ยืนยันว่าสิ่งที่อยู่บน production คือ commit นี้จริง
   (retry 5 ครั้งห่างกัน 10 วิ เพราะ edge ใช้เวลากระจาย)

ต้องตั้ง repo variable `APP_URL` ก่อน ไม่งั้น step สุดท้ายจะข้ามไปเฉยๆ

## `preview.yml`

ทุก PR ได้ URL ชั่วคราวที่เปิดบนมือถือได้ **หลังจาก `npm run check` เขียวแล้วเท่านั้น**
— preview ไม่ใช่ทางลัดข้าม gate

นี่คือสิ่งที่ทำให้ข้อ "ทดสอบบนมือถือจริง ไม่ใช่แค่ DevTools" ใน §24.5 เกิดขึ้นได้ **ก่อน**
ของขึ้น production เป็นครั้งแรก ซึ่งเดิมทำไม่ได้เลยเพราะ push main = ขึ้น production ทันที

ใช้ Workers preview กับ **ทุกแอป** รวมถึงแอปที่ production อยู่บน GitHub Pages เพราะ
GH Pages ไม่มี PR preview ในตัว และ deploy ลงโฟลเดอร์ `preview/` ใน repo production
ทำให้ prod สกปรก

## `uptime.yml`

ดู `references/observability-and-issues.md`

## dependency audit + `dependabot.yml` (`starter-multifile` เท่านั้น)

ของจริงอยู่ที่ `design-lab/starter-multifile/.github/dependabot.yml` +
step `npm run audit` ใน `ci.yml` job `check` (ต่อจาก `npm ci` ก่อนติดตั้ง Chromium — เร็ว
ไม่ต้องรอ e2e ถ้า dependency มีช่องโหว่จริง)

ทำไมแยกจาก root `.github/dependabot.yml` ของ `claude-config` เอง (ที่ปิด npm ecosystem
ไว้จงใจ): root คือ devDependency ของ meta-repo (~6 ตัว ไม่มีอะไร ship ไปไหน) ส่วนที่นี่คือ
เทมเพลตที่ทุกแอปจริงถูก copy ไปใช้ (Vite/Vitest/Firebase SDK/Chart.js ฯลฯ) แล้ว deploy
ให้คนอื่นใช้งานจริง — ช่องโหว่ที่นี่กระทบผู้ใช้จริง ต่างเหตุผลกันจึงต่างการตัดสินใจกัน

Dependabot เปิดเฉพาะ npm, group `minor-and-patch` รวมเป็น PR เดียวต่อสัปดาห์กัน noise
(major แยกให้เห็นทีละตัว เพราะมักมี breaking change) `npm run audit` ใช้
`--audit-level=high` ไม่ใช่ `moderate` ด้วยเหตุผลเดียวกับที่ root จำกัดขอบเขต Dependabot —
กันไม่ให้ CI แดงบ่อยจนกลายเป็นของที่ถูกมองข้าม เป็น step แยกจาก `npm run check`/`check:local`
เพื่อไม่ให้ไปรวมกับวลี "lint + secret scan + unit + e2e" ที่ repo อื่นๆ (starter เดี่ยว,
`vibe-coding-core`, `vibe-coding-workflow`) อ้างถึงคำต่อคำ

## Secrets / variables ที่ต้องตั้ง

| ชื่อ | ประเภท | ใช้ที่ไหน |
|---|---|---|
| `CLOUDFLARE_API_TOKEN` | secret | ci.yml + preview.yml · จำกัดสิทธิ์แค่ "Edit Cloudflare Workers" |
| `APP_URL` | variable | ตรวจ build stamp หลัง deploy + uptime cron |

## GitHub Pages — เปลี่ยนวิธี deploy

เปลี่ยนจาก "Pages เสิร์ฟ branch ตรงๆ" เป็น `actions/upload-pages-artifact` +
`actions/deploy-pages` ที่รันหลัง `check` ผ่าน ได้ 2 อย่างพร้อมกัน:

1. deploy กลายเป็นสิ่งที่ **gate ได้** — เดิมมันเกิดขึ้นเองทันทีที่ push ไม่มีอะไรมาขวางได้
2. คุมได้ว่าไฟล์ไหนขึ้น public — `tests/`, `node_modules/`, `package.json` จะไม่หลุด
3. ผลพลอยได้: rollback กลายเป็นการกด **Re-run all jobs** ของ run เก่า

## เวอร์ชันของ action และ Node

ตัวอย่าง YAML ใน skill ถูกคัดลอกไปใช้กับโปรเจกต์ใหม่จริง ถ้าปล่อยให้แต่ละที่ตกยุคคนละจังหวะ
แอปใหม่แต่ละตัวจะได้ toolchain ไม่เหมือนกันโดยไม่มีใครรู้ — เกิดขึ้นจริงแล้ว 2026-09-02
(`claude-config` เป็น `@v7` แต่ starter ยังเป็น `@v4` · `node-version` มี 20/22/24 ปนกัน 3 ค่า)

`tools/check-standards.mjs` กฎข้อ 7 จึงบังคับว่า **ทุกที่ต้องใช้เลขเดียวกัน** โดยตั้งใจ
ไม่ตรึงว่าเลขนั้นต้องเป็นอะไร — ไม่งั้นตัว linter เองจะกลายเป็นของที่ต้องไล่อัปเดตตามอีกทีหนึ่ง

เวลาจะ bump ให้แก้ทุกที่พร้อมกันในคอมมิตเดียว แล้ว `npm run check:standards` จะยืนยันให้ว่าครบ

## กติกาที่ไม่ควรแก้

- **ไม่ตั้ง `retries` ใน Playwright** — เทสต์ที่ผ่านบ้างไม่ผ่านบ้างคือเทสต์ที่ต้องแก้
  ไม่ใช่ต้องรันซ้ำ · retry ทำให้ปัญหาจริงถูกกลบ
- **ไม่ใส่ Playwright ใน pre-commit hook** — ช้าเกิน 5 วิเมื่อไหร่ คนจะเริ่มพิมพ์ `--no-verify`
- **ไม่ให้ third-party CDN ที่เข้าไม่ถึงทำ CI แดง** — สุดท้ายจะโดนปิดเทสต์ทิ้งทั้งชุด
