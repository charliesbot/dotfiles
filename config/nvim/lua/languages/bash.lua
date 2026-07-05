-- Bash / shell. Server: bashls. Formatter: shfmt.
return {
  server = 'bashls',
  mason = { 'shfmt' },
  parsers = { 'bash' },
  formatters = { sh = { 'shfmt' }, bash = { 'shfmt' } },
}
