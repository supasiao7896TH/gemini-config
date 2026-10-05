# Observability + Issue Tracking

> ส่วนหนึ่งของ `vibe-coding-quality` §25.5 · ขนาดที่พอดีกับ "เครื่องมือภายในโรงงาน ผู้ใช้ ~5 คน"

## ปัญหาที่แก้

เดิม `DEBUG_MODULE` เก็บ log ใน memory เท่านั้น หายทันทีที่ reload หน้า (2026-09-10 แก้แล้ว
— ตอนนี้ persist ผ่าน `STORAGE_ENGINE` ที่มีอยู่แล้ว ไม่ได้เปิด IndexedDB เส้นที่สอง ดู "5 ·
Persist ข้าม reload" ด้านล่าง) แต่ **ยังไม่มีใครอ่านจากระยะไกลได้** แปลว่าถ้าเพื่อนร่วมงาน
เจอ error วิธีเดียวที่จะรู้คือเขาเดินมาบอก และตอนเดินมาบอกก็จำไม่ได้แล้วว่ากดอะไร —
ปุ่ม "รายงานปัญหา" (ข้อ 2 ด้านล่าง) คือทางแก้ที่เลือกไว้ ไม่ใช่การ auto-upload

## 5 อย่างที่ทำ (ฟรีทั้งหมด)

### 1 · เปิด Workers Logs
แก้ไขแล้ว (2026-09-10) — เดิม `wrangler.jsonc` ของ `cloudflare-workers-deploy` skill ตั้ง
`observability.enabled: false` ทั้งที่ `logs.enabled: true` ข้างในขัดกันเอง (parent `false`
ทำให้ log ไม่ทำงานจริงแม้ child จะ `true`) ตอนนี้ทั้ง `design-lab/starter-multifile` และ
ตัวอย่างใน `cloudflare-workers-deploy` skill ตั้ง `enabled: true` ตรงกันแล้ว — log ฝั่ง server ฟรี

### วิธีดู log จริง
`wrangler tail <worker-name>` (stream สดจาก terminal) หรือ Cloudflare dashboard →
Workers & Pages → Worker นั้น → tab Logs (retention เช็คในหน้า dashboard เอง)

### 2 · ปุ่ม "รายงานปัญหา" → GitHub issue ที่กรอกไว้แล้ว
มีใน `design-lab/starter/index.html` แล้ว ตั้ง `APP_CONFIG.ISSUE_URL` ก็ใช้ได้

แนบให้อัตโนมัติ: log 20 บรรทัดล่าสุด · build stamp · user agent

ทำไมวิธีนี้ ไม่ใช่ส่ง log ขึ้น server เอง:

| | ปุ่มเปิด issue | ส่ง log อัตโนมัติ |
|---|---|---|
| ต้องมี backend | ไม่ | ต้องมี |
| ต้องแก้ CSP | ไม่ | ต้อง (`connect-src`) |
| ข้อมูลออกจากเครื่องเมื่อไหร่ | เมื่อผู้ใช้กดเอง | ตลอดเวลา |
| ได้บริบทว่า "กดอะไรก่อน" | ได้ (ผู้ใช้พิมพ์เอง) | ไม่ได้ |
| กลายเป็นงานที่ติดตามได้ | ใช่ เป็น issue เลย | ต้องมีคนไปอ่าน log |

### 3 · Global error boundary
`window.onerror` + `unhandledrejection` → `DEBUG_MODULE.log()` → toast
มีใน starter แล้ว (§2 สัญญาไว้ตั้งแต่แรกแต่ไม่เคย implement)

`DEBUG_MODULE` เก็บ ring buffer 20 รายการ **เสมอ** แม้ไม่ได้เปิด `?debug=1`
เพราะตอนเกิด error ผู้ใช้ไม่มีทางย้อนไปเปิด debug แล้วทำให้พังซ้ำได้

### 4 · Uptime ด้วย GitHub Actions cron

```yaml
name: Uptime
on:
  schedule: [{ cron: "0 * * * *" }]   # ทุกชั่วโมง (UTC)
  workflow_dispatch:
permissions: { issues: write }
jobs:
  ping:
    runs-on: ubuntu-latest
    steps:
      - name: เรียก URL จริง
        id: ping
        run: curl -sfo /dev/null --max-time 20 "${{ vars.APP_URL }}"
        continue-on-error: true
      - name: เปิด/อัปเดต issue เมื่อล่ม
        if: steps.ping.outcome == 'failure'
        uses: actions/github-script@v7
        with:
          script: |
            const title = "แอปเข้าไม่ได้";
            const { data } = await github.rest.issues.listForRepo({
              ...context.repo, state: "open", labels: "deploy"
            });
            const existing = data.find(i => i.title === title);
            const body = `ตรวจไม่ผ่านเมื่อ ${new Date().toISOString()} — ${{ vars.APP_URL }}`;
            if (existing) {
              await github.rest.issues.createComment({
                ...context.repo, issue_number: existing.number, body });
            } else {
              await github.rest.issues.create({
                ...context.repo, title, body, labels: ["deploy"] });
            }
```

ไม่แม่นระดับนาที — ซึ่งไม่สำคัญสำหรับเครื่องมือภายใน และไม่ต้องสมัคร service ใหม่

### 5 · Persist ข้าม reload

เดิม ring buffer อยู่ใน memory เท่านั้น — reload หน้าปุ๊บ log หายหมด ทั้งที่ผู้ใช้เพิ่งเจอ
error ไปหมาดๆ ตอนนี้ `DEBUG_MODULE.log()` เขียนทับ record เดียวใน store `debugLog`
ผ่าน `STORAGE_ENGINE` ที่มีอยู่แล้วทุกครั้งที่ log (ไม่เปิด IndexedDB เส้นที่สอง) และ
`DEBUG_MODULE.hydrate()` ถูกเรียกเป็นบรรทัดแรกของ `APP_CORE.init()` (fire-and-forget)
ดึงของเดิมกลับมา **merge** กับ ring ปัจจุบันแทนที่จะทับ — กัน log ที่เกิดขึ้นระหว่างรอ
`hydrate()` (เช่น log "พร้อมใช้งาน" ท้าย `init()`) หายไป

**ยังไม่กระทบแถว "Sentry / Rollbar" ในตาราง "สิ่งที่จงใจไม่ทำ" ด้านล่าง** — ปุ่ม
"รายงานปัญหา" ยังเป็นทางเดียวที่ log ออกจากเครื่อง (เมื่อผู้ใช้กดเอง) ไม่มีอะไรถูก
auto-upload ไปที่ไหนใหม่ การเปลี่ยนแปลงนี้แค่ทำให้ log ที่มีอยู่แล้วไม่หายตอน reload

## Issue tracking

**ลบหัวข้อ `## Known Issues` ออกจาก `CLAUDE.md` แล้วใส่ลิงก์แทน** — หัวข้อนั้นเป็นสำเนา
ของระบบที่มีอยู่แล้ว และการันตีว่าจะตกยุคเพราะไม่มีอะไรบังคับให้อัปเดต

| label | ใช้เมื่อ |
|---|---|
| `bug` | ทำงานไม่เหมือนที่ควรจะเป็น |
| `enhancement` | อยากได้เพิ่ม |
| `deploy` | ปัญหาตอน deploy / แอปเข้าไม่ได้ (uptime cron ใช้ label นี้) |

commit ที่แก้ issue ให้อ้างเลขไว้: `fix: กัน KPI คำนวณผิดตอนไม่มีข้อมูล (#12)`
→ GitHub ปิด issue ให้เอง และได้เส้นเชื่อมจากบักไปหาบรรทัดที่แก้

## สิ่งที่จงใจไม่ทำ และเหตุผล

| ไม่ทำ | เหตุผล |
|---|---|
| Sentry / Rollbar | ต้องแก้ CSP + โหลด script บุคคลที่สาม + ข้อมูลโรงงานไปอยู่ cloud คนอื่น · คุ้มเมื่อแอปเกิน ~20 คน หรือกลายเป็น multi-user Firestore |
| UptimeRobot / Pingdom | cron ข้างบนทำได้แล้ว ไม่ต้องมีบัญชีใหม่ |
| Google Analytics / Plausible | พี่ A รู้จักผู้ใช้ทุกคนเป็นรายบุคคล เดินไปถามได้ข้อมูลดีกว่า pageview |
| Workers Analytics Engine | คำตอบที่ถูกถ้าวันหนึ่งต้องการจริง แต่ยังไม่ถึงวันนั้น |
| Dashboard / alerting / SLO / on-call | ผู้ใช้หลักสิบคนที่นั่งอยู่ตึกเดียวกัน |
