---
name: vibe-coding-firebase
description: >
  Firebase Stack Skill สำหรับ Online Web App · Real-Time · Multi-User — ใช้ร่วมกับ
  vibe-coding-core เมื่อแอปที่กำลังสร้าง (ใหม่หรือเพิ่มฟีเจอร์) ต้องการ Firestore
  real-time, Firebase Auth, FCM Push Notification, LINE WebView, หรือ GitHub
  Actions CI/CD โดยเฉพาะ หรือพูดถึงคำว่า Firebase / Firestore / real-time /
  หลาย user ตรงๆ
---

# Vibe Coding Firebase — Supasit.A Skill

> **Scope:** Online Web App · Real-Time Firestore · Firebase Auth · FCM · GitHub Actions
> **ใช้เมื่อ:** แอปต้องการ real-time หลาย user / Push Notification / LINE WebView
> **ใช้ร่วมกับ:** vibe-coding-core เสมอ

| | |
|---|---|
| **Version** | 6.3 |
| **Updated** | 2026-09 |
| **Brand** | A-Class WebCraft · Code • Share • Inspire · by Supasit.A |
| **Sections in this file** | §20 |
| **Related skills** | `vibe-coding-core` (§1–17) — โหลดร่วมกันเสมอ |

---

## § 20 · Online Web App Stack (Real-Time / Firebase)

> **WHY:** Local-First IndexedDB เหมาะกับแอปใช้คนเดียว แต่เมื่อต้องการ Real-Time หลาย User
> หรือ Push Notification ต้องเปลี่ยนมาใช้ Firebase Stack นี้แทน

### Tech Stack มาตรฐาน

| หมวด | เทคโนโลยี | หมายเหตุ |
|---|---|---|
| Frontend | Multi-File (Vite+ES Modules, ค่าเริ่มต้น) หรือ Single-File HTML (ข้อยกเว้น) + Tailwind CSS (CDN) + Vanilla JS | ใช้ stack เดียวกับที่เลือกไว้ใน `vibe-coding-core` §1 Step 0 |
| Database | **Firebase Firestore** (real-time `onSnapshot`) | Sync ทุก client อัตโนมัติ |
| Auth | **Firebase Anonymous Auth + `inMemoryPersistence`** | ⚠️ ห้ามใช้ default — LINE/FB WebView บล็อก IndexedDB |
| Push Notification | **Firebase Cloud Messaging (FCM)** + Cloud Functions v2 | ส่ง notification ข้าม device |
| Hosting | GitHub Pages *หรือ* Cloudflare Workers (static assets) | Cloudflare Workers deploy flow แยกไปอยู่ skill `cloudflare-workers-deploy` แล้ว (ใช้ได้แม้ไม่มี Firebase) |
| CI/CD | **GitHub Actions** | deploy Pages + Functions อัตโนมัติเมื่อ push to `main` (ดู "GitHub Actions Deploy Flow" ด้านล่าง) |
| PWA | Service Worker (`sw.js`) + `manifest.json` | เหมือนเดิม |

### กฎบังคับ (ห้ามข้าม)

```
1. Single HTML File: bump CACHE_NAME ใน sw.js (vX → v(X+1)) ทุกครั้งที่แก้โค้ด
   WHY: ถ้าไม่ bump → browser ยังใช้ cache เก่า → user เห็นโค้ดเก่าโดยไม่รู้ตัว
   Multi-File: ข้อนี้ไม่ต้องทำ — vite-plugin-pwa สร้าง service worker ให้เองทุก build
   (ดู vibe-coding-multifile §21 / design-lab/starter-multifile/README.md)

2. Firestore Rules ต้อง deploy manual แยกต่างหาก (หรือผ่าน CI ด้านล่าง)
   คำสั่ง: npx firebase-tools deploy --only firestore:rules

3. ใช้ inMemoryPersistence เสมอ
   WHY: LINE / FB / IG WebView บล็อก IndexedDB → Firebase default auth จะ fail

4. ไม่มี rule ไหน allow read/write: if true; เด็ดขาด — ดูตัวอย่าง rules จริงด้านล่าง
```

### Firebase Auth — inMemoryPersistence (บังคับ)

```javascript
import { initializeApp } from 'https://www.gstatic.com/firebasejs/11.6.0/firebase-app.js';
import {
  getAuth, signInAnonymously,
  inMemoryPersistence, setPersistence
} from 'https://www.gstatic.com/firebasejs/11.6.0/firebase-auth.js';

const auth = getAuth(app);
await setPersistence(auth, inMemoryPersistence); // ← set ก่อน signIn เสมอ
await signInAnonymously(auth);
```

### Firestore Schema

```
artifacts/{appId}/public/data/
├── {collection}/{docId}   ← ข้อมูลหลัก (ต้องมี ownerId ทุก document)
└── logs/{docId}           ← audit trail (create-only, immutable)
```

```javascript
// Real-Time onSnapshot Pattern
import { getFirestore, collection, onSnapshot } from '...firebase-firestore.js';

const db = getFirestore(app);
const colRef = collection(db, `artifacts/${APP_ID}/public/data/items`);

onSnapshot(colRef, (snapshot) => {
  snapshot.docChanges().forEach(change => {
    if (change.type === 'added')    UI_RENDERER.addItem(change.doc.data());
    if (change.type === 'modified') UI_RENDERER.updateItem(change.doc.data());
    if (change.type === 'removed')  UI_RENDERER.removeItem(change.doc.id);
  });
});
```

### Firestore Security Rules — ตัวอย่างจริง (auth-first, deny-by-default)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /artifacts/{appId}/public/data/{collection}/{docId} {
      allow read:   if request.auth != null;
      allow create: if request.auth != null
                    && request.resource.data.ownerId == request.auth.uid;
      allow update, delete: if request.auth != null
                    && resource.data.ownerId == request.auth.uid;
    }

    // audit trail — สร้างได้ แต่ห้ามแก้/ลบ แม้แต่เจ้าของเอง
    match /artifacts/{appId}/public/data/logs/{docId} {
      allow read:   if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if false;
    }

    // deny-by-default — path ที่ไม่ได้ระบุไว้ข้างบน ปิดหมด
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

> **WHY deny-by-default block ท้ายสุด:** ถ้าลืมเขียน rule ให้ collection ใหม่ที่เพิ่มทีหลัง
> Firestore default คือ "ไม่มี rule ตรงกัน = ปฏิเสธ" อยู่แล้ว แต่การเขียน `{document=**}` ปิดชัดเจน
> ป้องกันคนอื่นมาเขียน rule ใหม่ทับโดยไม่ตั้งใจเปิดกว้างเกินไป

### LINE / WebView Handling

```javascript
function detectWebView() {
  const ua = navigator.userAgent;
  return {
    isLINE: /Line\//i.test(ua),
    isFB  : /FBAN|FBAV/i.test(ua),
    isIG  : /Instagram/i.test(ua),
  };
}

function showWebViewWarning() {
  const wv = detectWebView();
  if (!wv.isLINE && !wv.isFB && !wv.isIG) return;
  const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent);
  const msg = isIOS
    ? '⚠️ กรุณาเปิดใน Safari เพื่อประสบการณ์ที่ดีที่สุด'
    : '⚠️ กรุณาเปิดใน Chrome เพื่อประสบการณ์ที่ดีที่สุด';
  UI_RENDERER.showBanner(msg, {
    action: 'คัดลอกลิงก์',
    onClick: () => navigator.clipboard.writeText(location.href)
  });
}
```

### GitHub Actions Deploy Flow

> ⚠️ **อัปเดตสำคัญ:** เวอร์ชันก่อนหน้าของ skill นี้ใช้ `firebase login:ci` เพื่อสร้าง
> `FIREBASE_TOKEN` แบบ long-lived — Firebase เริ่มเลิกแนะนำวิธีนี้เพราะ token ผูกกับบัญชี
> ส่วนตัวและมีสิทธิ์กว้างเกินความจำเป็น ให้ใช้ **Service Account + Workload Identity
> Federation** แทน (ไม่มี long-lived secret หลุดออกไปเลย)

```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [main]

jobs:
  deploy-pages:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./

  deploy-firebase:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write   # จำเป็นสำหรับ Workload Identity Federation
    steps:
      - uses: actions/checkout@v7
      - uses: actions/setup-node@v7
        with:
          node-version: 22
      - run: npm ci --prefix functions

      - id: auth
        uses: google-github-actions/auth@v2
        with:
          workload_identity_provider: ${{ secrets.WIF_PROVIDER }}
          service_account: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}

      - name: Deploy Firebase (Functions + Rules)
        run: |
          npx firebase-tools deploy --only functions,firestore:rules \
            --project ${{ secrets.FIREBASE_PROJECT_ID }}
```

```
Setup ครั้งเดียวต่อโปรเจกต์ (นอก CI):
  1. สร้าง Service Account ใน Google Cloud Console ที่มีสิทธิ์แค่ที่จำเป็น
     (Firebase Admin ของ project นี้เท่านั้น ไม่ใช่ Owner ทั้ง org)
  2. ตั้ง Workload Identity Federation ผูกกับ repo GitHub นี้โดยเฉพาะ
     (ดูขั้นตอนที่ google-github-actions/auth README) — ไม่มี key file ให้ต้องเก็บ/หมุนเวียนเลย
  3. ถ้า setup WIF ยังไม่สะดวก ทางเลือกรองคือ service-account JSON key เก็บใน
     GitHub Secrets (`credentials_json:`) + ตั้งเตือน rotate ทุก 90 วัน —
     แคบกว่า FIREBASE_TOKEN เดิมมาก แต่ยังต้อง manage key file เอง
```

> **หมายเหตุ:** ถ้า hosting เป็น **Cloudflare Workers** แทน GitHub Pages ให้ใช้ skill
> แยกต่างหาก **`cloudflare-workers-deploy`** แทน section นี้ — ย้ายออกไปเมื่อ 2569-08
> เพราะเนื้อหานั้นใช้ได้กับทุกเว็บแอป ไม่จำเป็นต้องมี Firebase/real-time เลย

### Decision Table — ใช้ Stack ไหน?

```
คำถาม                                       → Stack
──────────────────────────────────────────────────────────
ใช้คนเดียว, offline-first                  → Local-First (IndexedDB) — vibe-coding-core §2–3
หลาย user ดูข้อมูลเดียวกัน real-time       → Firebase Stack (§ 20 นี้)
ต้องการ Push Notification                  → Firebase Stack (§ 20 นี้)
เปิดใน LINE / แชร์ Link                    → Firebase Stack (§ 20 นี้)
ต้องการ Auth (login email/google)          → Firebase Stack + Auth Provider
```

---

*SKILL: vibe-coding-firebase v6.3 | Section: §20*
*Supasit.A × A-Class WebCraft | Code • Share • Inspire*
*Related: vibe-coding-core (โหลดร่วมกันเสมอ)*
*Updated: September 2026 (พ.ศ. 2569)*
