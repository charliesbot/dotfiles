-- Create new file from current buffer path
function _G.createNewFile(fileName)
    vim.cmd("vnew %:h/" .. fileName)
end

vim.cmd("command! -nargs=1 Nfile call v:lua.createNewFile(<f-args>)")
