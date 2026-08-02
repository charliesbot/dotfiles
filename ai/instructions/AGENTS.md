# Agent Instructions

## Hard Rules

- For non-trivial changes, draft a plan first and wait for explicit approval before writing code. Trivial fixes (typos, one-line bug fixes, renames) can proceed directly.
- For non-trivial changes, work in a dedicated Git worktree and open a ready-for-review PR for the approved slice once ready. Approval to implement a non-trivial slice includes approval to commit the change, push its branch, and open its PR. Open draft PRs only when explicitly asked.
- Trivial fixes can be committed and pushed to `main` only when explicitly asked.
- Do not perform opportunistic refactors. If adjacent cleanup is useful but not required, log it as follow-up work or propose a separate cleanup PR.
- Do not commit, push, or open a PR outside an approved non-trivial slice unless explicitly asked. Before committing or pushing any change, verify no secrets are included.
- For non-trivial changes, do not commit, push, or open a PR until a reviewer subagent reports PASS.
- Treat `git commit`, `git push`, and `gh pr create` as unauthorized for non-trivial work unless reviewer status is PASS in the current session.
- NEVER use hacks to bypass the type system or linters (e.g., `// @ts-ignore`, suppressing linter warnings) unless explicitly directed.
- NEVER commit `.env` files or expose API keys, tokens, or secrets in any output.
- Bug fixes follow TDD red-green: write a failing test first (red), then implement the fix (green).

## Version Control

Use Git for local version control and `gh` for GitHub operations.

- Use `git status`, `git diff`, `git log`, and `git show` for inspection.
- Use dedicated worktrees for non-trivial work and keep commits scoped to the approved slice.
- Push the feature branch before creating or updating its pull request with `gh`.

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

Default feature workflow:

1. Plan the approved slice with `planning-and-task-breakdown`.
2. Use `context-engineering` if entering an unfamiliar repo area or if conventions are unclear.
3. Use `source-driven-development` if touching framework/library APIs, auth, routing, data fetching, forms, migrations, deployment, security-sensitive code, or dependency upgrades.
4. Implement the approved slice incrementally with `incremental-implementation`.
5. Run the relevant verification.
6. Use `implementation-reviewer` before describing, pushing, or opening a PR.
7. Resolve reviewer findings in the main session, then rerun `implementation-reviewer` until it reports PASS in the current session.

Main session handles implementation by default; delegate only when a required skill explicitly asks for a subagent.

Use `code-simplification` only for separate cleanup PRs or reviewer-requested follow-up.

Do not create a separate feature spec by default; the PR plan is the lightweight spec unless the feature is ambiguous, high-risk, product-defining, or likely to span multiple sessions.

When stuck, try 2–3 approaches before asking. If still blocked, ask with context on what you tried.

## Tooling

- GitHub username: charliesbot
- gh CLI is available globally
- When running inside Herdr (`HERDR_ENV=1`), prefer `herdr` panes for long-running commands, logs, dev servers, watchers, and sibling agents so output stays visible and persistent. Use normal command execution for quick one-shot commands.
