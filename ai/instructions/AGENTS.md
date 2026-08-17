# Agent Instructions

## Hard Rules

- For non-trivial changes, draft a plan first and wait for explicit approval before writing code. Trivial fixes (typos, one-line bug fixes, renames) can proceed directly.
- Treat the primary checkout as shared. For non-trivial changes, create a dedicated worktree with `wt switch --create <branch>` after approval; reuse one only when it is clearly assigned to the current task.
- Use one worktree per independent PR or per complete PR stack. Never create a separate worktree for each layer of the same stack.
- Use Worktrunk exclusively to create, switch, list, and remove worktrees. Never use native `git worktree` commands or manually delete worktree directories.
- If Worktrunk is unavailable or fails, stop and notify the user instead of falling back.
- Trivial fixes can be committed and pushed to `main` only when explicitly asked.
- Do not perform opportunistic refactors. If adjacent cleanup is useful but not required, log it as follow-up work or propose a separate cleanup PR.
- Approval to implement a non-trivial change includes approval to commit, push, and open its ready-for-review PR after applicable verification passes. For stacks, each layer requires approved scope and applicable verification. Open drafts only when explicitly asked.
- Treat `git commit`, `git push`, `gh pr create`, and `gh stack submit` as unauthorized for non-trivial work unless applicable verification has passed in the current session.
- Before committing or pushing, verify no secrets are included.
- NEVER use hacks to bypass the type system or linters (e.g., `// @ts-ignore`, suppressing linter warnings) unless explicitly directed.
- NEVER commit `.env` files or expose API keys, tokens, or secrets in any output.
- Bug fixes follow TDD red-green: write a failing test first (red), then implement the fix (green).

## Version Control

Use Git for local version control, Worktrunk for worktree management, and `gh` for GitHub and pull request operations.

- Use `git status`, `git diff`, `git log`, and `git show` for inspection.
- Use `wt list` before writable work. Use `wt switch --create <branch>` for a new task and `wt switch <branch>` only for an existing worktree assigned to that task.
- Keep commits scoped to the approved change.
- Use ordinary PRs by default. Use a stack only when two or more approved slices form a strict dependency chain and work must continue before lower PRs merge; use separate worktrees and PRs for independent changes.
- For a stack, create one worktree for the bottom branch, run `gh stack init <bottom-branch>`, then use `gh stack add <branch>` and stack navigation inside that worktree.
- Run stack commands non-interactively: `gh stack submit --auto --open`, `gh stack view --json`, and `gh stack merge <stack-or-pr> --yes --squash`. Never merge a stacked PR with `gh pr merge`.
- Continue merging through GitHub; do not use `wt merge`. After merging, synchronize stacks with `gh stack sync --prune`, then remove finished worktrees with `wt remove`.

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

Before non-trivial implementation, inspect the relevant code and present a concise plan covering intended behavior, approach, likely scope, risks or open questions, and verification. Keep the plan proportional to the change and wait for approval once.

Prefer one complete, coherent PR. Split only when every PR is independently useful, production-quality, and consistent with the intended final architecture. If all later PRs were cancelled, each earlier PR must still be an implementation worth keeping.

Expected files and estimated size are forecasts, not hard boundaries. Use snippets or diagrams only when they clarify a non-obvious interface or architectural decision.

After approval, implement the agreed behavior continuously. Reasonable supporting changes are included when required to complete it. Never introduce temporary abstractions, compatibility layers, duplicate implementations, disabled production paths, or throwaway APIs solely to make a change smaller.

Stop and ask only when intended behavior becomes ambiguous, the architecture or risk changes materially, or the work expands into an unrelated subsystem. File count or changed LOC alone is not a reason to stop.

Run the smallest relevant automated checks and inspect the complete diff before publishing. If applicable verification cannot run or fails, report that status and wait before publishing. Perform a deep review when the user explicitly asks; use an independent reviewer only when explicitly requested.

Main session handles implementation by default; delegate only when a required skill explicitly asks for a subagent.

Use `code-simplification` only for separate cleanup PRs or explicitly requested follow-up.

Do not create a separate feature spec by default; the PR plan is the lightweight spec unless the feature is ambiguous, high-risk, product-defining, or likely to span multiple sessions.

When stuck, try 2–3 approaches before asking. If still blocked, ask with context on what you tried.

## Tooling

- GitHub username: charliesbot
- gh CLI is available globally
- Worktrunk (`wt`) is available globally and exclusively manages worktree lifecycle.
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
