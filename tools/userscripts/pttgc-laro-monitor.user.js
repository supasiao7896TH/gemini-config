// ==UserScript==
// @name         PTTGC Laro Quality Monitor (PTA Routine Alert)
// @namespace    https://pttgclaro.pttgcgroup.com/
// @version      1.0.1
// @description  ระบบตรวจสอบผลวิเคราะห์ Routine Lab PZ-402 (รอบ 16:00 น.) อัตโนมัติและแจ้งเตือน
// @author       Supasit.A Studio & Antigravity
// @match        *://pttgclaro.pttgcgroup.com/*
// @grant        GM_notification
// @grant        GM_setValue
// @grant        GM_getValue
// @run-at       document-end
// ==/UserScript==

(function () {
  "use strict";

  console.log("[Laro Monitor] Script เริ่มทำงานแล้วบน:", window.location.href);

  const CONFIG = {
    checkIntervalNormal: 5 * 60 * 1000,
    checkIntervalRush: 2 * 60 * 1000,
    targetHour: 16,
    pagesToMonitor: [
      { id: 2122, name: "PTA-1 Routine", tableId: 4799 },
      { id: 2121, name: "PTA-2 Routine", tableId: 4799 }
    ],
    targetParams: ["4-CBA", "p-TA", "b-value (Pro)", "BA"]
  };

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

  function createWidget() {
    if (document.getElementById("laro-monitor-widget")) return;

    const widget = document.createElement("div");
    widget.id = "laro-monitor-widget";
    widget.style.cssText = `
            position: fixed !important;
            bottom: 24px !important;
            right: 24px !important;
            z-index: 2147483647 !important;
            background: #FFFFFF !important;
            border: 2px solid #1D4ED8 !important;
            border-radius: 12px !important;
            box-shadow: 0 8px 24px rgba(0,0,0,0.18) !important;
            padding: 12px 16px !important;
            font-family: 'Noto Sans Thai', sans-serif, system-ui !important;
            font-size: 13px !important;
            color: #1E293B !important;
            display: flex !important;
            align-items: center !important;
            gap: 10px !important;
            cursor: default !important;
        `;
    widget.innerHTML = `
            <span style="display:inline-block; width:10px; height:10px; border-radius:50%; background:#10B981;" id="laro-status-dot"></span>
            <div>
                <strong style="color:#1D4ED8; font-size:13px; display:block;">Laro Lab Monitor</strong>
                <div id="laro-status-text" style="color:#64748B; font-size:11px;">พร้อมทำงาน (กำลังเตรียมตรวจ...)</div>
            </div>
            <button id="laro-manual-btn" style="background:#1D4ED8; color:#FFFFFF; border:none; border-radius:6px; padding:6px 10px; font-size:11px; cursor:pointer; font-weight:600; margin-left:6px;">เช็คทันที</button>
        `;

    (document.body || document.documentElement).appendChild(widget);
    console.log("[Laro Monitor] สร้าง UI Widget สำเร็จเรียบร้อย");

    document.getElementById("laro-manual-btn").addEventListener("click", () => {
      updateWidgetStatus("กำลังตรวจสอบด้วยตนเอง...", "#3B82F6");
      runQualityCheck();
    });
  }

  function updateWidgetStatus(text, dotColor = "#10B981") {
    const statusText = document.getElementById("laro-status-text");
    const dot = document.getElementById("laro-status-dot");
    if (statusText) statusText.innerText = text;
    if (dot) dot.style.background = dotColor;
  }

  function getTodayDateString() {
    const d = new Date();
    const year = d.getFullYear();
    const month = String(d.getMonth() + 1).padStart(2, "0");
    const day = String(d.getDate()).padStart(2, "0");
    return `${year}-${month}-${day}`;
  }

  async function fetchRoutineResults(pageId, tableId) {
    const today = getTodayDateString();
    const url = `/getReportResults?pageId=${pageId}&tableId=${tableId}&dateStart=${today}T00:00:00&dateEnd=${today}T23:59:59`;
    const res = await fetch(url, {
      headers: { Accept: "application/json, text/plain, */*" },
      credentials: "include"
    });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    return await res.json();
  }

  async function runQualityCheck() {
    const now = new Date();
    const timeStr = now.toLocaleTimeString("th-TH", { hour: "2-digit", minute: "2-digit" });

    for (const page of CONFIG.pagesToMonitor) {
      try {
        const data = await fetchRoutineResults(page.id, page.tableId);
        if (!Array.isArray(data) || data.length === 0) continue;

        const targetHourStr = `${String(CONFIG.targetHour).padStart(2, "0")}:00:00`;
        const records16 = data.filter(
          (item) => item.collectionDate && item.collectionDate.includes(targetHourStr)
        );

        if (records16.length === 0) {
          updateWidgetStatus(`ยังไม่มีข้อมูลรอบ 16:00 (${timeStr})`, "#F59E0B");
          continue;
        }

        const completedItems = records16.filter(
          (item) =>
            item.sampleStatus === "Completed" &&
            item.displayValue &&
            item.displayValue !== "Initial"
        );

        const hasCompletedMainParams = CONFIG.targetParams.every((paramName) =>
          completedItems.some((item) => item.aliasParam === paramName || item.paramId === paramName)
        );

        const alertKey = `ALERTED_${getTodayDateString()}_${page.id}_${CONFIG.targetHour}`;
        const hasAlerted = GM_getValue(alertKey, false);

        if (hasCompletedMainParams && !hasAlerted) {
          triggerLabCompleteNotification(page.name, records16);
          GM_setValue(alertKey, true);
          updateWidgetStatus(`✅ รอบ 16:00 ออกครบแล้ว (${timeStr})`, "#10B981");
          return;
        } else if (hasCompletedMainParams) {
          updateWidgetStatus(`รอบ 16:00 ออกครบแล้ว (${timeStr})`, "#10B981");
        } else {
          updateWidgetStatus(
            `รอบ 16:00 ยังไม่ครบ (${completedItems.length} ค่า, ${timeStr})`,
            "#F59E0B"
          );
        }
      } catch (err) {
        console.error(`[Laro Monitor] Error page ${page.id}:`, err);
        updateWidgetStatus(`ดึงข้อมูลไม่สำเร็จ (${timeStr})`, "#EF4444");
      }
    }
  }

  function triggerLabCompleteNotification(routineName, records) {
    playAlertSound();

    const findVal = (p) => {
      const found = records.find(
        (r) => (r.aliasParam === p || r.paramId === p) && r.displayValue !== "Initial"
      );
      return found ? `${found.displayValue} ${found.displayUnits || ""}`.trim() : "-";
    };

    const cba = findVal("4-CBA");
    const pta = findVal("p-TA");
    const bVal = findVal("b-value (Pro)");
    const summaryMsg = `4-CBA: ${cba} | p-TA: ${pta} | b*: ${bVal}`;

    GM_notification({
      title: `🔔 ผล Lab รอบ 16:00 ออกครบแล้ว! (${routineName})`,
      text: `ค่าวิเคราะห์ออกครบเรียบร้อยแล้วค่ะพี่ A:\n${summaryMsg}`,
      timeout: 15000,
      onclick: () => {
        window.focus();
      }
    });
  }

  function scheduleNextCheck() {
    const currentHour = new Date().getHours();
    const currentMinute = new Date().getMinutes();
    const isRushHour =
      (currentHour === 15 && currentMinute >= 50) ||
      currentHour === 16 ||
      (currentHour === 17 && currentMinute <= 15);
    const interval = isRushHour ? CONFIG.checkIntervalRush : CONFIG.checkIntervalNormal;

    setTimeout(() => {
      runQualityCheck();
      scheduleNextCheck();
    }, interval);
  }

  const readyTimer = setInterval(() => {
    if (document.body) {
      clearInterval(readyTimer);
      createWidget();
      runQualityCheck();
      scheduleNextCheck();
    }
  }, 500);
})();
