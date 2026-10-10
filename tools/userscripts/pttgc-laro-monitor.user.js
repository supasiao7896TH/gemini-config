// ==UserScript==
// @name         PTTGC Laro Quality Monitor & Auto-Refresh (PTA Routine)
// @namespace    https://pttgclaro.pttgcgroup.com/
// @version      1.3.0
// @description  ระบบ Auto-Refresh (5 นาที) และตรวจสอบผล Lab PZ-402 ทั้ง 8 รอบ (01:00, 04:00, 07:00, 10:00, 13:00, 16:00, 19:00, 22:00) วนลูปไม่รู้จบ
// @author       Supasit.A Studio & Antigravity
// @match        https://pttgclaro.pttgcgroup.com/*
// @match        http://pttgclaro.pttgcgroup.com/*
// @include      *://pttgclaro.pttgcgroup.com/*
// @grant        GM_notification
// @grant        GM_setValue
// @grant        GM_getValue
// @run-at       document-end
// ==/UserScript==

(function () {
  "use strict";

  console.log("[Laro Monitor] Script v1.3.0 loaded on:", window.location.href);

  const CONFIG = {
    refreshSeconds: 300, // นับถอยหลัง 5 นาที (300 วินาที)
    labRounds: ["01:00", "04:00", "07:00", "10:00", "13:00", "16:00", "19:00", "22:00"],
    targetParams: ["4-CBA", "p-TA", "BA", "b-value (Pro)"]
  };

  let remainingSeconds = CONFIG.refreshSeconds;
  let isPaused = false;
  let countdownTimer = null;

  // -------------------------------------------------------------------------
  // 1. Audio Notification (Web Audio API)
  // -------------------------------------------------------------------------
  function playAlertSound() {
    try {
      const ctx = new (window.AudioContext || window.webkitAudioContext)();
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.type = "sine";
      osc.frequency.setValueAtTime(587.33, ctx.currentTime);
      osc.frequency.setValueAtTime(880, ctx.currentTime + 0.15);
      gain.gain.setValueAtTime(0.2, ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.6);
      osc.start();
      osc.stop(ctx.currentTime + 0.6);
    } catch (e) {
      console.warn("[Laro Monitor] Audio error", e);
    }
  }

  function getTodayString() {
    const d = new Date();
    const y = d.getFullYear();
    const m = String(d.getMonth() + 1).padStart(2, "0");
    const day = String(d.getDate()).padStart(2, "0");
    return `${y}-${m}-${day}`;
  }

  // -------------------------------------------------------------------------
  // 2. In-Place Table Refresh (กดปุ่ม OK บนหน้าจอเพื่อดึงข้อมูลสดโดยหน้าไม่ดับ)
  // -------------------------------------------------------------------------
  function triggerInPlaceRefresh() {
    const buttons = Array.from(document.querySelectorAll("button, .dx-button"));
    const okBtn = buttons.find((b) => b.innerText && b.innerText.trim() === "OK");
    const refreshIcon = document.querySelector(
      ".dx-icon-refresh, [title*='Refresh'], [title*='รีเฟรช']"
    );

    if (okBtn) {
      console.log("[Laro Monitor] กดปุ่ม OK เพื่อโหลดข้อมูลใหม่...");
      okBtn.click();
    } else if (refreshIcon) {
      console.log("[Laro Monitor] กดปุ่ม Refresh เพื่อโหลดข้อมูลใหม่...");
      refreshIcon.click();
    } else {
      console.log("[Laro Monitor] ไม่พบปุ่มบนจอ สั่ง location.reload()...");
      window.location.reload();
      return;
    }

    // รีเซ็ตเวลานับถอยหลังกลับไปที่ 5 นาทีทันที
    remainingSeconds = CONFIG.refreshSeconds;
    updateCountdownUI();

    // รอให้ Angular โหลดข้อมูลเสร็จ 2 วินาทีแล้วสแกนผลใหม่
    setTimeout(() => {
      const res = scanTableData();
      updateWidgetInfo(res);
    }, 2000);
  }

  // -------------------------------------------------------------------------
  // 3. DOM Lab Data Scanner
  // -------------------------------------------------------------------------
  function scanTableData() {
    const rows = document.querySelectorAll("tr");
    let latestCompleted = null;
    let nextPending = null;
    const completedRounds = [];

    rows.forEach((row) => {
      const text = row.innerText || "";
      for (const round of CONFIG.labRounds) {
        if (text.includes(round)) {
          const isCompleted = text.includes("Completed");
          const isInitial = text.includes("Initial");

          if (isCompleted) {
            completedRounds.push(round);
            latestCompleted = round;

            const alertKey = `ALERTED_${getTodayString()}_${round}`;
            const alreadyAlerted =
              typeof GM_getValue !== "undefined"
                ? GM_getValue(alertKey, false)
                : sessionStorage.getItem(alertKey);

            if (!alreadyAlerted) {
              triggerRoundCompleteAlert(round, row);
              if (typeof GM_setValue !== "undefined") {
                GM_setValue(alertKey, true);
              } else {
                sessionStorage.setItem(alertKey, "true");
              }
            }
          } else if (isInitial && !nextPending) {
            nextPending = round;
          }
        }
      }
    });

    return { latestCompleted, nextPending, countCompleted: completedRounds.length };
  }

  function triggerRoundCompleteAlert(round, rowElement) {
    playAlertSound();
    const rowText = rowElement ? rowElement.innerText.replace(/\s+/g, " ") : "";
    const title = `🔔 ผล Lab PZ-402 รอบ ${round} น. ออกแล้ว!`;
    const message = `ตรวจพบสถานะ (Completed) ของรอบ ${round} น. เรียบร้อยแล้วค่ะพี่ A`;

    if (typeof GM_notification !== "undefined") {
      GM_notification({
        title: title,
        text: `${message}\n${rowText.substring(0, 100)}...`,
        timeout: 15000,
        onclick: () => window.focus()
      });
    } else {
      alert(`${title}\n${message}`);
    }
  }

  // -------------------------------------------------------------------------
  // 4. UI Widget (Supasit.A Studio)
  // -------------------------------------------------------------------------
  function injectWidget() {
    if (document.getElementById("laro-monitor-widget")) return;

    const widget = document.createElement("div");
    widget.id = "laro-monitor-widget";
    widget.style.cssText = `
      position: fixed !important;
      bottom: 20px !important;
      right: 20px !important;
      z-index: 2147483647 !important;
      background: #FFFFFF !important;
      border: 1.5px solid #1D4ED8 !important;
      border-radius: 13px !important;
      box-shadow: 0 10px 25px rgba(0,0,0,0.15) !important;
      padding: 12px 16px !important;
      font-family: 'Noto Sans Thai', sans-serif, system-ui !important;
      font-size: 13px !important;
      color: #1E293B !important;
      min-width: 260px !important;
      user-select: none !important;
    `;

    widget.innerHTML = `
      <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:8px;">
        <div style="display:flex; align-items:center; gap:8px;">
          <span id="laro-dot" style="display:inline-block; width:10px; height:10px; border-radius:50%; background:#10B981;"></span>
          <strong style="color:#1D4ED8; font-size:13px; font-weight:700;">Laro Monitor & Refresh</strong>
        </div>
        <span id="laro-timer-badge" style="background:#F1F5F9; color:#475569; font-size:11px; padding:2px 8px; border-radius:999px; font-weight:600;">05:00</span>
      </div>

      <div style="font-size:12px; color:#475569; line-height:1.6; margin-bottom:10px;">
        <div>รอบล่าสุด: <strong id="laro-latest-round" style="color:#059669;">-</strong></div>
        <div>กำลังรอผล: <strong id="laro-next-round" style="color:#D97706;">-</strong></div>
      </div>

      <div style="display:flex; gap:6px;">
        <button id="laro-refresh-btn" style="flex:1; background:#1D4ED8; color:#FFFFFF; border:none; border-radius:999px; padding:6px 12px; font-size:11px; font-weight:600; cursor:pointer;">
          🔄 รีเฟรชทันที
        </button>
        <button id="laro-pause-btn" style="background:#F1F5F9; color:#475569; border:1px solid #CBD5E1; border-radius:999px; padding:6px 10px; font-size:11px; font-weight:600; cursor:pointer;">
          ⏸️ หยุด
        </button>
      </div>
    `;

    (document.body || document.documentElement).appendChild(widget);

    document.getElementById("laro-refresh-btn").addEventListener("click", () => {
      triggerInPlaceRefresh();
    });

    document.getElementById("laro-pause-btn").addEventListener("click", () => {
      isPaused = !isPaused;
      const pauseBtn = document.getElementById("laro-pause-btn");
      const dot = document.getElementById("laro-dot");
      if (isPaused) {
        pauseBtn.innerText = "▶️ ต่อ";
        pauseBtn.style.background = "#FEF3C7";
        pauseBtn.style.color = "#92400E";
        dot.style.background = "#F59E0B";
      } else {
        pauseBtn.innerText = "⏸️ หยุด";
        pauseBtn.style.background = "#F1F5F9";
        pauseBtn.style.color = "#475569";
        dot.style.background = "#10B981";
      }
    });
  }

  function updateWidgetInfo(scanResult) {
    const latestEl = document.getElementById("laro-latest-round");
    const nextEl = document.getElementById("laro-next-round");

    if (latestEl) {
      latestEl.innerText = scanResult.latestCompleted
        ? `${scanResult.latestCompleted} น. (Completed)`
        : "ยังไม่มีรอบที่เสร็จ";
    }

    if (nextEl) {
      nextEl.innerText = scanResult.nextPending
        ? `${scanResult.nextPending} น. (Initial)`
        : "ครบทุกรอบแล้ว";
    }
  }

  function updateCountdownUI() {
    const timerBadge = document.getElementById("laro-timer-badge");
    if (!timerBadge) return;

    if (isPaused) {
      timerBadge.innerText = "PAUSED";
      return;
    }

    const mins = String(Math.floor(remainingSeconds / 60)).padStart(2, "0");
    const secs = String(remainingSeconds % 60).padStart(2, "0");
    timerBadge.innerText = `${mins}:${secs}`;
  }

  // -------------------------------------------------------------------------
  // 5. Main Loop & Perpetual Timer (วนลูปไม่รู้จบ)
  // -------------------------------------------------------------------------
  function startCountdown() {
    if (countdownTimer) clearInterval(countdownTimer);

    countdownTimer = setInterval(() => {
      if (!isPaused) {
        remainingSeconds--;
        updateCountdownUI();

        if (remainingSeconds <= 0) {
          console.log("[Laro Monitor] ครบ 5 นาที สั่งรีเฟรชข้อมูลในหน้าแบบ In-Place...");
          triggerInPlaceRefresh();
        }
      }
    }, 1000);
  }

  setInterval(() => {
    injectWidget();
    const result = scanTableData();
    updateWidgetInfo(result);
  }, 2000);

  setTimeout(() => {
    injectWidget();
    const result = scanTableData();
    updateWidgetInfo(result);
    startCountdown();
  }, 1000);
})();
