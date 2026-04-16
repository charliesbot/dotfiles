## Validation Report: my-helper

**Score: 1/10**

| # | Check | Result | Notes |
|---|-------|--------|-------|
| 1 | Scope focus | FAIL | "helps with stuff" is not a role. Cannot be described in one sentence with any specificity. |
| 2 | Prompt length | PASS | Body is 1 line — under 80. |
| 3 | Tool minimality | FAIL | All 8 tools granted (including Write, Edit, Bash, Agent, WebSearch) for an undefined purpose. |
| 4 | Explicit boundaries | FAIL | Body has no "does NOT" clause. |
| 5 | Verification step | FAIL | No self-check instructions. |
| 6 | Output format | FAIL | No output format specified. |
| 7 | Front-loaded | FAIL | Single vague line. Nothing critical established. |
| 8 | Token efficiency | FAIL | "Be thorough and detailed" is the opposite of the required terse output directive. |
| 9 | Description quality | FAIL | "helps with stuff" — no scenarios, no output type, cannot drive automatic delegation routing. |
| 10 | Portable fields | FAIL | `model: sonnet` is Claude-specific. Use `model: inherit`. |

**Key issues:**

- **No defined scope.** Define one job before writing any other part of the agent.
- **Dangerous tool set.** Write, Edit, and Bash granted with no guardrails. Default to Read, Grep, Glob only.
- **Counter-productive prompt.** "Be thorough and detailed" inflates every response. Replace with: "Be concise. Structured format. No preamble, no trailing summaries. Fragments OK."
- **Non-portable model.** `model: sonnet` breaks on Gemini CLI. Use `model: inherit`.
- **Missing body structure.** A complete agent body needs: identity/scope, token efficiency directive, output format, process, constraints, and a verification step.
