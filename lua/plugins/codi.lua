vim.g['codi#width'] = 50.0
-- vim.g['codi#virtual_text'] = 0
vim.g['codi#rightalign'] = 0

local languages = {'cpp', 'javascript', 'python', 'lua'}

function _G.fullScreenScratch(fileType)
    -- store filetype and bufnr of current buffer
    -- for later reference
    -- local currentBufFt  = vim.bo.filetype
    local winnr = vim.fn.win_getid()
    local bufnr = vim.api.nvim_win_get_buf(winnr)
    vim.cmd("tabe | setlocal buftype=nofile noswapfile modifiable buflisted")
    -- vim.bo.filetype = currentBufFt
    vim.bo.filetype = fileType
    vim.api.nvim_buf_set_keymap(0, 'n', '<leader><leader>', ':q!<Cr>',
                                {noremap = true, silent = true})
    vim.cmd("Codi")
end

-- vim.api.nvim_set_keymap('n', '<leader><leader>', ':call v:lua.fullScreenScratch()<Cr>', { noremap = false, silent = true })

-- Invoque UI Modal

function _G.selectScratchpad(code)
    if code == -1 then
        return
    else
        fullScreenScratch(languages[code + 1])
    end
end

vim.cmd([[
  func! SelectScratchpad(code)
   call v:lua.selectScratchpad(a:code)
  endfunc
]])

vim.cmd("let content = ['C++','Typescript', 'Python', 'Lua']")
vim.cmd(
    "let opts = {'title': 'Playground', 'w': 30, 'callback': 'SelectScratchpad', 'index':g:quickui#listbox#cursor }")
-- vim.cmd("call quickui#listbox#open(content, opts)")

vim.api.nvim_set_keymap('n', '<leader><leader>', ':call quickui#listbox#open(content, opts)<Cr>',
                        {noremap = false, silent = true})
