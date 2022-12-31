require("lualine").setup({
	options = { theme = "auto" },
	sections = {
		lualine_a = { { "mode", lower = false } },
		lualine_b = { "filename" },
		lualine_c = {
			{
				"diagnostics",
				sources = { "nvim_diagnostic", "coc" },
				symbols = { error = "E: ", warn = "W: ", info = "I: ", hint = "H: " },
			},
		},
		lualine_x = { "encoding", "filetype" },
	},
})
