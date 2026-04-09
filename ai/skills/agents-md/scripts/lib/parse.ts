#!/usr/bin/env bun
import { readFileSync } from "fs";
import { parse as parseTOML } from "smol-toml";

const commands: Record<string, (args: string[]) => void> = {
  onefetch,
  "package-json": packageJson,
  pyproject,
  cargo,
  gomod,
};

const [subcommand, ...args] = process.argv.slice(2);

if (!subcommand || subcommand === "--help" || subcommand === "-h") {
  console.log(`Usage: parse.ts <subcommand> [args]`);
  console.log(`Subcommands: ${Object.keys(commands).join(", ")}`);
  process.exit(0);
}

const handler = commands[subcommand];
if (!handler) {
  console.error(`Unknown subcommand: ${subcommand}`);
  process.exit(1);
}

// All subcommands except onefetch (which accepts "-" for stdin) require a file path
if (subcommand !== "onefetch" && !args[0]) {
  console.error(`Missing file path for ${subcommand}`);
  process.exit(1);
}

try {
  handler(args);
} catch (e) {
  console.error(
    `Failed to parse ${subcommand}: ${e instanceof Error ? e.message : e}`,
  );
  process.exit(1);
}

// --- Subcommands ---

function onefetch(args: string[]) {
  const input = args[0] === "-" ? readStdin() : readFileSync(args[0], "utf-8");
  const data = JSON.parse(input);

  // onefetch JSON uses infoFields as an array of single-key objects (tagged union pattern).
  // Each object has exactly one key (e.g. "ProjectInfo", "HeadInfo") mapping to its data.
  const fields: Array<{ key: string; extract: (val: any) => string | null }> = [
    {
      key: "ProjectInfo",
      extract: (v) => `- Project: ${v.repoName}`,
    },
    {
      key: "HeadInfo",
      extract: (v) => {
        const refs = v.headRefs;
        const refStr = (refs.refs ?? []).join(", ");
        return `- HEAD: ${refs.shortCommitId} (${refStr})`;
      },
    },
    {
      key: "CreatedInfo",
      extract: (v) => `- Created: ${v.creationDate}`,
    },
    {
      key: "LanguagesInfo",
      extract: (v) => {
        const langs = v.languagesWithPercentage ?? [];
        if (!langs.length) return null;
        const parts = langs.map(
          (l: any) => `${l.language} (${l.percentage.toFixed(1)}%)`,
        );
        return `- Languages: ${parts.join(", ")}`;
      },
    },
    {
      key: "LastChangeInfo",
      extract: (v) => `- Last change: ${v.lastChange}`,
    },
    {
      key: "UrlInfo",
      extract: (v) => (v.repoUrl ? `- URL: ${v.repoUrl}` : null),
    },
    {
      key: "CommitsInfo",
      extract: (v) => `- Commits: ${v.numberOfCommits}`,
    },
    {
      key: "LocInfo",
      extract: (v) => `- Lines of code: ${v.linesOfCode}`,
    },
    {
      key: "SizeInfo",
      extract: (v) => `- Size: ${v.repoSize} (${v.fileCount} files)`,
    },
    {
      key: "LicenseInfo",
      extract: (v) => (v.license ? `- License: ${v.license}` : null),
    },
  ];

  const fieldMap = new Map(fields.map((f) => [f.key, f.extract]));

  for (const field of data.infoFields ?? []) {
    for (const [key, val] of Object.entries(field)) {
      const extract = fieldMap.get(key);
      if (!extract) continue;
      try {
        const line = extract(val);
        if (line) console.log(line);
      } catch {
        // skip malformed fields
      }
    }
  }
}

function packageJson(args: string[]) {
  const filePath = args[0];
  const data = JSON.parse(readFileSync(filePath, "utf-8"));
  const scripts = data.scripts ?? {};
  const entries = Object.entries(scripts);
  if (!entries.length) {
    process.exit(2); // exit 2 = no scripts found, caller skips section intentionally
  }
  for (const [k, v] of entries) {
    console.log(`- ${k}: \`${v}\``);
  }
}

function pyproject(args: string[]) {
  const filePath = args[0];
  const raw = readFileSync(filePath, "utf-8");
  const data = parseTOML(raw) as any;

  // detect tooling in use
  const tools = Object.keys(data.tool ?? {});
  if (tools.length) {
    console.log(`- tools: ${tools.join(", ")}`);
  }

  // scripts per PEP 621, then poetry fallback
  let scripts = data.project?.scripts;
  if (!scripts || !Object.keys(scripts).length) {
    scripts = data.tool?.poetry?.scripts;
  }

  if (scripts && Object.keys(scripts).length) {
    for (const [k, v] of Object.entries(scripts)) {
      console.log(`- ${k}: \`${v}\``);
    }
  } else {
    console.log("(no scripts found)");
  }
}

// Emits package metadata only — conventional commands (cargo build/test/etc.)
// are added by the bash caller since they're static and don't need parsing.
function cargo(args: string[]) {
  const filePath = args[0];
  const raw = readFileSync(filePath, "utf-8");
  const data = parseTOML(raw) as any;

  const pkg = data.package ?? {};
  if (pkg.name) console.log(`- package: ${pkg.name}`);
  if (pkg.version) console.log(`- version: ${pkg.version}`);
  if (pkg.edition) console.log(`- edition: ${pkg.edition}`);

  const bins = data.bin ?? [];
  for (const b of bins) {
    console.log(`- binary: ${b.name ?? "unnamed"}`);
  }
}

function gomod(args: string[]) {
  const filePath = args[0];
  const content = readFileSync(filePath, "utf-8");

  const moduleMatch = content.match(/^module\s+(\S+)/m);
  if (moduleMatch) console.log(`- module: ${moduleMatch[1]}`);

  const goMatch = content.match(/^go\s+(\S+)/m);
  if (goMatch) console.log(`- go: ${goMatch[1]}`);
}

// --- Helpers ---

// Reads from fd 0 synchronously — Bun handles this natively.
function readStdin(): string {
  return readFileSync(0, "utf-8");
}
