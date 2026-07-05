-- Markdown. No language server, just parsers + formatting via prettierd.
return {
  mason = { 'prettierd' },
  parsers = { 'markdown', 'markdown_inline' },
  formatters = { markdown = { 'prettierd' } },
}
