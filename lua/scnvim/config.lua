--- scnvim default configuration.
-- @module scnvim.config
-- @author David Granström
-- @license GPLv3

return function()
  return {
    ensure_installed = true, -- if installed this can be set to false to improve startup time.
    sclang = {
      path = nil,   -- g:scnvim_sclang_executable
      options = {}, -- g:scnvim_sclang_options
      server_status_interval = 1, -- g:scnvim_statusline_interval
    },
    mapping = {}, -- Empty by default
    documentation = { -- set to 'false' to use HelpBrowser
      --- absolute path to the render program
      cmd = '/opt/homebrew/bin/pandoc',
      --- options given to the render program
      args = {'$1', '--from', 'html', '--to', 'plain', '-o', '$2'},
      --- Custom selector function used for browsing methods.
      --- The function will receive two arguments: err, results.
      --- Use nil for the default implementation (quickfix window)
      selector = nil,
    },
    postwin = {
      syntax = true,       -- g:scnvim_postwin_syntax_hl
      direction = 'right', -- g:scnvim_postwin_direction
      auto_toggle_error = true, -- g:scnvim_postwin_auto_toggle
      scrollback = 5000, -- g:scnvim_postwin_scrollback
      -- fixed_size = 25,     -- g:scnvim_postwin_size
      -- horizontal = true, -- use a horizontal split instead of vertical
      --- Use a floating window
      -- float = {
      --   width = 40,
      --   height = 30,
      --   x = '90%',
      --   y = '10%'
      -- },
    },
    editor = {
      flash = { -- set to false to disable flash
        duration = 100, -- g:scnvim_eval_flash_duration
        repeats = 2,    -- g:scnvim_eval_flash_repeats
        --- Flash colors
        --- Use an existing highlight group
        hl_group = 'TermCursor'
        --- Or use user specified colors directly
        --- Setting any of these will override the `hl_group` entry.
        -- guifg = 'black',
        -- guifg = 'white'
        -- ctermfg = 'black',
        -- ctermfg = 'white'
      }
    },
    completion = {
      signature = true, -- show method signatures in a floating window
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
      mul_add = false, -- includes mul/add arguments for UGens
      style = 'default', -- 'compact' = do not put spaces between args, etc.
    }
  }
end
