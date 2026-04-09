---
name: agents-md
description: >
  Improve or create AGENTS.md files that serve as shared instructions for AI coding agents
  (Claude, Gemini, etc.). Use this skill whenever the user mentions AGENTS.md, CLAUDE.md,
  GEMINI.md, agent instructions, agent configuration, or wants to improve how AI agents
  behave in their project. Also trigger when the user says "improve my instructions",
  "agents file", "update my rules", or asks about best practices for configuring coding agents.
  If in doubt and the task involves AI agent instruction files, use this skill.
---

You help users write and improve AGENTS.md files — shared instruction files that AI coding agents (Claude, Gemini, etc.) read at the start of every session. The goal is a single file that works across platforms via symlinks.

Read `references/BEST_PRACTICES.md` before analyzing or writing any AGENTS.md content. It contains the patterns extracted from official documentation that inform every decision below.

## Core Workflow

### 1. Assess the Current State

Before proposing changes, read the target file and evaluate it against these dimensions:

- **Length** — is it under 200 lines? Ideally under 100? Agents have a budget of ~150 instructions they can reliably follow, and the system prompt already uses ~50.
- **Structure** — does it use markdown headers to group related instructions? Or is it a wall of text / a single giant list?
- **Specificity** — are instructions concrete and verifiable ("use 2-space indentation") or vague ("write clean code")?
- **Contradictions** — do any rules conflict with each other?
- **Scope mixing** — does it blend personal preferences with project-level standards?
- **Signal-to-noise** — does every instruction pass the conciseness test ("would removing this cause the agent to make mistakes")? Are there instructions the agent would follow anyway without being told?
- **Completeness** — is it missing key sections (Priorities, Never/Hard Rules, Common Commands, Architecture, Workflow, Tooling)? Score: 1 = all present, 2 = 1-2 missing, 3 = 3+ missing.

### 1b. Exit Gate

After scoring, determine whether to proceed or stop:

- **Score 7–8 (healthy):** Report the assessment, state "No changes recommended," and STOP. Do not propose a patch or refactor.
- **Score 9–12 (minor issues):** Present findings and ask the user if they want changes. Do not propose a patch unless the user confirms.
- **Score 13+ (needs work):** Present findings and proceed to step 2.

**Override:** If the user explicitly requests changes (e.g., "improve," "fix," "update," "rewrite"), skip the exit gate and proceed to step 2 regardless of score. Present findings first, then propose.

### 2. Decide: Patch or Refactor

This is the critical decision. Not every AGENTS.md needs a rewrite.

**Patch** when the file:

- Already has clear section headers
- Is under 200 lines
- Has mostly specific, actionable instructions
- Just needs gaps filled (missing sections, incomplete rules)

A patch preserves the existing structure and voice. Add what's missing, tighten what's vague, remove what contradicts — but don't reorganize a file that's already organized.

**Refactor** when the file:

- Exceeds 200 lines
- Lacks section headers or has inconsistent structure
- Contains mostly vague or unverifiable instructions
- Has significant contradictions or scope mixing
- Would require so many patches that the result would feel Frankenstein'd

A refactor rewrites the file from scratch, preserving the _intent_ of existing instructions while restructuring them into a well-organized format.

### 3. Present the Plan

Always show the user what you intend to do before making changes:

- Whether you're patching or refactoring, and why
- Which sections you'll add, modify, or remove
- For patches: the specific gaps you identified
- For refactors: the proposed new structure with section headers

Wait for approval before writing.

### 4. Write the Instructions

Apply the patterns from `references/BEST_PRACTICES.md`. The output is always a single AGENTS.md file. Key principles while writing:

- Every instruction should be something an agent can act on or verify
- Group related rules under descriptive headers
- Front-load the most important instructions — agents weight earlier content more heavily
- Use the imperative form ("Use X", "Run Y") not descriptive ("We use X", "Y is preferred")
- Explain _why_ when the reason isn't obvious — agents follow instructions better when they understand the motivation

### 5. Validate

After writing, check the result against the assessment dimensions from step 1. Confirm:

- Under 200 lines (ideally under 100), or uses `@imports` to stay modular
- No contradictions
- No vague instructions that survived the edit
- No scope mixing
- No instructions that duplicate what linters/formatters already enforce
- Every line passes the conciseness test — if removing it wouldn't cause mistakes, cut it
- CLAUDE.md and GEMINI.md symlinks point to AGENTS.md (step 6)

### 6. Set Up Symlinks — DO NOT SKIP THIS STEP

Every run of this skill must end with symlinks in place. The output is always `AGENTS.md`, and both `CLAUDE.md` and `GEMINI.md` must be symlinks pointing to it. This is what makes the single-source-of-truth model work — without symlinks, one platform silently stops reading the instructions.

**If CLAUDE.md or GEMINI.md already exist as symlinks:** Confirm they point to AGENTS.md. Report this to the user ("symlinks already in place").

**If they don't exist:** Create them:

```bash
ln -sf AGENTS.md CLAUDE.md
ln -sf AGENTS.md GEMINI.md
```

**If they exist as regular files (not symlinks):** STOP and warn the user before replacing them. They may contain platform-specific content that needs to be merged into AGENTS.md first. Show the user what would be lost, get approval, then replace with symlinks.

**If the user asked for a "CLAUDE.md" or "GEMINI.md":** Still create AGENTS.md as the source and symlink the requested name to it.

## What This Skill Does NOT Do

- It doesn't create `.claude/rules/` files or platform-specific configuration — those are separate concerns
- It doesn't manage `settings.json` for either platform
- It doesn't handle auto-memory configuration
- It doesn't split a single AGENTS.md into separate CLAUDE.md and GEMINI.md — the whole point is one file, symlinked

## Common Scenarios

**"I don't have an AGENTS.md yet"**
Run the bundled discovery script first: `${CLAUDE_SKILL_DIR}/scripts/discover.sh <project-root>`. It detects the stack, commands, directory structure, and existing agent files — no AI tokens spent on exploration. Present the discovery summary to the user, then draft an AGENTS.md based on it. Only ask about things the script can't discover — like workflow preferences, deployment targets, or team conventions that aren't encoded in config files.

**"My AGENTS.md is too long"**
Audit for redundancy, vague instructions that can be cut, and sections that belong in `@imported` reference files rather than the main body. The main AGENTS.md should be an index of high-signal instructions, not an encyclopedia.

**"Agents keep ignoring my instructions"**
Three common causes: (1) the file is too long and instructions are getting lost in the noise — prune aggressively, (2) the instructions are too vague to act on — rewrite until objectively verifiable, (3) style rules that should be enforced by a linter, not an agent. If the agent does something wrong despite a rule against it, the file is probably too long and the rule is getting lost.

**"I want to add rules for a new project/area"**
Run the full assessment first. If the file is already in good shape, slot the new rules into the existing structure. If adding them reveals deeper issues (the file is already at capacity, the structure doesn't accommodate the new area cleanly), the assessment will surface that and may recommend a refactor instead.
