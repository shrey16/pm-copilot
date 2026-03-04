// PM Copilot - Implementation REPL Stop Hook
// Adapted from ralph-loop pattern.
//
// This hook runs on the Stop event. It reads the implementation state file
// and decides whether to block the stop (continue the loop) or allow it.
//
// Exit behavior:
//   - Exit 0 with no output -> allow stop
//   - Output JSON with decision:"block" -> block stop and re-feed prompt

const fs = require("fs");

const STATE_FILE = ".claude/pm-implement-state.local.md";

if (!fs.existsSync(STATE_FILE)) {
  process.exit(0);
}

const state = fs.readFileSync(STATE_FILE, "utf-8");
const lines = state.split("\n");

// Find current in-progress unit
let currentUnit = "";
let iteration = 0;
const MAX_ITERATIONS = 5;
let inProgressBlock = false;
let unitTestsFail = false;
let e2eTestsFail = false;

for (let i = 0; i < lines.length; i++) {
  const line = lines[i];
  if (line.match(/^### Unit \d+:/) && i + 1 < lines.length) {
    const nextLines = lines.slice(i, i + 7).join("\n");
    if (nextLines.includes("Status: in-progress")) {
      currentUnit = line.replace(/^### Unit \d+:\s*/, "").trim();
      inProgressBlock = true;
      for (let j = i; j < Math.min(i + 7, lines.length); j++) {
        const m = lines[j].match(/Iteration:\s*(\d+)\/5/);
        if (m) iteration = parseInt(m[1], 10);
        if (lines[j].includes("Unit Tests: fail")) unitTestsFail = true;
        if (lines[j].includes("E2E Tests: fail")) e2eTestsFail = true;
      }
      break;
    }
  }
}

// Count pending requirements (unchecked boxes)
const pendingReqs = (state.match(/^- \[ \]/gm) || []).length;
const totalReqs = (state.match(/^- \[[ x]\]/gm) || []).length;

// Count units
const completedUnits = (state.match(/Status: complete/g) || []).length;
const totalUnits = (state.match(/^### Unit/gm) || []).length;
const pendingUnits = (state.match(/Status: pending/g) || []).length;

const totalFailing = (unitTestsFail ? 1 : 0) + (e2eTestsFail ? 1 : 0);

// If max iterations reached for current unit
if (iteration >= MAX_ITERATIONS) {
  if (pendingUnits === 0 && pendingReqs === 0) {
    process.exit(0);
  }
  const reason = `Continue implementing. Current unit '${currentUnit}' reached max iterations (${MAX_ITERATIONS}). Moving to next unit. ${completedUnits}/${totalUnits} units completed. ${pendingReqs} requirements still pending.`;
  console.log(JSON.stringify({ decision: "block", reason }));
  process.exit(0);
}

// If all requirements satisfied and all tests pass
if (pendingReqs === 0 && totalFailing === 0 && totalReqs > 0) {
  process.exit(0);
}

// Otherwise, block stop and continue
let reason = `Continue implementing. Unit: '${currentUnit}'. Iteration ${iteration}/${MAX_ITERATIONS}.`;
if (pendingReqs > 0) {
  reason += ` ${pendingReqs}/${totalReqs} requirements pending.`;
}
if (totalFailing > 0) {
  reason += ` ${totalFailing} test suites failing.`;
}
reason += " Fix the failures and re-run tests.";

console.log(JSON.stringify({ decision: "block", reason }));
process.exit(0);
