-- Create new file from current buffer path
vim.api.nvim_create_user_command("Nfile", function(opts)
  local filename = opts.fargs[1]
  vim.cmd("vnew %:h/" .. filename)
end, { nargs = 1 })
