---
name: project-prd
description: >-
  Create or update a living docs/PRD.md for a new personal project. Use when
  starting a new project, shaping a rough project idea, drafting a project PRD,
  turning an idea into a north-star document, or deciding how a new idea changes
  an existing project's PRD. The PRD is project-level, not feature-level: it
  defines what the project is, the North Star, research worth preserving, Phase
  0 as a minimal-but-great canvas, and later ideas.
---

Turn playful project ideas into a living `docs/PRD.md`.

This is not a corporate PRD. It is a short north-star document for personal projects: clear enough to resume later, scoped enough to avoid sprawl, and flexible enough to evolve.

## Core Behavior

- Start with chat. Do not write `docs/PRD.md` until the idea has landed.
- Treat the PRD as project-level, not feature-level.
- Push back gently when the idea is vague, too broad, or trying to become many products.
- Keep the tone practical and direct. Avoid startup/product-management filler.
- Preserve research so future sessions do not have to rediscover APIs, links, constraints, platform quirks, or technical decisions.
- Scope `Phase 0: Canvas` as the current goal: the minimal-but-great first version that makes the project real and gives future ideas somewhere to land.
- Treat `Later` as a holding area, not a backlog.
- For existing projects, evaluate new ideas against the current PRD before changing it.
- When creating a new PRD, use `assets/PRD.md` as the canonical template and write the finished document to `docs/PRD.md`.
- Phase 0 should create the usable canvas, not chase completeness. Example: for a reading app, Phase 0 is "list books and open one readable file", not sync, dictionaries, covers, or settings.

## Interview Flow

Ask only what is needed to land the PRD. Prefer one or two questions at a time.

Cover these decisions:

1. What is this project?
2. What is the exciting North Star?
3. What research, links, APIs, constraints, or decisions should be preserved?
4. What is the Phase 0 canvas: the smallest beautiful foundation?
5. What belongs later because it would distract from Phase 0?

If the user already gave enough context, draft the PRD instead of over-interviewing.

## Pushback Rules

Push back when:

- Phase 0 includes polish, integrations, settings, sync, or secondary modes before the canvas exists.
- The North Star is missing or reads like a task list.
- `Later` ideas are being smuggled into Phase 0.
- The project cannot be described plainly in `What Is This?`.

Pushback should land the idea, not block momentum. Recommend a smaller Phase 0 when needed.

## PRD Template

Create or update `docs/PRD.md` using `assets/PRD.md` as the starting point. Keep the template sections intact unless explicitly requested.

## Editing Existing PRDs

When `docs/PRD.md` already exists:

1. Read it first.
2. Decide whether the new idea changes `What Is This?`, sharpens the `North Star`, adds `Research`, belongs in `Phase 0: Canvas`, or should go to `Later`.
3. Prefer small updates that preserve the current project shape.
4. If the new idea conflicts with the North Star, call that out before editing.

Do not add default sections for context, non-goals, done criteria, personas, market analysis, monetization, timelines, user stories, or implementation checklists unless explicitly requested.
