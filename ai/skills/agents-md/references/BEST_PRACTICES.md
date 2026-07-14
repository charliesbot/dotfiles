# AGENTS.md Best Practices

Patterns extracted from official Claude and Gemini documentation plus community research, cross-referenced for universal applicability. These apply to any AGENTS.md read by AI coding agents.

## Table of Contents

- [How Agents Read Instructions](#how-agents-read-instructions)
- [Instruction Budget](#instruction-budget)
- [File Length](#file-length)
- [Structure](#structure)
- [The Include/Exclude Test](#the-includeexclude-test)
- [Writing Effective Instructions](#writing-effective-instructions)
- [Common Sections](#common-sections)
- [Anti-Patterns](#anti-patterns)
- [Modularity with @imports](#modularity-with-imports)
- [Refactor vs Patch Decision Framework](#refactor-vs-patch-decision-framework)

## How Agents Read Instructions

Both Claude and Gemini load AGENTS.md (via symlinks to CLAUDE.md / GEMINI.md) at the start of every session. The content is injected into the context window alongside the user's conversation. This means:

- Every line costs tokens on every prompt, not just the first one
- Instructions compete with the actual conversation for the agent's attention
- Longer files dilute the signal — the agent has more to weigh and may deprioritize some rules
- The agent treats these as guidance, not hard enforcement — specificity is what drives compliance

Both platforms walk up the directory tree and concatenate all found files. Files don't override each other; they stack. Contradictions across files at different levels create ambiguity the agent resolves arbitrarily.

**Periphery bias:** Research shows agents weight instructions at the beginning and end of the file more heavily than the middle. Front-load your most critical rules, and don't let the file trail off into low-value content at the end.

## Instruction Budget

Frontier models reliably follow ~150-200 discrete instructions. The agent's own system prompt already consumes roughly 50 of those. That leaves you ~100-150 instructions before compliance starts degrading — not per file, but across _all_ loaded instruction files combined (AGENTS.md, subdirectory files, imported files, rules).

This budget is the core constraint. Every instruction you add pushes something else closer to being ignored. Treat each line like it costs money — because in token terms, it does.

## File Length

**Target: under 200 lines. Ideal: under 100 lines.**

Both platforms document 200 lines as the practical limit for reliable instruction-following. But research from teams using these tools daily suggests shorter is better — some effective AGENTS.md files are under 60 lines.

**The conciseness test:** For each instruction, ask: "Would removing this cause the agent to make mistakes?" If the agent would do the right thing without the instruction — because it's a standard language convention, or it's obvious from reading the code — delete it.

If your file exceeds 200 lines:

1. Apply the conciseness test aggressively
2. Cut vague instructions that don't add actionable value
3. Remove redundancy (saying the same thing two ways doesn't help)
4. Move detailed reference material into `@imported` files
5. Use `file:line` pointers instead of inline code snippets

## Structure

Use markdown headers (`##`) to group related instructions. Agents scan structure the same way humans do — organized sections are easier to follow than a flat list or wall of text.

### Recommended Ordering

Front-load what matters most, close strong:

1. **Project identity** — what this project is, in one line
2. **Critical rules / Never** — the hard constraints that prevent the most damage
3. **Priorities** — the ranked values that break ties (e.g., `correctness > simplicity > performance`)
4. **Tech stack and architecture** — what the agent is working with
5. **Coding standards** — formatting, naming, patterns
6. **Workflow** — how to build, test, deploy
7. **Common commands** — build, test, lint, format
8. **Tooling context** — available CLIs, services, usernames

This ordering puts high-stakes instructions at the top where the agent weights them most. Reference material goes at the bottom where it's accessible but doesn't crowd out behavioral rules.

### Alternative: WHY / WHAT / HOW

Some teams prefer organizing around three questions:

- **WHY** — the project's purpose and each component's function
- **WHAT** — tech stack, project structure, codebase map
- **HOW** — workflows, commands, verification steps

Both structures work. Pick one and be consistent.

## The Include/Exclude Test

Not everything belongs in AGENTS.md. The file should contain rules and decisions that aren't obvious from reading the codebase.

| Include                                              | Exclude                                               |
| ---------------------------------------------------- | ----------------------------------------------------- |
| Bash commands the agent can't guess                  | Anything the agent can figure out by reading code     |
| Code style rules that differ from defaults           | Standard language conventions the agent already knows |
| Testing instructions and preferred test runners      | Detailed API documentation (link to docs instead)     |
| Repository etiquette (branch naming, PR conventions) | Information that changes frequently                   |
| Architectural decisions specific to your project     | Long explanations or tutorials                        |
| Developer environment quirks (required env vars)     | File-by-file descriptions of the codebase             |
| Common gotchas or non-obvious behaviors              | Self-evident practices like "write clean code"        |

**Don't use AGENTS.md as a linter.** Code style enforcement belongs in deterministic tools (ESLint, Biome, Spotless, Prettier). Agents are unreliable at enforcing formatting rules consistently. Let the agent focus on logic; let linters handle style.

## Writing Effective Instructions

### Be Specific and Verifiable

Every instruction should pass this test: "Could someone objectively check whether the agent followed this?"

| Vague (bad)            | Specific (good)                                                          |
| ---------------------- | ------------------------------------------------------------------------ |
| Write clean code       | Use 2-space indentation in all TypeScript files                          |
| Test your changes      | Run `npm test` before committing                                         |
| Keep files organized   | API handlers live in `src/api/handlers/`                                 |
| Use good naming        | Prefix interfaces with `I` (e.g., `IUserService`)                        |
| Handle errors properly | Wrap external API calls in try/catch and log the error before rethrowing |

### Use Imperative Form

Write instructions as commands, not descriptions. The agent is receiving orders, not reading documentation.

- "Use `pnpm` for all package operations" — not "We use pnpm in this project"
- "Run `./gradlew spotlessApply` before committing" — not "Spotless is our formatter"
- "Place all domain models in `core/domain/model/`" — not "Domain models are kept in core"

### Explain Why (When Non-Obvious)

Agents follow instructions better when they understand the motivation. If a rule would surprise someone new to the project, add a short reason.

- "Do not add dependencies between feature modules — features depend only on `:core`. This prevents the codebase from becoming a tangled dependency graph as it grows."
- "Lock down Firestore security rules from day one, even for prototypes. An open rule set in production has caused incidents before."

Skip the "why" for universally obvious rules like "don't commit secrets."

### Use Emphasis Sparingly but Strategically

Adding "IMPORTANT" or bold text to a critical rule can improve adherence. But overuse dilutes the signal — if everything is important, nothing is. Reserve emphasis for the 2-3 rules that matter most. If you find yourself writing "ALWAYS" or "NEVER" in caps on every other line, the real problem is the instruction isn't clear enough. Rewrite it and explain the reasoning instead.

### Prefer Pointers Over Inline Content

Instead of pasting a 30-line code snippet into AGENTS.md, point to the source:

- "Follow the pattern in `src/api/handlers/users.ts:15-40` for new API endpoints"
- "See `@docs/deployment.md` for the full deploy checklist"

This keeps the main file lean and avoids stale duplicated content.

## Common Sections

Not every project needs all of these — include what's relevant.

### Project Identity

One or two lines explaining what the project is. Gives the agent baseline context for all decisions.

### Priorities

A ranked list of what matters most. Agents use this to break ties when instructions conflict or are ambiguous. Example: `correctness > simplicity > performance > readability`.

### Tech Stack

A table or short list of the technology choices. Prevents the agent from suggesting alternatives or using the wrong tools.

### Architecture / Project Structure

Where files go, how modules relate, dependency rules. One of the highest-value sections — agents frequently create files in wrong locations without it.

### Coding Standards

Formatting, naming conventions, patterns to use/avoid. Be specific. But remember: if a linter can enforce it, let the linter enforce it.

### Workflow

How changes flow from code to production. Build steps, test requirements, commit conventions, deploy process.

### Common Commands

The exact commands to build, test, lint, format, deploy. Agents use these verbatim, so get them right.

### Do Not / Never

Hard constraints. Things the agent must avoid. Keep this section short and specific — a long "never" list becomes noise. 5-7 items is a good ceiling.

### Tooling Context

Available CLIs, service accounts, usernames, environments. Context the agent can't discover on its own.

## Anti-Patterns

### The Encyclopedia

An AGENTS.md that tries to document everything about the project. Most of that information is already in the code, README, or can be discovered by the agent. The instructions file should contain rules and decisions that aren't obvious from reading the codebase.

### The Wishlist

Vague aspirational instructions like "write maintainable code" or "follow best practices." These burn tokens without changing behavior.

### The Changelog

Instructions that include historical context ("we used to use X but switched to Y in Q3"). The agent doesn't need the history — it needs the current rule.

### The Linter

Using AGENTS.md to enforce code formatting. Agents are unreliable at consistent style enforcement. Use deterministic tools instead.

### Contradictions Across Levels

A project AGENTS.md says "use tabs" while a subdirectory AGENTS.md says "use spaces." Both get loaded and concatenated. The agent picks one arbitrarily. Audit for contradictions periodically, especially in monorepos.

### Scope Mixing

Personal preferences ("I like dark mode in the terminal") mixed with project standards ("use ESLint"). Personal preferences belong in user-level files (`~/.claude/CLAUDE.md` or `~/.gemini/GEMINI.md`), not in the shared project AGENTS.md.

### Repeating the Same Rule

Saying the same thing in three different sections doesn't make the agent follow it 3x harder. It wastes tokens and creates maintenance burden when you need to update the rule.

### The Auto-Generated Template

Using `/init` or similar commands and never refining the output. Auto-generated files are a starting point, not a finished product. AGENTS.md is a high-leverage configuration point — every line affects every session. Manually review and trim.

## Modularity with @imports

Both Claude and Gemini support `@path/to/file.md` syntax to import additional files into the instructions context. Paths resolve relative to the file containing the import.

Use imports when:

- Your main file exceeds 200 lines
- You have detailed reference material (architecture docs, deployment guides) that the agent needs access to
- Multiple AGENTS.md files across a monorepo share common rules

Keep the main AGENTS.md as a concise index with pointers:

```markdown
# My Project

Core rules live here (under 200 lines).

For deployment details, see @docs/deployment.md
For API conventions, see @docs/api-guide.md
```

Imports are expanded at load time — the agent sees the full content, not the `@` reference. Remember that imported content counts against the instruction budget too.

## Refactor vs Patch Decision Framework

Score the existing file on these dimensions (1-3 each):

| Dimension           | 1 (Good)                               | 2 (Needs Work)                      | 3 (Bad)                                   |
| ------------------- | -------------------------------------- | ----------------------------------- | ----------------------------------------- |
| **Length**          | Under 100 lines                        | 100-200 lines                       | Over 200 lines                            |
| **Structure**       | Clear headers, logical grouping        | Some headers, inconsistent grouping | No headers or wall of text                |
| **Specificity**     | Mostly verifiable instructions         | Mixed specific and vague            | Mostly vague                              |
| **Contradictions**  | None found                             | 1-2 minor conflicts                 | Multiple or major conflicts               |
| **Scope**           | Clean project-level only               | Minor personal leakage              | Heavily mixed                             |
| **Signal-to-noise** | Every line passes the conciseness test | Some dead weight                    | Heavy with things the agent already knows |
| **Completeness**    | All key sections present               | 1-2 sections missing                | 3+ sections missing                       |

**Total 7-8: Patch not needed.** The file is healthy. Report and stop.

**Total 9-12: Patch.** The file is solid but has gaps. Add what's missing, sharpen what's vague.

**Total 13-16: Judgment call.** Could go either way. Lean toward patching if the user's voice and organization are worth preserving.

**Total 17-21: Refactor.** The file needs a fresh start. Preserve intent, rewrite structure.
