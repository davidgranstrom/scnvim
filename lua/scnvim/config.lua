--- scnvim default configuration.
---@module scnvim.config

local default = {
  --- If installed once, this can be set to false to improve startup time.
  ensure_installed = true,
  sclang = {
    --- Path to the sclang executable. Not needed if `sclang` is already in your $PATH.
    path = nil,
    --- Command line options passed to the `sclang` executable.
    options = {},
    --- The interval of updating the server status line
    server_status_interval = 1,
  },
  --- Mappings, empty by default.
  mapping = {},
  --- Set to `false` in order to use the HelpBrowser
  documentation = {
    --- Absolute path to the render program (e.g. /opt/homebrew/bin/pandoc)
    cmd = nil,
    --- Options given to the render program. The default options are for
    --- `pandoc`. Any program that can convert html into plain text should work.
    ---
    --- The string $1 will be replaced with the input file path and $2 will be
    --- replaced with the output file path.
    args = { '$1', '--from', 'html', '--to', 'plain', '-o', '$2' },
    --- Custom selector function used for browsing methods.
    --- The function will receive two arguments: err (nil or message), results (table).
    --- Use nil for the default implementation (quickfix window)
    selector = nil,
  },
  postwin = {
    --- Use syntax colored post window output.
    syntax = true,
    --- Auto-toggle post window on errors.
    auto_toggle_error = true,
    --- The number of lines to save in the post window history.
    scrollback = 5000,
    --- The direction of the post window, 'left' or 'right'.
    --- If 'horizontal' is true, then use 'top' or 'bottom'.
    direction = 'right',
    --- Use a fixed size for the post window.
    fixed_size = nil,
    --- Use a horizontal split instead of vertical
    horizontal = false,
    --- Use a floating post window.
    -- float = {
    --   --- Where to position the float. Possible values: 'top', 'mid', 'bot'
    --   position = 'top',
    --   --- The width of the window
    --   width = 40,
    --   --- The height of the window
    --   height = 30,
    --   --- Horizontal offset. Increasing this value will "push" the window to the left of the editor.
    --   offset_x = 2,
    --   --- Vertical offset. Increasing this value will "push" the window to the bottom of the editor.
    --   offset_y = 2,
    --   --- See :h nvim_open_win for possible values
    --   border = 'single',
    -- },
  },
  editor = {
    --- Set to `false` to disable flash
    flash = {
      --- The duration of the flash in ms.
      duration = 100,
      --- The number of repeats.
      repeats = 2,
      --- Use an existing highlight group for the flash color.
      hl_group = 'TermCursor',
      --- Or use specified colors directly
      --- Setting any of these will override the `hl_group` entry above.
      -- guifg = 'black',
      -- guifg = 'white'
      -- ctermfg = 'black',
      -- ctermfg = 'white'
    },
  },
  completion = {
    signature = {
      --- Show function signatures in a floating window
      float = true,
      --- Show function signatures while typing in insert mode
      auto = true,
    },
  },
  snippet = {
    engine = {
      --- name of the snippet engine
      name = 'luasnip',
      -- engine specific options
      options = {
        descriptions = true, -- luasnip descriptions
      },
    },
    --- Include mul/add arguments for UGens
    mul_add = false,
    --- Snippet style
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
