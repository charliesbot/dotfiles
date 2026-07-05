-- Rust. Server: rust_analyzer. Formatter: rustfmt (from the rust toolchain;
-- conform falls back to LSP formatting if rustfmt is not present).
return {
  server = 'rust_analyzer',
  parsers = { 'rust' },
  formatters = { rust = { 'rustfmt' } },
}
