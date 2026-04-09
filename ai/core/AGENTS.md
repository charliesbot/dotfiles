# Agent Instructions

## Hard Rules

- NEVER write or modify code without explicit user approval. Draft a plan first, wait for approval.
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

Plans must include:
- A clear breakdown of what will change and why.
- Code snippets showing the key parts of the proposed solution.
- Diagrams (ASCII/Mermaid) when they clarify architecture, data flow, or component relationships.

When stuck, try 2–3 approaches before asking. If still blocked, ask with context on what you tried.

## Tooling

- GitHub username: charliesbot
- gh CLI is available globally
