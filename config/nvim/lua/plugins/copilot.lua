-- GitHub Copilot, inline ghost-text style (VSCode feel). `<Tab>` accepts.
-- hide_during_completion = false keeps the ghost text visible even when the blink
-- menu is open, which is the fix for Copilot "showing nothing".
-- Already authed on this machine; otherwise run `:Copilot auth` once.
return {
  'zbirenbaum/copilot.lua',
  cmd = 'Copilot',
  event = 'InsertEnter',
  opts = {
    suggestion = {
      enabled = true,
      auto_trigger = true,
      hide_during_completion = false,
      debounce = 75,
      keymap = {
        accept = '<Tab>',
        accept_word = false,
        accept_line = false,
        next = '<M-]>',
        prev = '<M-[>',
        dismiss = '<C-]>',
      },
    },
    panel = { enabled = false },
    filetypes = {
      yaml = false,
      markdown = false,
      help = false,
      gitcommit = false,
      gitrebase = false,
      ['.'] = false,
    },
  },
}
