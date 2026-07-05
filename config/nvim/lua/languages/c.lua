-- C / C++. Server: clangd (with the tuned flags). Formatter: clang-format.
return {
  server = {
    name = 'clangd',
    cmd = {
      'clangd',
      '--background-index',
      '--clang-tidy',
      '--header-insertion=iwyu',
      '--completion-style=detailed',
      '--function-arg-placeholders',
      '--fallback-style=llvm',
    },
    init_options = {
      usePlaceholders = true,
      completeUnimported = true,
      clangdFileStatus = true,
    },
  },
  mason = { 'clang-format' },
  parsers = { 'c', 'cpp' },
  formatters = { c = { 'clang-format' }, cpp = { 'clang-format' } },
}
