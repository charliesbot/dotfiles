## Subagent Definition Validation

### 1. Description is too vague (High severity)

`description: helps with stuff` gives the runtime no useful signal for when to invoke this agent. The description is what the parent model reads to decide whether to delegate a task — a description this generic makes routing impossible.

Fix: Write a specific, action-oriented description naming the domain and task types. Example: `description: Answers questions about the codebase by reading files, searching for patterns, and summarizing findings.`

### 2. System prompt is too generic (High severity)

"Do your best to help the user with whatever they need" gives the agent no identity, no scope, no constraints, and no behavioral rules. A good subagent prompt should state what it specializes in, define what it should and should not do, and give concrete behavioral instructions.

Fix: Rewrite to be specific about role, scope, and operating constraints.

### 3. Overly broad toolset (Medium severity)

Granting `Write`, `Edit`, and `Bash` to a generic agent with no scoped prompt is risky. These tools can modify files and execute arbitrary shell commands. Without a tightly scoped prompt constraining their use, unintended side effects are likely.

Fix: Remove tools not required for the stated purpose, or explicitly restrict their use in the system prompt.

### 4. `Agent` tool included without justification (Medium severity)

The `Agent` tool allows this subagent to spawn further subagents, creating recursive delegation chains that are hard to audit. This should only be included when orchestration is an explicit part of the agent's design.

Fix: Remove `Agent` unless this agent is intentionally an orchestrator.

### 5. Model alias is ambiguous (Low severity)

`model: sonnet` is an informal alias that may resolve to an unexpected version as new models are released, or may fail to resolve entirely.

Fix: Use a fully qualified model ID such as `model: claude-sonnet-4-6` to pin behavior.

### 6. Name is not descriptive (Low severity)

`my-helper` is placeholder-style. Agent names appear in logs and orchestration tooling and should reflect the agent's actual function.

Fix: Use a name that reflects the domain, e.g. `codebase-explorer` or `file-summarizer`.

---

**Summary:** The file has valid YAML frontmatter structure but fails on content quality across every field. The description and prompt provide no useful specialization, the toolset is overly permissive, and the model reference is ambiguous.
