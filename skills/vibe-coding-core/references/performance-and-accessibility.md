# Performance & Accessibility Reference

> ส่วนหนึ่งของ `vibe-coding-core` — โหลดไฟล์นี้ก่อน deliver ทุกครั้ง (checklist ใน QA §16)

---

## Performance Patterns

```javascript
// Lazy load sections (ไม่ render ก่อนจำเป็น)
const LazySection = {
  load: async (id) => {
    if (document.getElementById(id)) return;
    const mod = await import(`./sections/${id}.js`);
    mod.render();
  }
};

// Debounce สำหรับ search input
const debounce = (fn, ms = 300) => {
  let t; return (...args) => { clearTimeout(t); t = setTimeout(() => fn(...args), ms); };
};

// Virtual scroll สำหรับ list ยาว (>200 items)
// ใช้ IntersectionObserver แทน scroll event
const observer = new IntersectionObserver((entries) => {
  entries.forEach(e => { if (e.isIntersecting) loadMore(); });
}, { threshold: 0.1 });
```

---

## Accessibility (ARIA)

```html
<!-- บังคับทุก interactive element -->
<button aria-label="เพิ่มรายการ" aria-pressed="false">
<input  aria-required="true" aria-describedby="hint-id">
<div    role="alert" aria-live="polite">  <!-- Toast / Status -->
<nav    aria-label="เมนูหลัก">
<img    alt="คำอธิบายภาพ">               <!-- ห้าม alt="" ยกเว้น decorative -->

<!-- Focus management (Modal) -->
<!-- trap focus ใน modal · คืน focus เมื่อปิด · Escape ปิดได้ -->
<!-- Keyboard: Tab/Shift+Tab navigate · Enter/Space activate -->

<!-- Color Contrast -->
<!-- text-primary  ≥ 7:1  (WCAG AAA) -->
<!-- text-secondary ≥ 4.5:1 (WCAG AA) -->
```
