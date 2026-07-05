-- Python. Server: pyright (types). Formatter/linter: ruff.
return {
  server = 'pyright',
  mason = { 'ruff' },
  parsers = { 'python' },
  formatters = { python = { 'ruff_format' } },
}
