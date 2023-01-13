require("flutter-tools").setup()

require("telescope").load_extension("flutter")

local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<leader>f", ":Telescope flutter commands<CR>", opts)
