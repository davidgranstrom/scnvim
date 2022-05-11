--- scnvim default configuration.
-- @module scnvim.config
-- @author David Granström
-- @license GPLv3

local M = {}

function M.new()
  return {
    ensure_installed = true, -- if installed this can be set to false to improve startup time.
    sclang = {
      path = nil,   -- g:scnvim_sclang_executable
      options = {}, -- g:scnvim_sclang_options
    },
    mapping = {}, -- Empty by default
    documentation = { -- set to 'false' to use HelpBrowser
      cmd = 'pandoc', -- g:scnvim_scdoc_render_prg
      args = {'--from', 'html', '--to', 'plain'} -- g:scnvim_scdoc_render_args
    },
    postwin = {
      syntax = true,       -- g:scnvim_postwin_syntax_hl
      orientation = 'v',   -- g:scnvim_postwin_orientation
      direction = 'right', -- g:scnvim_postwin_direction
      fixed_size = 25,     -- g:scnvim_postwin_size
      auto_show_errors = true, -- g:scnvim_postwin_auto_toggle
      scrollback = 5000, -- g:scnvim_postwin_scrollback
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
      engine = { -- table or string
        name = 'luasnip',
        -- engine specific options
        descriptions = true, -- luasnip descriptions
      },
      mul_add = false, -- includes mul/add arguments for UGens
      style = 'default', -- 'compact' = do not put spaces between args, etc.
    }
  }
end

function M.set(cfg)
  M.config = cfg
end

function M.get()
  return M.config or M.new()
end

return M
