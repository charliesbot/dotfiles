---
name: implementation-reviewer
description: >
  Use after completing a non-trivial implementation slice before describing,
  pushing, or opening a PR. Starts a fresh reviewer subagent when possible,
  verifies the implementation against the approved plan, diff, tests, and
  project standards, and requires PASS before proceeding.
---

# Implementation Reviewer

Use this skill as the review gate for completed non-trivial implementation work.
The skill does not perform the review in the main session by default; it routes
the work to a fresh reviewer context.

## Required Action

Start a fresh reviewer subagent now.

Use `references/reviewer-subagent-prompt.md` as the subagent's primary prompt.
Do not summarize or reinterpret that prompt. Add task-specific context below it:

- User request and approved plan or implementation slice
- Non-goals and expected file list, if known
- Implementer report, if available
- Current diff scope or changed files list
- Verification commands run and results
- Any repo-specific instructions the reviewer needs

The reviewer subagent must not edit files. It must return exactly one terminal
status: `PASS` or `NEEDS FIXES`.

## Review Loop

If the reviewer returns `NEEDS FIXES`, resolve the findings in the main session
or implementation session, then use this skill again with a new fresh reviewer
subagent. Never resume a previous reviewer subagent for re-review.

Do not describe, push, open a PR, or move past the review gate until a reviewer
subagent reports `PASS` in the current session.

## Fallback

If the runtime cannot create subagents, perform the review in the main session
using `references/reviewer-subagent-prompt.md` and clearly report that subagent
dispatch was unavailable. The same `PASS` / `NEEDS FIXES` gate still applies.
