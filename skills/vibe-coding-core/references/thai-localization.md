# Thai Localization Reference

> ส่วนหนึ่งของ `vibe-coding-core` — โหลดไฟล์นี้เมื่อแอปต้อง format วันที่/ตัวเลข/เงินภาษาไทย

```javascript
// วันที่ภาษาไทย (พ.ศ.)
const toThaiDate = (date) => {
  const d = new Date(date);
  return d.toLocaleDateString('th-TH', {
    year: 'numeric', month: 'long', day: 'numeric'
  }); // → "28 มิถุนายน 2569"
};

// ตัวเลขไทย (ถ้าต้องการ)
const toThaiNum = (n) => n.toLocaleString('th-TH');

// สกุลเงิน
const toBaht = (n) => `฿${n.toLocaleString('th-TH', { minimumFractionDigits: 2 })}`;
```
