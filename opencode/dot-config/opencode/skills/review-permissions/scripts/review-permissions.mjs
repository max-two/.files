#!/usr/bin/env node

import fs from "node:fs";
import os from "node:os";
import path from "node:path";

const home = os.homedir();
const configPath = path.join(home, ".config/opencode/opencode.json");
const logDir = path.join(home, ".local/share/opencode/log");

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function flattenPermissionConfig(config) {
  const result = [];
  if (!config || typeof config !== "object") return result;

  for (const [permission, value] of Object.entries(config)) {
    if (typeof value === "string") {
      result.push({ permission, pattern: "*", action: value });
      continue;
    }

    if (!value || typeof value !== "object") continue;

    for (const [pattern, action] of Object.entries(value)) {
      if (typeof action !== "string") continue;
      result.push({ permission, pattern, action });
    }
  }

  return result;
}

function latestLogFile(dirPath) {
  const entries = fs
    .readdirSync(dirPath, { withFileTypes: true })
    .filter((entry) => entry.isFile() && entry.name.endsWith(".log"))
    .map((entry) => entry.name)
    .sort();

  if (entries.length === 0) {
    throw new Error(`No log files found in ${dirPath}`);
  }

  return path.join(dirPath, entries[entries.length - 1]);
}

function parseSessionAllows(logText) {
  const rules = new Map();
  const broad = new Map();

  for (const line of logText.split("\n")) {
    if (!line.includes("service=permission") || !line.includes('"action":"allow"')) {
      continue;
    }

    const match = line.match(/action=(\{.*\}) evaluated$/);
    if (!match) continue;

    let action;
    try {
      action = JSON.parse(match[1]);
    } catch {
      continue;
    }

    if (action.action !== "allow") continue;

    const normalized = {
      permission: String(action.permission ?? ""),
      pattern: String(action.pattern ?? ""),
      action: "allow",
    };

    const key = `${normalized.permission}\t${normalized.pattern}\t${normalized.action}`;
    if (normalized.permission === "*" || normalized.pattern === "*") {
      broad.set(key, normalized);
    } else {
      rules.set(key, normalized);
    }
  }

  return {
    rules: [...rules.values()].sort(compareRules),
    broad: [...broad.values()].sort(compareRules),
  };
}

function compareRules(a, b) {
  return (
    a.permission.localeCompare(b.permission) ||
    a.pattern.localeCompare(b.pattern) ||
    a.action.localeCompare(b.action)
  );
}

function escapeRegex(text) {
  return text.replace(/[|\\{}()[\]^$+?.]/g, "\\$&");
}

function patternMatches(pattern, value) {
  const regex = new RegExp(`^${escapeRegex(pattern).replace(/\*/g, ".*")}$`);
  return regex.test(value);
}

function durableCoversRule(durableRule, sessionRule) {
  if (durableRule.action !== sessionRule.action) return false;

  const permissionMatches =
    durableRule.permission === "*" ||
    durableRule.permission === sessionRule.permission;

  if (!permissionMatches) return false;

  return patternMatches(durableRule.pattern, sessionRule.pattern);
}

function missingRules(sessionRules, durableRules) {
  return sessionRules.filter(
    (rule) => !durableRules.some((durableRule) => durableCoversRule(durableRule, rule)),
  );
}

function formatRules(title, rules) {
  const lines = [`## ${title}`];
  if (rules.length === 0) {
    lines.push("- none");
    return lines.join("\n");
  }

  for (const rule of rules) {
    lines.push(`- ${rule.permission}: ${rule.pattern} -> ${rule.action}`);
  }
  return lines.join("\n");
}

function main() {
  const logPath = process.argv[2] ? path.resolve(process.argv[2]) : latestLogFile(logDir);
  const config = readJson(configPath);
  const durableRules = flattenPermissionConfig(config.permission)
    .filter((rule) => rule.action === "allow")
    .sort(compareRules);
  const session = parseSessionAllows(fs.readFileSync(logPath, "utf8"));
  const missing = missingRules(session.rules, durableRules);

  const output = [
    `Log file: ${logPath}`,
    `Durable config: ${configPath}`,
    "",
    formatRules("Durable Allow Rules", durableRules),
    "",
    formatRules("Session Allow Rules", session.rules),
    "",
    formatRules("Session-only Allow Rules", missing),
    "",
    formatRules("Broad Wildcard Approvals Seen In Session", session.broad),
  ];

  process.stdout.write(`${output.join("\n")}\n`);
}

main();
