--- Default configuration.
--- Provides fallback values not specified in the user config.
---@module scnvim.config

--- table
---@table default
---@field ensure_installed (default: true) If installed once, this can be set to false to improve startup time.
local default = {
  ensure_installed = true,

  --- table
  ---@table default.sclang
  ---@field cmd Path to the sclang executable. Not needed if sclang is already in your $PATH.
  ---@field args Comma separated arguments passed to the sclang executable.
  sclang = {
    cmd = nil,
    args = {},
  },

  --- table (empty by default)
  ---@table default.mapping
  ---@field keymap scnvim.map
  ---@usage mapping = {
  ---    ['<M-e>'] = scnvim.map.send_line({'i', 'n'}),
  ---    ['<C-e>'] = {
  ---      scnvim.map.send_block({'i', 'n'}),
  ---      scnvim.map.send_selection('x'),
  ---    },
  ---    ['<leader>st'] = scnvim.map(scnvim.start),
  ---    ['<leader>sk'] = scnvim.map(scnvim.recompile),
  ---  }
  mapping = {},

  --- table
  ---@table default.documentation
  ---@field cmd Absolute path to the render program (e.g. /opt/homebrew/bin/pandoc)
  ---@field args (default: `{ '$1', '--from', 'html', '--to', 'plain', '-o', '$2' }`)
  ---
  --- Arguments given to the render program. The default args are for
  ---`pandoc`. Any program that can convert html into plain text should work. The
  --- string $1 will be replaced with the input file path and $2 will be replaced
  --- with the output file path.
  ---
  ---@field horizontal (default: true) Open the help window as a horizontal split
  ---@field direction (default: 'top') Direction of the split: 'top', 'right', 'bot', 'left'
  ---@field mapping (default: true) If true apply user keymaps to the help
  --- window. Use a table value for explicit mappings.
  documentation = {
    cmd = nil,
    args = { '$1', '--from', 'html', '--to', 'plain', '-o', '$2' },
    horizontal = true,
    direction = 'top',
    mapping = true,
  },

  --- table
  ---@table default.postwin
  ---@field highlight (default: true) Use syntax colored post window output.
  ---@field auto_toggle_error (default: true) Auto-toggle post window on errors.
  ---@field scrollback (default: 5000) The number of lines to save in the post window history.
  ---@field horizontal (default: false) Open the post window as a horizontal split
  ---@field direction (default: 'right') Direction of the split: 'top', 'right', 'bot', 'left'
  ---@field size Use a custom initial size
  ---@field fixed_size Use a fixed size for the post window. The window will always use this size if closed.
  ---@field mapping (default: true) If true apply user keymaps to the help
  --- window. Use a table value for explicit mappings.
  postwin = {
    highlight = true,
    auto_toggle_error = true,
    scrollback = 5000,
    horizontal = false,
    direction = 'right',
    size = nil,
    fixed_size = nil,
    mapping = nil,

    --- table
    ---@table default.postwin.float
    ---@field enabled (default: false) Use a floating post window.
    ---@field row (default: 0) The row position, can be a function.
    ---@field col (default: vim.o.columns) The column position, can be a function.
    ---@field width (default: 64) The width, can be a function.
    ---@field height (default: 14) The height, can be a function.
    ---@field callback (default: `function(id) vim.api.nvim_win_set_option(id, 'winblend', 10) end`)
    --- Callback that runs whenever the floating window was opened.
    --- Can be used to set window local options.
    float = {
      enabled = false,
      row = 0,
      col = function()
        return vim.o.columns
      end,
      width = 64,
      height = 14,
      --- table
      ---@table default.postwin.float.config
      ---@field border (default: 'single')
      ---@field ... See `:help nvim_open_win` for possible values
      config = {
        border = 'single',
      },
      callback = function(id)
        vim.api.nvim_win_set_option(id, 'winblend', 10)
      end,
    },
  },

  --- table
  ---@table default.editor
  ---@field force_ft_supercollider (default: true) Treat .sc files as supercollider.
  --- If false, use nvim's native ftdetect.
  editor = {
    force_ft_supercollider = true,

    --- table
    ---@table editor.highlight
    ---@field color (default: `TermCursor`) Highlight group for the flash color.
    --- Use a table for custom colors:
    --- `color = { guifg = 'black', guibg = 'white', ctermfg = 'black', ctermbg = 'white' }`
    ---@field type (default: 'flash') Highligt flash type: 'flash', 'fade' or 'none'

    --- table
    ---@table editor.highlight.flash
    ---@field duration (default: 100) The duration of the flash in ms.
    ---@field repeats (default: 2) The number of repeats.

    --- table
    ---@table editor.highlight.fade
    ---@field duration (default: 375) The duration of the flash in ms.
    highlight = {
      color = 'TermCursor',
      type = 'flash',
      flash = {
        duration = 100,
        repeats = 2,
      },
      fade = {
        duration = 375,
      },
    },

    --- table
    ---@table editor.signature
    ---@field float (default: true) Show function signatures in a floating window
    ---@field auto (default: true) Show function signatures while typing in insert mode
    ---@field config
    signature = {
      float = true,
      auto = true,
      config = {}, -- TODO: can we use vim.diagnostic instead..?
    },
  },

  --- table
  ---@table snippet

  --- table
  ---@table snippet.engine
  ---@field name Name of the snippet engine
  ---@field options Table of engine specific options (note, currently not in use)
  snippet = {
    engine = {
      name = 'luasnip',
      options = {
        descriptions = true,
      },
    },
    -- mul_add = false, -- Include mul/add arguments for UGens
    -- style = 'default', -- 'compact' = do not put spaces between args, etc.
  },

  --- table
  ---@table statusline
  ---@field poll_interval (default: 1) The interval to update the status line widgets in seconds.
  statusline = {
    poll_interval = 1,
  },

  --- table
  ---@table extensions
  extensions = {},
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

--- Merge the user configuration with the default values.
---@param config The user configuration
function M.resolve(config)
  config = config or {}
  M.config = vim.tbl_deep_extend('keep', config, default)
end

return M
