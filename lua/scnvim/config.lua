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
    },
    mapping = {}, -- TODO(david)
    documentation = { -- set to 'false' to use HelpBrowser
      cmd = 'pandoc', -- g:scnvim_scdoc_render_prg
      args = '% --from html --to plain -o %' -- g:scnvim_scdoc_render_args
    },
    postwin = {
      syntax = true,       -- g:scnvim_postwin_syntax_hl
      orientation = 'v',   -- g:scnvim_postwin_orientation
      direction = 'right', -- g:scnvim_postwin_direction
      fixed_size = 25,     -- g:scnvim_postwin_size
      auto_show_errors = true, -- g:scnvim_postwin_auto_toggle
      scrollback = 5000, -- g:scnvim_postwin_scrollback
    },
    eval = {
      flash_duration = 100, -- g:scnvim_eval_flash_duration
      flash_repeats = 2,    -- g:scnvim_eval_flash_repeats
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
