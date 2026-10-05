# Architecture Blueprint Template

> ส่วนหนึ่งของ `vibe-coding-core` — ใช้ใน § 1 Step 3 (Architecture Blueprint)

```markdown
## 🏗️ Architecture Blueprint — [ชื่อแอป]

### Target & Platform
- Device  : [Mobile / PC / Responsive]
- Network : [Online-only / Offline-first / Hybrid]
- Auth    : [Anonymous / Firebase Auth / None]

### Modules (เลือกเท่าที่ใช้)
| Module | ใช้ | หน้าที่ |
|--------|-----|---------|
| APP_CONFIG | ✅ | Config, CDN, tokens |
| STATE_STORE | ✅ | Reactive state |
| STORAGE_ENGINE | ✅ | IndexedDB |
| CLOUD_SYNC_MANAGER | ⬜ | Firestore sync |
| AUTH_PROVIDER | ⬜ | Login system |
| GEMINI_AI_BRIDGE | ✅ | AI features |
| UI_RENDERER | ✅ | Components |
| DEBUG_MODULE | ✅ | Logging |
| APP_CORE | ✅ | Init + routing |

### Data Schema (IndexedDB)
```
Store: [store_name]
  id        : string (PK)
  [field]   : type
  createdAt : timestamp
  updatedAt : timestamp
  _syncStatus: 'pending' | 'synced' | 'error'
```

### Pages / Views
1. [หน้าหลัก] — [คำอธิบาย]
2. [หน้าที่ 2]  — [คำอธิบาย]

### Key Features
- [ ] [Feature 1]
- [ ] [Feature 2]

### Test Plan
> ตอบก่อนเขียนโค้ด ไม่ใช่หลัง — ถ้าตอบไม่ได้ว่าจะพิสูจน์ยังไงว่ามันถูก
> แปลว่ายังไม่รู้ว่า "ถูก" แปลว่าอะไร

| จะพิสูจน์อะไร | ชั้นไหน | ทำอะไรแล้วมันต้องแดง |
|---|---|---|
| [logic หลักของแอปนี้] | unit | [เปลี่ยนอะไรแล้วเทสต์ต้องจับได้] |
| [กฎ §8 ที่เกี่ยวกับแอปนี้] | unit | |
| contrast/44px/โฟกัส ทั้ง 2 ธีม | e2e | ได้ฟรีจาก starter |

> ทุกแถว "unit" ในตารางนี้ = เทสต์ที่ต้องเขียนและพิสูจน์ว่าแดงจริงที่ Step 5a
> (`vibe-coding-core` §1) **ก่อน** logic ใดๆ ถูกเขียน — ไม่ใช่แค่แผนบนกระดาษ

### Definition of Done
```
[ ] npm run check เขียว
[ ] เทสต์ใหม่ถูกพิสูจน์แล้วว่าแดงได้จริง
[ ] sa-code-reviewer ไม่เหลือ 🔴
[ ] เปิด preview URL บนมือถือจริงแล้ว
[ ] รู้คำสั่ง rollback ก่อน deploy
```
> รายละเอียด: `vibe-coding-quality` §25.3

### Roadmap Phases
① Local-First HTML+IndexedDB
② AI Intelligence (Gemini BYOK)
③ Cloud Sync (Firebase)
④ Deploy GitHub Pages
```
