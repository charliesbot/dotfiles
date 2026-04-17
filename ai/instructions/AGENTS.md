# Agent Instructions

## Hard Rules

- For non-trivial changes, draft a plan first and wait for explicit approval before writing code. Trivial fixes (typos, one-line bug fixes, renames) can proceed directly.
- ALWAYS create a new branch before making changes. Never commit directly to `main`.
- NEVER commit unless explicitly asked. Before any commit, verify no secrets are included.
- NEVER use hacks to bypass the type system or linters (e.g., `// @ts-ignore`, suppressing linter warnings) unless explicitly directed.
- NEVER commit `.env` files or expose API keys, tokens, or secrets in any output.
- Bug fixes follow TDD red-green: write a failing test first (red), then implement the fix (green).

## Priorities

correctness > simplicity > performance > readability

## Communication

- Be direct and concise. No preamble, no filler affirmations, no trailing summaries.
- Give opinionated recommendations. Limit options to 2–3 max. No unsolicited alternatives unless they fix a bug, security issue, or significant performance problem.
- Skip explanations of language fundamentals, design patterns, and standard library usage. Do explain project-specific conventions and non-obvious architectural decisions.
- Prefer prose over bullet points unless structure genuinely helps.

## Workflow

Main session does the work by default. Subagents are for specific triggers, not a default pipeline.

A change is non-trivial when it introduces new behavior, touches more than one module, or affects auth, payments, or data flow. Everything else is trivial.

### Plans

For non-trivial changes, draft a plan first and wait for approval. Do not jump into code.

Plans must include:

- A clear breakdown of what will change and why.
- Code snippets showing the key parts of the proposed solution.
- Diagrams (ASCII/Mermaid) when they clarify architecture, data flow, or component relationships.

When stuck, try 2–3 approaches before asking. If still blocked, ask with context on what you tried.

### Subagents

Main session handles everything else.

- **architect** — Reach for it when starting work in a codebase you don't know well, or before a cross-cutting change where blast radius is unclear. Runs `discover` on its own.
- **reviewer** — Auto-run after every non-trivial change lands on the branch. Read-only, fresh-eyes pass before commit or PR.

## Tooling

- GitHub username: charliesbot
- gh CLI is available globally
