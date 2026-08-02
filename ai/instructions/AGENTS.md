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

<!-- BEGIN ENGRAM MEMORY PROTOCOL — managed by engram setup -->

## Engram Persistent Memory — Protocol

You have access to Engram, a persistent memory system that survives across sessions and compactions.

### WHEN TO SAVE (mandatory — not optional)

Call mem_save IMMEDIATELY after any of these:

- Bug fix completed
- Architecture or design decision made
- Non-obvious discovery about the codebase
- Configuration change or environment setup
- Pattern established (naming, structure, convention)
- User preference or constraint learned

Format for mem_save:

- **title**: Verb + what — short, searchable (e.g. "Fixed N+1 query in UserList", "Chose Zustand over Redux")
- **type**: bugfix | decision | architecture | discovery | pattern | config | preference
- **scope**: project (default) | personal
- **topic_key** (optional, recommended for evolving decisions): stable key like architecture/auth-model
- **content**:
  **What**: One sentence — what was done
  **Why**: What motivated it (user request, bug, performance, etc.)
  **Where**: Files or paths affected
  **Learned**: Gotchas, edge cases, things that surprised you (omit if none)

### Topic update rules (mandatory)

- Different topics must not overwrite each other (e.g. architecture vs bugfix)
- Reuse the same topic_key to update an evolving topic instead of creating new observations
- If unsure about the key, call mem_suggest_topic_key first and then reuse it
- Use mem_update when you have an exact observation ID to correct

### WHEN TO SEARCH MEMORY

When the user asks to recall something — any variation of "remember", "recall", "what did we do",
"how did we solve", "recordar", "acordate", "qué hicimos", or references to past work:

1. First call mem_context — checks recent session history (fast, cheap)
2. If not found, call mem_search with relevant keywords (FTS5 full-text search)
3. If you find a match, use mem_get_observation for full untruncated content

Also search memory PROACTIVELY when:

- Starting work on something that might have been done before
- The user mentions a topic you have no context on — check if past sessions covered it

### SESSION CLOSE PROTOCOL (mandatory)

Before ending a session or saying "done" / "listo" / "that's it", you MUST:

1. Call mem_session_summary with this structure:

## Goal

[What we were working on this session]

## Instructions

[User preferences or constraints discovered — skip if none]

## Discoveries

- [Technical findings, gotchas, non-obvious learnings]

## Accomplished

- [Completed items with key details]

## Next Steps

- [What remains to be done — for the next session]

## Relevant Files

- path/to/file — [what it does or what changed]

This is NOT optional. If you skip this, the next session starts blind.

### PASSIVE CAPTURE — automatic learning extraction

When completing a task or subtask, include a "## Key Learnings:" section at the end of your response
with numbered items. Engram will automatically extract and save these as observations.

Example:

## Key Learnings:

1. bcrypt cost=12 is the right balance for our server performance
2. JWT refresh tokens need atomic rotation to prevent race conditions

You can also call mem_capture_passive(content) directly with any text that contains a learning section.
This is a safety net — it captures knowledge even if you forget to call mem_save explicitly.

### AFTER COMPACTION

If you see a message about compaction or context reset, or if you see "FIRST ACTION REQUIRED" in your context:

1. IMMEDIATELY call mem_session_summary with the compacted summary content — this persists what was done before compaction
2. Then call mem_context to recover any additional context from previous sessions
3. Only THEN continue working

Do not skip step 1. Without it, everything done before compaction is lost from memory.

<!-- END ENGRAM MEMORY PROTOCOL -->
