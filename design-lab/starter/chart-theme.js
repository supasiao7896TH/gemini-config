/* ============================================================
   ธีมกราฟ Chart.js ที่อ่านสีจาก CSS variable ของแอป
   เปลี่ยนธีมสว่าง/มืด แล้วกราฟเปลี่ยนตามโดยไม่ต้องแก้โค้ดกราฟ
   วิธีใช้:
     var chart = new Chart(ctx, CHART_THEME.line({ labels: [...], data: [...] }));
     document.addEventListener('themechange', function(){ CHART_THEME.refresh(chart); });
   ============================================================ */
var CHART_THEME = (function () {
  function token(name) {
    return getComputedStyle(document.documentElement).getPropertyValue(name).trim();
  }
  function palette() {
    return {
      accent: token("--accent"),
      accent2: token("--accent-2"),
      ok: token("--ok"), warn: token("--warn"), crit: token("--crit"),
      grid: token("--border"), tick: token("--text-3"),
      surface: token("--surface"), text: token("--text"),
      font: "'Noto Sans Thai', system-ui, sans-serif"
    };
  }
  function baseOptions() {
    var p = palette();
    return {
      responsive: true, maintainAspectRatio: false,
      animation: { duration: 160 },
      plugins: {
        legend: { labels: { color: p.tick, font: { family: p.font, size: 12 }, boxWidth: 10, usePointStyle: true } },
        tooltip: {
          backgroundColor: p.text, titleColor: p.surface, bodyColor: p.surface,
          titleFont: { family: p.font }, bodyFont: { family: p.font },
          padding: 10, cornerRadius: 9, displayColors: false
        }
      },
      scales: {
        x: { grid: { color: p.grid, drawBorder: false }, ticks: { color: p.tick, font: { family: p.font, size: 11 } } },
        y: { grid: { color: p.grid, drawBorder: false }, ticks: { color: p.tick, font: { family: p.font, size: 11 } } }
      }
    };
  }
  return {
    palette: palette,
    options: baseOptions,
    line: function (cfg) {
      var p = palette();
      return {
        type: "line",
        data: { labels: cfg.labels, datasets: [{
          label: cfg.label || "", data: cfg.data,
          borderColor: p.accent, backgroundColor: p.accent + "1F",
          borderWidth: 2.5, tension: .3, fill: true, pointRadius: 0, pointHoverRadius: 5
        }]},
        options: baseOptions()
      };
    },
    bar: function (cfg) {
      var p = palette();
      return {
        type: "bar",
        data: { labels: cfg.labels, datasets: [{
          label: cfg.label || "", data: cfg.data,
          backgroundColor: p.accent, borderRadius: 6, borderSkipped: false
        }]},
        options: baseOptions()
      };
    },
    /* เรียกหลังสลับธีม — อ่าน token ใหม่แล้ววาดซ้ำ */
    refresh: function (chart) {
      var p = palette();
      chart.data.datasets.forEach(function (ds) {
        if (ds.type === "bar" || chart.config.type === "bar") ds.backgroundColor = p.accent;
        else { ds.borderColor = p.accent; ds.backgroundColor = p.accent + "1F"; }
      });
      chart.options = baseOptions();
      chart.update("none");
    }
  };
})();
