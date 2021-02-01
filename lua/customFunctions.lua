-- Create new file from current buffer path
function createNewFile(fileName)
  local execute = vim.api.nvim_command
  execute(string.format("vnew %:h/", fileName))
end
