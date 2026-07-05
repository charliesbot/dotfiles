# Modern AI Neovim

A plan to rebuild the Neovim config at `config/nvim` into a lean, modern,
AI-native setup on Neovim 0.12. The current config is a kickstart.nvim fork.
This replaces it with a config you own and rarely have to touch.

## North Star

Stop configuring, start drafting projects. The editor should boot into a calm
focused environment, autocomplete with a model of my choosing, format on save,
and get out of the way. Eye candy is welcome as long as it stays quiet enough
for an ADHD brain to focus.

## Principles

- **Minimal surface.** Fewer plugins, each doing real work. No educational cruft.
- **Low churn.** Once it works I should not be nudged to keep tweaking it.
- **Bindings are sacred.** Muscle memory carries over verbatim. See the inventory below.
- **Focus first.** Distraction-free tools (zen, dim) are first-class, not add-ons.
- **jj, not git.** Version control tooling assumes jujutsu, with git colocated only where a plugin needs it.
- **Native 0.12.** Use `vim.lsp.config` / `vim.lsp.enable`, treesitter `main`, `vim.hl`, `vim.diagnostic.jump`.

## Decisions (settled)

| Area            | Choice                                                                                    |
| --------------- | ----------------------------------------------------------------------------------------- |
| Migration style | Clean modular rebuild, bindings ported verbatim                                           |
| UI core         | `folke/snacks.nvim` (picker, explorer, dashboard, zen, dim, notifier, sessions, terminal) |
| AI autocomplete | `minuet-ai.nvim` with two backends: local Qwen via Ollama, remote via OpenRouter          |
| File navigation | `oil.nvim` for editing paths, snacks explorer as the toggleable sidebar                   |
| Working set     | `harpoon` for the per-project curated file list                                           |
| Sessions        | None. Always start fresh, never save or restore buffers or layout                         |
| Completion menu | `blink.cmp` (kept)                                                                        |
| Formatting      | `conform.nvim` format-on-save (kept)                                                      |
| Theme           | `catppuccin` mocha (kept)                                                                 |

## Navigation model

How I actually move around, which drives several plugin choices:

- **Splits, not tabs.** Layout is vertical splits arranged by hand per task.
  No bufferline, no tab bar, no buffer strip to scan. Navigation is by jumping,
  not by clicking a list.
- **Buffers are disposable.** Open files are invisible plumbing. Closing a file
  means it leaves my attention. Nothing should nag me with a lingering list.
- **A curated set in hand per project.** The three or four files a task revolves
  around, reachable in one keystroke each.

This maps to three tools working together:

- **harpoon** is the curated set. Pin the files that matter, jump with a single
  key. This is the primary way I move between files, ahead of the picker. The
  pin list persists per project, so reopening a repo brings back the working set
  even though the split layout starts blank.
- **snacks.bufdelete** makes "closed means gone" literally true. It drops a
  buffer without tearing down the split layout, unlike a bare window close which
  leaves the buffer loaded in the background.

No sessions. Layout starts fresh every launch, arranged by hand, which I prefer.
Harpoon brings the files back in one keystroke, buffers stay disposable, no tabs.

## Target file layout

A clean module split so each concern lives in one small file.

```
config/nvim/
  init.lua                 -- leader, bootstrap lazy, require config modules
  lua/config/
    options.lua            -- vim.o settings (ported from current init.lua)
    keymaps.lua            -- SINGLE source of truth for non-plugin bindings
    autocmds.lua           -- yank highlight, filetype indent rules
    lazy.lua               -- lazy.nvim bootstrap + import plugins/
    languages.lua          -- loader: reads lua/languages/*.lua, wires all subsystems
  lua/languages/           -- ONE file per language, everything about it co-located
    lua.lua                -- server, parsers, formatters, linters, mason tools
    typescript.lua
    c.lua                  -- clangd (c and cpp)
    kotlin.lua             -- official JetBrains kotlin-lsp
    python.lua
    go.lua
    rust.lua
    bash.lua
  lua/plugins/
    ai.lua                 -- minuet-ai + blink integration
    completion.lua         -- blink.cmp + LuaSnip
    lsp.lua                -- vim.lsp.config/enable + mason, fed by languages loader
    treesitter.lua         -- nvim-treesitter (frozen main), parsers from loader
    format.lua             -- conform.nvim + format on save, formatters from loader
    editor.lua             -- oil, mini.ai/surround/pairs, guess-indent, todo-comments
    ui.lua                 -- snacks, catppuccin, lualine, which-key, dropbar
    git.lua                -- gitsigns (jj colocated) + jj terminal helper
```

`lua/config/keymaps.lua` is deliberately the one place I look when a binding
feels wrong. Plugin-specific keys still live with their plugin spec, but the
global muscle-memory keys are all in one file.

## Binding inventory to preserve

Everything below must behave identically after the rebuild. Where the backing
plugin changes (Telescope to snacks, neo-tree to snacks explorer, Copilot to
minuet) the key stays, only the implementation moves.

### Global (normal, unless noted)

| Key                        | Action                        | Backing after rebuild                              |
| -------------------------- | ----------------------------- | -------------------------------------------------- |
| `<Esc>`                    | Clear search highlight        | native                                             |
| `<leader>q`                | Diagnostics to loclist        | native                                             |
| `<leader>n`                | Next diagnostic               | `vim.diagnostic.jump` (was deprecated `goto_next`) |
| `<leader>m`                | Previous diagnostic           | `vim.diagnostic.jump` (was deprecated `goto_prev`) |
| `<C-h>` / `<C-l>`          | Focus window left / right     | native                                             |
| `<leader>v` / `<leader>V`  | Vertical split / vertical new | native                                             |
| `<C-p>`                    | Find files                    | snacks picker (was Telescope)                      |
| `<C-f>`                    | Live grep                     | snacks picker (was Telescope)                      |
| `<C-j>` / `<C-k>`          | Move line down / up           | native                                             |
| `<C-b>`                    | Toggle sidebar                | snacks explorer (was neo-tree)                     |
| `<leader>x`                | Close file, keep the split    | snacks bufdelete (new)                             |
| `<C-j>` / `<C-k>` (visual) | Move selection down / up      | native                                             |
| `<Esc><Esc>` (terminal)    | Exit terminal mode            | native                                             |

### Working set (harpoon, new)

`<leader>h` add current file to the list, `<leader>e` toggle the harpoon menu,
`<leader>1` to `<leader>5` jump to pinned files. `<leader>e` is normal-mode and
does not conflict with blink's insert-mode `<C-e>`.

### Search family (`<leader>s*`, was Telescope, now snacks picker)

`sh` help, `sk` keymaps, `sf` files, `ss` pickers list, `sw` current word,
`sg` grep, `sd` diagnostics, `sr` resume, `s.` recent files, `sn` search config,
`<leader><leader>` buffers, `<leader>/` fuzzy in buffer, `<leader>s/` grep open buffers.

### LSP (buffer-local)

`grn` rename, `gra` code action, `grr` references, `gri` implementation,
`gd` definition, `gD` declaration, `gO` document symbols, `gW` workspace symbols,
`grt` type definition, `gh` hover, `<leader>th` toggle inlay hints. References,
implementation, definition, symbols route through the snacks picker.

### Completion and AI (insert)

`<C-n>` / `<C-p>` select next / prev, `<CR>` accept, `<C-e>` hide, `<C-space>`
show or toggle docs, `<C-k>` toggle docs, `<Up>` / `<Down>` select. **`<Tab>`
accepts the AI ghost-text suggestion** (was Copilot, now minuet virtual text),
so the accept muscle memory is unchanged.

### Breadcrumb (dropbar, kept)

`<leader>;` pick, `[;` context start, `];` next context.

## AI autocomplete design (minuet-ai)

`minuet-ai.nvim` is the one AI plugin. It talks to both backends through a single
interface, so switching is a config edit, never a new plugin. minuet authenticates
with API keys and OpenAI-compatible endpoints, so both backends fit it directly:

- **Local Qwen** via Ollama serving `qwen2.5-coder` on the OpenAI-compatible FIM
  endpoint (`openai_fim_compatible` provider). Default for offline, zero-cost work.
- **OpenRouter** via one API key (`openai_compatible` provider). OpenRouter
  aggregates DeepSeek, Claude, GPT, cloud Qwen and more behind a single key, so
  "any remote model" is a model-name change, not a new provider setup. Pay per use.

### On subscription-based auth

minuet cannot consume a ChatGPT or Codex OAuth subscription. That subscription
authorizes the ChatGPT app and Codex CLI, not autocomplete API calls, and the
OpenAI API bills separately on credits. The only inline autocomplete engine that
runs on an OAuth subscription is Copilot itself. Since the goal is to move past
Copilot and Ollama plus OpenRouter covers local and remote, subscription-OAuth is
out of scope for autocomplete. If it is ever wanted, it returns as a small
optional Copilot add-back, kept separate from minuet.

Two integration modes, pick one:

1. **Virtual text (ghost)** like Copilot. `<Tab>` accepts. Feels identical to
   today, lowest visual noise. Recommended default.
2. **blink.cmp source.** Suggestions appear in the completion menu next to LSP
   items. More info-dense, slightly busier.

Keys and endpoints load from environment variables, never committed. A small
`provider` switch at the top of `lua/plugins/ai.lua` selects local vs remote so
I can flip between "on a plane with Qwen" and "DeepSeek for the hard stuff"
without hunting through config.

Lighter alternative if I ever want local-only and nothing else: `llama.vim`
from ggml-org is a purpose-built fast FIM plugin for Qwen. Noted, not chosen.

## Adding a language (the language-pack architecture)

The current biggest pain is that adding one language means editing five tables
across three files: the `servers` table, the mason install list, conform's
`formatters_by_ft`, nvim-lint's `linters_by_ft`, and treesitter's parser list.
Nothing is co-located, so every addition is a scavenger hunt and there is nothing
to "remember" because the language was never defined in one place.

Fix: **one file per language.** Each `lua/languages/<lang>.lua` declares
everything about that language in a single spec, and a small loader
(`lua/config/languages.lua`, written once) wires it into all subsystems.

```lua
-- lua/languages/python.lua
return {
  server     = 'pyright',                         -- LSP: string, or { name, cmd, settings }
  parsers    = { 'python' },                       -- treesitter (parser names)
  formatters = { python = { 'ruff_format' } },     -- conform, keyed by FILETYPE
  linters    = { python = { 'ruff' } },            -- nvim-lint, keyed by FILETYPE
  mason      = { 'pyright', 'ruff' },              -- tools to auto-install
}
```

The loader reads `lua/languages/*.lua`, then feeds:

- `vim.lsp.config` / `vim.lsp.enable` for servers (replaces the deprecated
  `mason-lspconfig` handlers pattern, with `vim.lsp.config('*', { capabilities })`
  as shared defaults),
- `nvim-treesitter` install for parsers,
- `conform` `formatters_by_ft`,
- `nvim-lint` `linters_by_ft`,
- `mason-tool-installer` for the union of all tools.

Mental model becomes one sentence: **new language, add `lua/languages/<lang>.lua`.**
Removing a language is deleting its file. Reading how a language is wired is
opening one file. Two honest notes: filetype and parser name sometimes differ
(for example the `typescriptreact` filetype uses the `tsx` parser), so specs key
formatters and linters by filetype and parsers by parser name explicitly. Gnarly
server config (clangd cmd flags, lua_ls settings) lives in that language's file
as `server = { name = ..., cmd = ..., settings = ... }`, staying co-located.

## Formatting and treesitter, briefly

- **Formatting.** `conform.nvim` with `format_on_save` and `lsp_format = 'fallback'`,
  unchanged in behavior. The formatter map is now populated by the language loader
  rather than hand-edited. `<leader>f` still formats manually.
- **Treesitter.** See the dedicated section below. Short version: pin the archived
  `nvim-treesitter` `main` branch and treat it as frozen. Parser list comes from
  the language loader.

## Treesitter after the archival

Context that changes the naive answer: `nvim-treesitter` was archived on
April 3, 2026 and is read-only. The `main` branch (the rewrite this config
already uses) was its final state and needs Neovim 0.12. Neovim 0.12 core brought
in the treesitter runtime and highlighting via `vim.treesitter.start()`, plus a
small set of bundled parsers only (`c`, `lua`, `markdown`, `markdown_inline`,
`query`, `vim`, `vimdoc`). Core ships no parser manager and no queries for other
languages. Crucially, nvim-treesitter also shipped the curated highlight, indent,
and fold queries that make highlighting good, and core does not replace those.

Two real paths, verified:

**Path A (chosen): keep the archived `nvim-treesitter` `main`, pinned.** It still
installs and runs fine at a locked commit and keeps shipping the curated queries.
Downside is it is frozen, no future updates. This is the lower-maintenance,
higher-quality choice today, which is why it wins.

**Path B (not now): native core plus `tree-sitter-manager.nvim`.** Verified that
it installs both parsers and queries and is actively maintained, but it builds
parsers from source so it needs the tree-sitter CLI and a C compiler on every
machine, and for non-core languages it uses grammar-repo queries, which are
generally lower quality than nvim-treesitter's and can carry Neovim-predicate
quirks. So highlighting works but looks poorer for TypeScript, Go, Kotlin, and Bash.

**Decision:** Path A, pinned and frozen. **Migration trigger to Path B:** when
Neovim core ships native parser management (an `nvim-lspconfig`-style solution is
under discussion) or when a language I use lacks good queries under Path A.

## jj workflow

jj is the daily driver. Plan:

- Projects are a **mix** of jj, plain git, and not-yet-migrated repos.
  `gitsigns.nvim` handles this for free: it paints signs wherever a `.git` exists
  (plain git or colocated jj) and stays quiet on pure jj with no `.git`. When a
  project moves to jj, running `jj git init --colocate` keeps signs working.
  Signs and inline diff work, blame is best-effort under jj.
- A **snacks floating terminal** bound for jj commands (`jj status`, `jj log`,
  `jj diff`) so version control stays inside the editor without a dedicated
  plugin. There is no mature jj-native Neovim UI yet, so a terminal is the
  pragmatic modern answer.

## Focus and eye candy (snacks)

All from the one snacks dependency, so no extra plugin sprawl:

- **Dashboard** on startup with recent projects and files, a calm landing pad.
- **Zen mode** and **dim** for distraction-free drafting, bound to a focus key.
- **Indent guides** via `snacks.indent` (replaces indent-blankline).
- **Notifier** for quiet, non-blocking messages.
- **catppuccin mocha** stays for color. **lualine** stays for the statusline,
  it is already tuned and snacks does not cover statuslines.

## Low-friction project startup

The "just start drafting" goal, kept minimal. No session restore by choice, so
low-friction startup means getting into a fresh, ready project fast:

- **Dashboard project shortcuts** to jump straight into a repo.
- **Harpoon pins** bring the working set back on reopen, no layout restore needed.
- **Templates.** A simple `templates/` directory plus a scaffolding command
  (`:NewProject <template>`) that copies a template and runs `jj git init`.
  No heavyweight generator plugin. This is a small custom command, revisited
  only if it proves too limited.

## Plugin set (target)

Kept: lazy.nvim, nvim-treesitter (archived `main`, pinned and frozen, see above),
nvim-lspconfig, mason stack, fidget, blink.cmp,
LuaSnip, conform.nvim, lazydev, catppuccin, lualine, gitsigns, guess-indent,
todo-comments, mini.ai, mini.surround, dropbar.

Added: snacks.nvim, oil.nvim, minuet-ai.nvim, which-key.nvim, mini.pairs, harpoon.

Dropped: telescope (+fzf-native, +ui-select) to snacks picker, neo-tree (+nui)
to snacks explorer, indent-blankline to snacks.indent, nvim-autopairs to
mini.pairs, copilot.lua to minuet-ai.

## Phased rollout

Small vertical slices, each usable on its own. Start super minimal.

### Phase 1 — Minimal editable core (the "super minimal" milestone)

Modular init, options, keymaps, autocmds, lazy bootstrap, treesitter, native LSP,
blink.cmp, conform format-on-save, catppuccin. No AI, no fancy UI yet. Build the
`lua/config/languages.lua` loader and write the `lua/languages/*.lua` specs for
the real language set: `lua`, `typescript`, `c`/`cpp`, `kotlin`, `python`, `go`,
`rust`, `bash`. Each spec carries its server, parsers, formatters, and mason
tools. Outcome: a fast editor that highlights, completes from LSP, and formats on
save, with all non-plugin bindings in place, and adding a language is a single
new file.

Kotlin note: use the official JetBrains `kotlin-lsp`. Mason packaging for it may
lag, so its language file may need a manual `cmd` path rather than a mason install,
verified when we write `kotlin.lua`.

Verify: open a TS, Lua, and Python file. Confirm highlight, go-to-definition,
hover, and format-on-save. Confirm every global binding in the inventory. Add a
throwaway language file and confirm server, parser, and formatter all come up from
that one file, then delete it.

### Phase 2 — AI autocomplete

Add minuet-ai in ghost-text mode with the provider switch. Wire `<Tab>` accept.
Configure local Qwen endpoint and one remote provider via env vars.

Verify: suggestions appear and `<Tab>` accepts, with local and remote providers.

### Phase 3 — Navigation and working set

Add snacks picker (map all `<leader>s*`, `<C-p>`, `<C-f>`), oil.nvim, snacks
explorer on `<C-b>`, which-key, dropbar. Add harpoon with its `<leader>h`,
`<leader>e`, `<leader>1..5` bindings, and the `<leader>x` close-buffer-keep-split
binding. Harpoon is the primary file-jumping tool, the picker is the fallback
for files not in hand.

Verify: every search-family binding works, oil edits paths, `<C-b>` toggles the
tree, harpoon pins and jumps, `<leader>x` closes a file without collapsing the split.

### Phase 4 — Focus and eye candy

Add snacks dashboard, zen, dim, indent, notifier. Bind a focus toggle.

Verify: dashboard on launch, zen and dim toggle cleanly.

### Phase 5 — jj workflow and project startup

gitsigns (lights up on any `.git`, quiet on pure jj), snacks jj terminal, and the
`:NewProject` template command.

Verify: signs render in a colocated or plain-git repo and stay quiet on pure jj,
jj terminal runs, scaffolding a template lands a ready-to-edit project.

## Open questions

- Which Qwen tag in Ollama (for example `qwen2.5-coder:7b` versus `:3b`), and is
  Ollama on the default `http://localhost:11434`?
- Harpoon pin list: persist per project across restarts (its default and main
  value), or wipe on every launch to match the always-fresh preference?
- Keep `dropbar` breadcrumb, or is that visual noise to cut later?
- Harpoon menu on `<leader>e`: confirm no clash with the `<leader>` search family
  in muscle memory, or prefer `<C-e>` in normal mode instead?
- `<leader>x` for close-buffer: good, or would you rather it live somewhere else?

## Non-goals

- AI chat or agentic editing in-editor. Autocomplete only.
- A jj-native GUI plugin. Terminal is enough.
- Porting kickstart comments or example plugins. Fresh and lean.

```

```
