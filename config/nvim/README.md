# nvim

Personal Neovim config — modern, minimal, jj-first. Requires Neovim 0.12+.

- Plugins managed by **lazy.nvim** (`:Lazy`).
- `init.lua` is a thin loader for `lua/config/*`; plugins live in `lua/plugins/*`;
  each language is a single file in `lua/languages/*`.
- Symlinked from the dotfiles repo: `config/nvim` → `~/.config/nvim`.

Design notes and the full rebuild plan: `modern-ai-nvim.md` in the dotfiles root.
