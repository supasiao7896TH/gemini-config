// Antigravity CLI Statusline renderer - Option 1: Smart Dev (with Session Duration)
// Reads agent JSON state from stdin and outputs a formatted statusline.

import fs from "node:fs";
import { execSync } from "node:child_process";

function getBaseName(p) {
  if (!p || typeof p !== "string") return "";
  const cleaned = p.replace(/[\/\\]+$/, "");
  const parts = cleaned.split(/[\/\\]/);
  return parts[parts.length - 1] || "";
}

function getSessionDurationStr() {
  const ppid = process.ppid;
  const tmpDir = process.env.TEMP || process.env.TMP || "C:\\Temp";
  const sessionFile = `${tmpDir}\\agy_session_${ppid}.txt`;

  let startTime = 0;
  try {
    if (fs.existsSync(sessionFile)) {
      const content = fs.readFileSync(sessionFile, "utf8").trim();
      const ts = parseInt(content, 10);
      if (!isNaN(ts) && ts > 0) startTime = ts;
    }
  } catch (_) {}

  if (!startTime) {
    startTime = Date.now();
    try {
      if (ppid) {
        const out = execSync(
          `powershell -NoProfile -Command "(Get-Process -Id ${ppid}).StartTime.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')"`,
          { encoding: "utf8", timeout: 1000 }
        ).trim();
        const parsed = Date.parse(out);
        if (!isNaN(parsed) && parsed > 0) {
          startTime = parsed;
        }
      }
    } catch (_) {}

    try {
      fs.writeFileSync(sessionFile, String(startTime), "utf8");
    } catch (_) {}
  }

  const elapsedMs = Math.max(0, Date.now() - startTime);
  const totalMins = Math.floor(elapsedMs / 60000);
  const hrs = Math.floor(totalMins / 60);
  const mins = totalMins % 60;
  return hrs > 0 ? `${hrs}h ${String(mins).padStart(2, "0")}m` : `${mins}m`;
}

let inputData = "";

process.stdin.setEncoding("utf8");

process.stdin.on("data", (chunk) => {
  inputData += chunk;
});

process.stdin.on("end", () => {
  if (!inputData.trim()) {
    process.exit(0);
  }

  try {
    const data = JSON.parse(inputData);
    const parts = [];

    // 1. Model
    const model = data.model?.display_name || data.model?.name || "Gemini";
    parts.push(`⚡ ${model}`);

    // 2. Context Window usage %
    if (data.context_window?.used_percentage !== undefined) {
      const pct = Number(data.context_window.used_percentage).toFixed(1);
      parts.push(`🪙 ${pct}%`);
    }

    // 3. 5-Hour Quota & Countdown
    const q5 = data.quota?.["gemini-5h"];
    if (q5 && typeof q5.remaining_fraction === "number") {
      const pct = Math.round(q5.remaining_fraction * 100);
      let resetCountdown = "";
      if (q5.reset_in_seconds && q5.reset_in_seconds > 0) {
        const totalMins = Math.round(q5.reset_in_seconds / 60);
        const hrs = Math.floor(totalMins / 60);
        const mins = totalMins % 60;
        resetCountdown = hrs > 0 ? ` (${hrs}h ${mins}m)` : ` (${mins}m)`;
      }
      parts.push(`🔋 5h: ${pct}%${resetCountdown}`);
    }

    // 4. Weekly Quota
    const qWk = data.quota?.["gemini-weekly"];
    if (qWk && typeof qWk.remaining_fraction === "number") {
      const pct = Math.round(qWk.remaining_fraction * 100);
      parts.push(`📅 Wk: ${pct}%`);
    }

    // 5. Git Branch & Dirty status
    if (data.vcs?.branch) {
      const dirtyFlag = data.vcs.dirty ? "*" : "";
      parts.push(`🌿 ${data.vcs.branch}${dirtyFlag}`);
    }

    // 6. Workspace / Project folder
    const workspacePath =
      data.workspace?.current_dir ||
      data.workspace?.workspace ||
      data.workspace?.project_dir ||
      process.cwd();
    if (workspacePath) {
      const folderName = getBaseName(workspacePath);
      if (folderName) {
        parts.push(`📁 ${folderName}`);
      }
    }

    // 7. Session Duration + Local Clock
    const durationStr = getSessionDurationStr();
    const now = new Date();
    const timeStr =
      String(now.getHours()).padStart(2, "0") + ":" + String(now.getMinutes()).padStart(2, "0");
    parts.push(`⏱️ ${durationStr} (${timeStr})`);

    process.stdout.write(parts.join(" │ "));
  } catch (err) {
    process.stdout.write("⚡ Antigravity");
  }
});
