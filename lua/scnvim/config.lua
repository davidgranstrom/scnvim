--- Default configuration.
--- Provides fallback values not specified in the user config.
--- Please see source file for the default values.
---@module scnvim.config

--- default configuration
local default = {
  ensure_installed = true, -- If installed once, this can be set to false to improve startup time.
  ft_supercollider = true, -- Treat .sc files as supercollider (if false, use native ft detect scala/supercollider)
  sclang = {
    cmd = nil, -- Path to the sclang executable. Not needed if `sclang` is already in your $PATH.
    args = {}, -- Comma separated arguments passed to the `sclang` executable.
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
    horizontal = true, -- Open the help window as a horizontal split
    direction = 'top', -- direction of the split: 'top', 'right', 'bot', 'left'
    -- Custom function to use when opening a help file.
    -- If this function is nil a split window will be opened.
    -- @param err Nil on success or reason for the error
    -- @param uri Absolute uri to the help file
    -- @param pattern A regular expression to search for in the help file (nil if not opening a method)
    on_open = nil,
    -- Custom function to use when selecting a method.
    -- If this function is nil the quickfix window will be used.
    -- @param err Nil on success or reason for the error
    -- @param results Table with method entries
    on_select = nil,
  },
  postwin = {
    highlight = true, -- Use syntax colored post window output.
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
  statusline = {
    poll_interval = 1, -- The interval to update the status line widgets in seconds
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
