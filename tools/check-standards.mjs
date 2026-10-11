import { readFileSync, readdirSync, existsSync } from "node:fs";
import { spawnSync } from "node:child_process";
import { resolve, join } from "node:path";

const root = process.cwd();
let passed = 0;
let failed = 0;

function check(name, fn) {
  try {
    fn();
    console.log(`  [OK]   ${name}`);
    passed++;
  } catch (err) {
    console.error(`  [FAIL] ${name} - ${err.message}`);
    failed++;
  }
}

console.log("\n==========================================================");
console.log(" [CI Doctor] Antigravity Configuration Standards Check");
console.log("==========================================================\n");

// 1. JSON Validity
const jsonFiles = ["config.json", "hooks.json", "mcp_config.json"];
for (const file of jsonFiles) {
  check(`JSON syntax: ${file}`, () => {
    const fullPath = join(root, file);
    if (!existsSync(fullPath)) throw new Error(`File ${file} does not exist`);
    const content = readFileSync(fullPath, "utf8");
    JSON.parse(content);
  });
}

// 2. Subagents & Persona
const expectedAgents = [
  { name: "sa-architect", model: "pro" },
  { name: "sa-code-reviewer", model: "pro" },
  { name: "sa-debugger", model: "pro" },
  { name: "sa-explore", model: "flash" },
  { name: "sa-git-manager", model: "flash" },
  { name: "sa-handoff", model: "flash" },
  { name: "sa-summarizer", model: "flash" }
];

for (const agent of expectedAgents) {
  check(`Subagent: ${agent.name} (model: ${agent.model})`, () => {
    const file = join(root, "agents", `${agent.name}.md`);
    if (!existsSync(file)) throw new Error(`Agent file missing at ${file}`);
    const content = readFileSync(file, "utf8");
    if (!content.includes(`model: ${agent.model}`)) {
      throw new Error(`Expected model '${agent.model}' not found`);
    }
    if (!content.includes("หนู") || !content.includes("ค่ะ") || !content.includes("พี่ A")) {
      throw new Error(`Persona tags (หนู / ค่ะ / พี่ A) missing`);
    }
  });
}

// 3. Core tools & starter
check("Tool: doctor.ps1", () => {
  if (!existsSync(join(root, "tools", "doctor.ps1"))) throw new Error("tools/doctor.ps1 missing");
});

check("Tool: new-vibe-project.ps1", () => {
  if (!existsSync(join(root, "tools", "new-vibe-project.ps1")))
    throw new Error("tools/new-vibe-project.ps1 missing");
});

check("Starter: design-lab/starter-multifile", () => {
  if (!existsSync(join(root, "design-lab", "starter-multifile", "package.json"))) {
    throw new Error("design-lab/starter-multifile/package.json missing");
  }
});

check("Tool: statusline.js + test-security-gate.ps1", () => {
  for (const f of ["statusline.js", "security-gate.ps1", "test-security-gate.ps1"]) {
    if (!existsSync(join(root, "tools", f))) throw new Error(`tools/${f} missing`);
  }
});

// 4. Hook/statusline commands: Antigravity is not a shell - quote characters reach the child
//    process literally ("Illegal characters in path" / "Cannot find module"). Found 2026-10-11.
const hookCommands = [];
check("hooks.json: commands contain no quote characters", () => {
  const hooks = JSON.parse(readFileSync(join(root, "hooks.json"), "utf8"));
  const walk = (node) => {
    if (Array.isArray(node)) node.forEach(walk);
    else if (node && typeof node === "object") {
      if (typeof node.command === "string") hookCommands.push(node.command);
      Object.values(node).forEach(walk);
    }
  };
  walk(hooks);
  if (hookCommands.length === 0) throw new Error("no hook commands found");
  const bad = hookCommands.filter((c) => /["']/.test(c));
  if (bad.length) throw new Error(`quote characters in: ${bad.join(" | ")}`);
});

// 5. The gate must really run when started the way Antigravity starts it (tokens, no shell).
check("security gate: hooks.json command asks for `git reset --hard`", () => {
  const cmd = hookCommands.find((c) => /security-gate\.ps1/.test(c));
  if (!cmd) throw new Error("hooks.json does not call security-gate.ps1");
  const [exe, ...rest] = cmd.split(/\s+/);
  const r = spawnSync(exe, rest, {
    cwd: root,
    input: JSON.stringify({
      toolCall: { name: "run_command", args: { CommandLine: "git reset --hard" } }
    }),
    encoding: "utf8",
    env: { ...process.env, GATE_SILENT: "1" },
    timeout: 20000
  });
  if (r.error?.code === "ENOENT") return; // no powershell on this machine (e.g. CI on Linux) - skip
  if (!/"decision"\s*:\s*"force_ask"/.test(r.stdout ?? ""))
    throw new Error(`gate did not ask; stdout=${JSON.stringify((r.stdout ?? "").slice(0, 80))}`);
});

// 6. MCP servers: pinned versions, no BOM (strict JSON parsers reject it).
check("mcp_config.json: no BOM, no @latest, npx packages pinned", () => {
  const buf = readFileSync(join(root, "mcp_config.json"));
  if (buf[0] === 0xef && buf[1] === 0xbb && buf[2] === 0xbf)
    throw new Error("file starts with a BOM");
  const cfg = JSON.parse(buf.toString("utf8"));
  const problems = [];
  for (const [name, s] of Object.entries(cfg.mcpServers ?? cfg)) {
    if (s.command !== "npx") continue;
    const pkg = (s.args ?? []).find((a) => !a.startsWith("-"));
    if (!pkg || pkg.endsWith("@latest") || !/@\d/.test(pkg)) problems.push(`${name}: ${pkg}`);
  }
  if (problems.length) throw new Error(`unpinned: ${problems.join(", ")}`);
});

// 7. PowerShell 5.1 reads BOM-less files as ANSI: any .ps1 with non-ASCII text needs a UTF-8 BOM.
check("*.ps1 with non-ASCII text must start with a UTF-8 BOM", () => {
  const dirs = [root, join(root, "tools")];
  const bad = [];
  for (const dir of dirs) {
    for (const f of readdirSync(dir).filter((n) => n.endsWith(".ps1"))) {
      const b = readFileSync(join(dir, f));
      const hasBom = b[0] === 0xef && b[1] === 0xbb && b[2] === 0xbf;
      if (!hasBom && b.some((x) => x > 127)) bad.push(dir === root ? f : `tools/${f}`);
    }
  }
  if (bad.length) throw new Error(`non-ASCII without BOM: ${bad.join(", ")}`);
});

console.log("\n==========================================================");
if (failed > 0) {
  console.error(` [FAILED] ${failed} check(s) failed, ${passed} passed`);
  process.exit(1);
} else {
  console.log(` [PASSED] All ${passed} checks passed successfully!`);
}
