local keymap = vim.api.nvim_set_keymap

vim.o.completeopt = "menuone,noselect,noinsert"

vim.g.coq_settings = {
    ["auto_start"] = true,
    ["keymap.jump_to_mark"] = "<c-n>",
    ["clients.tmux.enabled"] = true,
    ["clients.tree_sitter.enabled"] = false,
    ['display.preview.positions'] = {east = 1, north = 2, south = 3, west = 4}
}

keymap("i", '<Tab>',
       [=[pumvisible() ? (complete_info().selected == -1 ? "\<C-e><Tab>" : "\<C-y>") : "\<Tab>"]=],
       {expr = true, silent = true})
