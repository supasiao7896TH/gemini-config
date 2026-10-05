/* Chart.js theming — อ่านสีจาก CSS variable ของแอป (ไม่ใช่ 1 ใน 9 โมดูลหลัก
   ใช้เฉพาะโปรเจกต์ที่มีกราฟ — ลบไฟล์นี้ทิ้งได้ถ้าไม่ได้ใช้ Chart.js)
   วิธีใช้:
     import { ChartTheme } from "./modules/chart-theme.js";
     const chart = new Chart(ctx, ChartTheme.line({ labels: [...], data: [...] }));
     document.addEventListener("themechange", () => ChartTheme.refresh(chart));

   Chart.js เองยังโหลดผ่าน CDN script tag ใน index.html เหมือนเดิม (ดู "สิ่งที่ไม่ต้องแตะ"
   ใน vibe-coding-multifile §21) — ไฟล์นี้จึงประกาศ global ด้านล่างแทนการ import จาก npm */
/* global Chart */

function token(name) {
  return getComputedStyle(document.documentElement).getPropertyValue(name).trim();
}

function palette() {
  return {
    accent: token("--accent"),
    accent2: token("--accent-2"),
    ok: token("--ok"),
    warn: token("--warn"),
    crit: token("--crit"),
    grid: token("--border"),
    tick: token("--text-3"),
    surface: token("--surface"),
    text: token("--text"),
    font: "'Noto Sans Thai', system-ui, sans-serif"
  };
}

function baseOptions() {
  const p = palette();
  return {
    responsive: true,
    maintainAspectRatio: false,
    animation: { duration: 160 },
    plugins: {
      legend: {
        labels: {
          color: p.tick,
          font: { family: p.font, size: 12 },
          boxWidth: 10,
          usePointStyle: true
        }
      },
      tooltip: {
        backgroundColor: p.text,
        titleColor: p.surface,
        bodyColor: p.surface,
        titleFont: { family: p.font },
        bodyFont: { family: p.font },
        padding: 10,
        cornerRadius: 9,
        displayColors: false
      }
    },
    scales: {
      x: {
        grid: { color: p.grid, drawBorder: false },
        ticks: { color: p.tick, font: { family: p.font, size: 11 } }
      },
      y: {
        grid: { color: p.grid, drawBorder: false },
        ticks: { color: p.tick, font: { family: p.font, size: 11 } }
      }
    }
  };
}

export const ChartTheme = {
  palette,
  options: baseOptions,
  line(cfg) {
    const p = palette();
    return {
      type: "line",
      data: {
        labels: cfg.labels,
        datasets: [
          {
            label: cfg.label || "",
            data: cfg.data,
            borderColor: p.accent,
            backgroundColor: `${p.accent}1F`,
            borderWidth: 2.5,
            tension: 0.3,
            fill: true,
            pointRadius: 0,
            pointHoverRadius: 5
          }
        ]
      },
      options: baseOptions()
    };
  },
  bar(cfg) {
    const p = palette();
    return {
      type: "bar",
      data: {
        labels: cfg.labels,
        datasets: [
          {
            label: cfg.label || "",
            data: cfg.data,
            backgroundColor: p.accent,
            borderRadius: 6,
            borderSkipped: false
          }
        ]
      },
      options: baseOptions()
    };
  },
  /* เรียกหลังสลับธีม — อ่าน token ใหม่แล้ววาดซ้ำ */
  refresh(chart) {
    const p = palette();
    chart.data.datasets.forEach((ds) => {
      if (ds.type === "bar" || chart.config.type === "bar") ds.backgroundColor = p.accent;
      else {
        ds.borderColor = p.accent;
        ds.backgroundColor = `${p.accent}1F`;
      }
    });
    chart.options = baseOptions();
    chart.update("none");
  }
};
