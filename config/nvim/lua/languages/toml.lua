-- TOML. No language server, just parsing + formatting via Taplo.
return {
  mason = { 'taplo' },
  parsers = { 'toml' },
  formatters = { toml = { 'taplo' } },
}
