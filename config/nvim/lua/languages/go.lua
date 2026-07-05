-- Go. Server: gopls. Formatter: goimports (formats + manages imports).
return {
  server = 'gopls',
  mason = { 'goimports' },
  parsers = { 'go', 'gomod' },
  formatters = { go = { 'goimports' } },
}
