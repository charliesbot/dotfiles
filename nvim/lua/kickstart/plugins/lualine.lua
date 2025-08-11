return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('lualine').setup {
      options = {
        icons_enabled = vim.g.have_nerd_font,
        theme = 'auto',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
      },
      sections = {
        lualine_a = {
          {
            'mode',
            fmt = function(str)
              return str:sub(1, 1):upper() .. str:sub(2):lower()
            end,
          },
        },
        lualine_b = {},
        lualine_c = {
          {
            'filename',
            color = { bg = '#3b4252', fg = '#d8dee9' },
          },
          {
            'diagnostics',
            symbols = {
              error = ' ',
              warn = ' ',
              info = ' ',
              hint = ' ',
            },
          },
        },
        lualine_x = {
          'filetype',
          {
            'branch',
            icon = ' ',
          },
          {
            'diff',
            symbols = { added = ' ', modified = ' ', removed = ' ' },
            source = function()
              local gitsigns = vim.b.gitsigns_status_dict
              if gitsigns then
                return {
                  added = gitsigns.added,
                  modified = gitsigns.changed,
                  removed = gitsigns.removed,
                }
              end
            end,
          },
        },
        lualine_y = { 'location' },
        lualine_z = {},
      },
    }
  end,
}
