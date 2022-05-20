--- Default configuration.
--- Provides fallback values not specified in the user config.
--- Please see source file for the default values.
---@module scnvim.config

--- default configuration
local default = {
  ensure_installed = true, -- If installed once, this can be set to false to improve startup time.
  sclang = {
    path = nil, -- Path to the sclang executable. Not needed if `sclang` is already in your $PATH.
    options = {}, -- Command line options passed to the `sclang` executable.
    server_status_interval = 1, -- The interval of updating the server status line
  },
  mapping = {}, -- Mappings, empty by default.
  documentation = {
    cmd = nil, -- Absolute path to the render program (e.g. /opt/homebrew/bin/pandoc)
    -- Options given to the render program. The default options are for
    -- `pandoc`. Any program that can convert html into plain text should work.
    --
    -- The string $1 will be replaced with the input file path and $2 will be
    -- replaced with the output file path.
    args = { '$1', '--from', 'html', '--to', 'plain', '-o', '$2' },
    -- Custom selector function used for browsing methods.
    -- The function will receive two arguments: err (nil or message), results (table).
    -- Use nil for the default implementation (quickfix window)
    selector = nil,
    horizontal = true, -- Open the help window as a horizontal split
    direction = 'top', -- direction of the split: 'top', 'right', 'bot', 'left'
  },
  postwin = {
    syntax = true, -- Use syntax colored post window output.
    auto_toggle_error = true, -- Auto-toggle post window on errors.
    scrollback = 5000, -- The number of lines to save in the post window history.
    horizontal = false, -- Open the post window as a horizontal split
    direction = 'right', -- direction of the split: 'top', 'right', 'bot', 'left'
    size = nil, -- Use a custom initial size
    fixed_size = nil, -- Use a fixed size for the post window. The window will always use this size if closed.
    float = {
      enabled = false, -- Use a floating post window
      offset_x = 0, -- Horizontal offset. Increasing this value will "push" the window to the left of the editor.
      offset_y = 0, -- Vertical offset. Increasing this value will "push" the window to the bottom of the editor.
      -- See :h nvim_open_win for possible values
      config = {
        border = 'single',
      },
      -- Callback that runs whenever the floating window was opened.
      -- Can be used to set window local options.
      callback = function(id)
        vim.api.nvim_win_set_option(id, 'winblend', 10)
      end,
    },
  },
  editor = {
    highlight = {
      -- Use an existing highlight group for the flash color.
      color = 'TermCursor',
      -- Use a table for custom colors.
      -- color = {
      --   guifg = 'black',
      --   guibg = 'white',
      --   ctermfg = 'black',
      --   ctermbg = 'white',
      -- },
      type = 'flash', -- highlight type: 'flash', 'fade' or 'none'
      flash = {
        duration = 100, -- The duration of the flash in ms.
        repeats = 2, -- The number of repeats.
      },
      fade = {
        duration = 375, -- The duration of the fade in ms
      },
    },
  },
  completion = {
    signature = {
      float = true, -- Show function signatures in a floating window
      auto = true, -- Show function signatures while typing in insert mode
      config = {}, -- Float configuration (see if we can use vim.diagnostic instead..)
    },
  },
  snippet = {
    engine = {
      name = 'luasnip', -- name of the snippet engine
      -- engine specific options
      options = {
        descriptions = true, -- luasnip descriptions
      },
    },
    mul_add = false, -- Include mul/add arguments for UGens
    style = 'default', -- 'compact' = do not put spaces between args, etc.
  },
}

local M = {}

setmetatable(M, {
  __index = function(self, key)
    local config = rawget(self, 'config')
    if config then
      return config[key]
    end
    return default[key]
  end,
})

function M.resolve(config)
  config = config or {}
  M.config = vim.tbl_deep_extend('keep', config, default)
end

return M
