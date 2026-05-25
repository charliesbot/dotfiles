# Agent Instructions

## Hard Rules

- For non-trivial changes, draft a plan first and wait for explicit approval before writing code. Trivial fixes (typos, one-line bug fixes, renames) can proceed directly.
- For non-trivial changes, work on a new branch and open a ready-for-review PR for the approved slice once ready. Approval to implement a non-trivial slice includes approval to commit that slice and open its PR. Open draft PRs only when explicitly asked.
- Trivial fixes can commit directly to `main` only when explicitly asked.
- Do not perform opportunistic refactors. If adjacent cleanup is useful but not required, log it as follow-up work or propose a separate cleanup PR.
- Do not commit outside an approved non-trivial slice unless explicitly asked. Before any commit, verify no secrets are included.
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

Non-trivial: new features, refactors, cross-module changes, anything touching auth, payments, or data flow.
Trivial: typos, one-line bug fixes, renames, comment or doc edits, AGENTS.md tweaks, dependency version bumps.

### Feature Flow

For non-trivial feature work, treat reviewability as a first-class constraint. A small, coherent PR that implements part of a feature is better than a complete feature that is too large to review deeply.

Before implementation, produce a lightweight PR plan and wait for approval. Include:

- Intended behavior, non-goals, assumptions, and open questions.
- 2–5 reviewable PR slices, with the recommended first slice called out.
- Expected files for the first slice and why each needs to change.
- Minimal code snippets showing key interfaces, route shapes, data models, component boundaries, or function signatures. Do not write full implementations in the plan.
- Diagrams in ASCII or Mermaid when they clarify architecture, data flow, or component relationships.
- Verification for the first slice.

Prefer small vertical slices that produce working behavior. Use foundation-only slices only when they reduce risk or unblock later work.

Implement only the approved slice. If scope grows beyond the approved file list, touches more than ~5 meaningful files, or approaches ~300 changed LOC excluding generated files, lockfiles, snapshots, and migrations, stop and propose a split.

Use `planning-and-task-breakdown`, `incremental-implementation`, and reviewer checks as the default feature workflow. Use `code-simplification` only for separate cleanup PRs or reviewer-requested follow-up. Use `context-engineering` when entering an unfamiliar repo area or when conventions are unclear. Use `source-driven-development` for framework/library APIs, auth, routing, data fetching, forms, migrations, deployment, security-sensitive code, or dependency upgrades. Do not create a separate feature spec by default; the PR plan is the lightweight spec unless the feature is ambiguous, high-risk, product-defining, or likely to span multiple sessions.

When stuck, try 2–3 approaches before asking. If still blocked, ask with context on what you tried.

### Subagents

Main session handles implementation. Delegate only when a trigger below matches:

- **reviewer** — MUST run a fresh-eyes pass (delegated to a read-only reviewer subagent or a separate review pass reading the modified files) after every non-trivial change, before commit or PR. Do not proceed until the review reports PASS or all issues are resolved.

## Tooling

- GitHub username: charliesbot
- gh CLI is available globally
