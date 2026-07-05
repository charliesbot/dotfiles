-- TypeScript / JavaScript. Server: ts_ls. Formatter: prettierd.
return {
  server = 'ts_ls',
  mason = { 'prettierd' },
  parsers = { 'typescript', 'tsx', 'javascript' },
  formatters = {
    typescript = { 'prettierd' },
    typescriptreact = { 'prettierd' },
    javascript = { 'prettierd' },
    javascriptreact = { 'prettierd' },
  },
}
