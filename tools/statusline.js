// Antigravity CLI Statusline renderer
// Reads agent JSON state from stdin and outputs a formatted statusline.

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

    // 1. Model
    const model = data.model?.display_name || data.model?.name || "Gemini";

    // 2. Context Window usage %
    let contextStr = "";
    if (data.context_window?.used_percentage !== undefined) {
      const pct = Number(data.context_window.used_percentage).toFixed(1);
      contextStr = `🪙 Context: ${pct}%`;
    }

    // 3. 5-Hour Quota & Countdown
    let quota5hStr = "";
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
      quota5hStr = `🔋 5h: ${pct}%${resetCountdown}`;
    }

    // 4. Weekly Quota
    let quotaWkStr = "";
    const qWk = data.quota?.["gemini-weekly"];
    if (qWk && typeof qWk.remaining_fraction === "number") {
      const pct = Math.round(qWk.remaining_fraction * 100);
      quotaWkStr = `📅 Wk: ${pct}%`;
    }

    // 5. Plan Tier
    const tier = data.plan_tier || "Google AI Pro";
    const tierStr = `💎 ${tier}`;

    // Assemble parts
    const parts = [`⚡ ${model}`];
    if (contextStr) parts.push(contextStr);
    if (quota5hStr) parts.push(quota5hStr);
    if (quotaWkStr) parts.push(quotaWkStr);
    if (tierStr) parts.push(tierStr);

    process.stdout.write(parts.join(" │ "));
  } catch (err) {
    process.stdout.write("⚡ Antigravity");
  }
});
