# Platform Compatibility Map

Reference for field compatibility and tool name mapping between Claude Code and Gemini CLI subagents.

## Portable Subset

These fields work identically on both platforms. Use only these for portable agents.

| Field         | Claude Code   | Gemini CLI    | Notes                                                                                                                           |
| ------------- | ------------- | ------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| `name`        | Required      | Required      | Lowercase + hyphens. Gemini also allows underscores, but hyphens work on both.                                                  |
| `description` | Required      | Required      | Identical semantics. Used for automatic delegation routing.                                                                     |
| `model`       | Optional      | Optional      | Use `inherit` for portability. Platform-specific values (e.g., `sonnet`, `gemini-3-flash-preview`) break on the other platform. |
| Body          | System prompt | System prompt | Fully portable markdown. The agent's entire instruction set.                                                                    |

## Tool Name Mapping

Tool names differ between platforms. The `tools` field must use the correct names for the target platform.

| Capability             | Claude Code | Gemini CLI    |
| ---------------------- | ----------- | ------------- |
| Read files             | `Read`      | `read_file`   |
| Search file content    | `Grep`      | `grep_search` |
| Find files by pattern  | `Glob`      | `glob`        |
| Edit existing files    | `Edit`      | `edit_file`   |
| Create/overwrite files | `Write`     | `write_file`  |
| Run shell commands     | `Bash`      | `shell`       |
| Spawn subagents        | `Agent`     | Not available |
| Web search             | `WebSearch` | Not available |
| Web fetch              | `WebFetch`  | Not available |

### Read-Only Tool Set

For read-only agents (the recommended default):

- **Claude:** `tools: Read, Grep, Glob`
- **Gemini:** `tools: [read_file, grep_search, glob]`

### Read-Write Tool Set

For agents that need to modify files:

- **Claude:** `tools: Read, Grep, Glob, Edit, Write`
- **Gemini:** `tools: [read_file, grep_search, glob, edit_file, write_file]`

### Full Tool Set

For agents that also need shell access:

- **Claude:** `tools: Read, Grep, Glob, Edit, Write, Bash`
- **Gemini:** `tools: [read_file, grep_search, glob, edit_file, write_file, shell]`

## Platform-Specific Fields

### Claude Code Only

| Field             | Type    | Description                                                              |
| ----------------- | ------- | ------------------------------------------------------------------------ |
| `disallowedTools` | array   | Denylist — tools removed from inherited set                              |
| `permissionMode`  | string  | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, `plan` |
| `skills`          | array   | Skills preloaded into context at startup                                 |
| `hooks`           | object  | Lifecycle hooks: `PreToolUse`, `PostToolUse`, `Stop`                     |
| `memory`          | string  | Persistent memory scope: `user`, `project`, `local`                      |
| `background`      | boolean | Always run as background task                                            |
| `effort`          | string  | `low`, `medium`, `high`, `max`                                           |
| `isolation`       | string  | `worktree` for git worktree isolation                                    |
| `color`           | string  | UI color hint                                                            |
| `initialPrompt`   | string  | Auto-submitted first turn when running as session agent                  |

### Gemini CLI Only

| Field          | Type   | Description                                  |
| -------------- | ------ | -------------------------------------------- |
| `temperature`  | number | `0.0`-`2.0`. Lower = more deterministic.     |
| `timeout_mins` | number | Maximum execution duration in minutes        |
| `kind`         | string | `local` (default) or `remote` (A2A protocol) |

### Semantically Equivalent but Different Keys

| Concept                | Claude Code  | Gemini CLI                              |
| ---------------------- | ------------ | --------------------------------------- |
| Max conversation turns | `maxTurns`   | `max_turns`                             |
| MCP server config      | `mcpServers` | `mcpServers` (same key, similar syntax) |

## File Locations

| Scope                 | Claude Code                  | Gemini CLI                   |
| --------------------- | ---------------------------- | ---------------------------- |
| User-level (personal) | `~/.claude/agents/<name>.md` | `~/.gemini/agents/<name>.md` |
| Project-level (team)  | `.claude/agents/<name>.md`   | `.gemini/agents/<name>.md`   |

## Invocation Syntax

| Method               | Claude Code                  | Gemini CLI                       |
| -------------------- | ---------------------------- | -------------------------------- |
| Explicit mention     | `@"agent-name (agent)"`      | `@agent-name`                    |
| Automatic delegation | Based on `description` match | Based on `description` match     |
| Session-wide         | `claude --agent <name>`      | Not available                    |
| Management           | Not available                | `/agents list`, `/agents reload` |
