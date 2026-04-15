# Subagent Best Practices

Patterns for writing performant, portable subagents. Extracted from Anthropic and Google research, cross-referenced with production usage data.

## Table of Contents

- [The One Rule](#the-one-rule)
- [Role Design](#role-design)
- [System Prompt Structure](#system-prompt-structure)
- [Token Efficiency](#token-efficiency)
- [Tool Access](#tool-access)
- [Description Field](#description-field)
- [Validation Checklist](#validation-checklist)
- [Anti-Patterns](#anti-patterns)
- [Delegation Patterns](#delegation-patterns)

## The One Rule

Subagents are **information collectors, not implementers**. They read, analyze, summarize, and return findings. The main agent implements.

Why: Anthropic's research found that subagents work best when they "just look for information and provide a small amount of summary." Multi-agent systems where subagents implement changes suffer from merge conflicts, context drift, and coordination failures. A read-only agent physically cannot cause damage.

Override: The user may explicitly request a read-write agent. Proceed, but add guardrails — restrict which files/directories the agent can modify, and include explicit stop conditions.

## Role Design

### One Agent, One Job

A focused agent outperforms a generalist because it:

- Gets a smaller, more relevant system prompt (fewer wasted tokens)
- Has fewer tools to choose from (less decision confusion)
- Returns tighter summaries (less noise for the orchestrator)

Test: Can you describe the agent's role in one sentence? If not, split it.

### Recommended Roles

These roles map well to the subagent pattern (information collection):

| Role                  | What it does                                   | Tools needed       |
| --------------------- | ---------------------------------------------- | ------------------ |
| Code reviewer         | Analyzes code for quality, security, patterns  | Read, Search, Find |
| Test analyzer         | Reads test output, identifies failure patterns | Read, Search, Run  |
| Architecture explorer | Maps dependencies, answers structure questions | Read, Search, Find |
| Security auditor      | Finds vulnerability patterns, reports risks    | Read, Search, Find |
| Documentation scanner | Checks docs freshness, finds gaps              | Read, Search, Find |
| Dependency checker    | Audits packages for updates, vulnerabilities   | Read, Run          |

### Roles That Need Care

These roles require write access and explicit guardrails:

| Role       | Risk                    | Guardrails                                           |
| ---------- | ----------------------- | ---------------------------------------------------- |
| Test fixer | May break passing tests | Only modify test files, run tests after changes      |
| Formatter  | May mangle code         | Restrict to specific file patterns, run linter after |
| Migrator   | May corrupt data        | Dry-run first, explicit file scope                   |

## System Prompt Structure

Order matters. Research shows agents weight the beginning and end of instructions more heavily than the middle (periphery bias). Structure accordingly:

### Recommended Order

1. **Identity + scope** (lines 1-5) — Who the agent is, what it does, what it does NOT do. This sets the behavioral frame for everything that follows.

2. **Token efficiency directive** (lines 6-8) — "Be concise. Structured format. No preamble, no trailing summaries. Fragments OK." Placing this early means every subsequent interaction is cheaper.

3. **Output format** (lines 9-20) — Specify exactly what the response looks like. Headings, structure, length. Without this, agents produce narrative prose that wastes tokens and is harder to parse.

4. **Process** (lines 21-50) — Step-by-step approach. Numbered for sequential work, bullets for parallel considerations. Include "start broad, then narrow" for search-oriented agents.

5. **Constraints** (lines 51-65) — Hard rules. What to avoid. When to stop. Keep this section short (5-7 items max). If you need more, the scope is too broad.

6. **Verification** (lines 65-80) — How the agent checks its own work. This is the single highest-leverage section — without it, agents produce plausible-looking but incorrect outputs.

### Length Budget

- **Ideal:** Under 80 lines
- **Maximum:** 120 lines
- **Why:** Token usage explains 80% of performance variance in agent systems. Every line costs tokens on every turn. A lean prompt that the agent actually follows beats a comprehensive one it partially ignores.

## Token Efficiency

### In the Prompt

- Cut vague instructions the agent would follow anyway
- Use pointers ("follow the pattern in `src/auth.ts:15-40`") instead of inline code
- Include the terse output directive: "Be concise. Structured format. No preamble."
- One good example beats three paragraphs of description

### In Tool Access

- Unused tools still get tokenized in the agent's context
- Grant only what the agent needs
- Read-only agents need: Read, Search, Find
- Read-write agents add: Edit, Write (rarely both)

### In Agent Output

The terse output directive saves ~60% of per-message tokens. Agents default to verbose prose when not explicitly constrained. "Fragments OK" gives the agent permission to skip complete sentences when a structured format is clearer.

## Tool Access

### Default: Read-Only

Unless the user explicitly needs write access, grant only:

- Read files (Claude: `Read` / Gemini: `read_file`)
- Search content (Claude: `Grep` / Gemini: `grep_search`)
- Find files (Claude: `Glob` / Gemini: `glob`)

A read-only agent physically cannot cause damage. This is better than relying on prompt instructions alone — tool restrictions are enforced by the platform, not by the agent's compliance.

### When to Add Write Tools

- The agent needs to create or modify files as part of its core purpose
- The user explicitly requests it
- The task cannot be decomposed into "analyze → report → main agent implements"

### When to Add Run/Shell

- The agent needs to execute build commands, run tests, or check tool output
- Be specific in the prompt about which commands are expected

## Description Field

The `description` is what the main agent reads to decide whether to delegate. Quality here directly affects routing accuracy.

### Good Descriptions

- Specific about the agent's expertise area
- Include 2-3 triggering scenarios
- Mention what the agent produces (findings, reports, analysis)
- Use "proactively" if you want the main agent to delegate without being asked

Example:

```
Analyzes code changes for security vulnerabilities. Use when reviewing PRs,
auditing authentication flows, or checking for OWASP top 10 patterns. Returns
structured findings with severity, file location, and remediation suggestions.
```

### Bad Descriptions

- Too vague: "Helps with code"
- Too narrow: "Reviews Python Flask auth middleware"
- Missing output: "Looks at security" (what does it produce?)

## Validation Checklist

Run every agent through these checks before presenting to the user:

| #   | Check               | Pass Criteria                                               |
| --- | ------------------- | ----------------------------------------------------------- |
| 1   | Scope focus         | One sentence describes the role. No "and also..."           |
| 2   | Prompt length       | Body under 80 lines (ideal) or 120 lines (max)              |
| 3   | Tool minimality     | Only tools the agent actually uses. Read-only default.      |
| 4   | Explicit boundaries | Body states what agent does AND does NOT do                 |
| 5   | Verification step   | Body includes self-check instructions                       |
| 6   | Output format       | Body specifies response structure                           |
| 7   | Front-loaded        | Critical instructions in first 20 lines                     |
| 8   | Token efficiency    | Terse output directive included                             |
| 9   | Description quality | Specific, includes scenarios, mentions output type          |
| 10  | Portable fields     | Only `name`, `description`, `model`, `tools` in frontmatter |

**Scoring:** Each check is pass/fail. 10/10 = ship it. 8-9 = minor fixes. Below 8 = rethink the design.

## Anti-Patterns

### The Kitchen Sink

Cramming every scenario into instructions. The agent can't parse or prioritize, and performance degrades. If the prompt exceeds 120 lines, the scope is too broad — split into two agents.

### All Tools Granted

Granting all tools to an agent that only needs to read files. Unused tools consume tokens and increase decision confusion. Restrict to minimum needed.

### Vague Delegation

"Fix authentication" vs "Analyze the OAuth redirect loop where successful login redirects to /login instead of /dashboard. Check auth middleware in src/lib/auth.ts. Report root cause and suggest fix." The second works. The first produces random exploration.

### No Stop Condition

Without explicit stopping criteria, agents "continue running far beyond their useful window." Always define when the agent should stop and return results.

### Implementation Without Guardrails

A read-write agent with no file scope restrictions, no test-after-modify step, and no explicit boundaries. Recipe for silent damage.

### Over-Parallelizing

10 agents for one feature wastes tokens and creates conflicts. Parallel dispatch works for 3+ truly independent tasks with no shared files.

## Delegation Patterns

### When to Use Subagents

- Task produces verbose output you don't need in main context (test logs, file scans)
- Research requires reading dozens of files
- Multiple independent analysis tasks can run in parallel
- You want enforced tool restrictions (read-only review)
- Fresh perspective needed (writer/reviewer pattern)

### When NOT to Use Subagents

- Work is sequentially dependent (step 2 needs full step 1 output)
- Parallel edits to the same file would conflict
- Small focused tasks don't justify the overhead
- Tasks need frequent back-and-forth with the user

### The Writer/Reviewer Pattern

Use one agent to implement and a fresh agent (clean context, no bias toward code it wrote) to review. The reviewer catches issues the writer is blind to because it has no memory of the implementation decisions.
