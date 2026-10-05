import { readFileSync, existsSync } from "node:fs";
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

console.log("\n==========================================================");
if (failed > 0) {
  console.error(` [FAILED] ${failed} check(s) failed, ${passed} passed`);
  process.exit(1);
} else {
  console.log(` [PASSED] All ${passed} checks passed successfully!`);
}
