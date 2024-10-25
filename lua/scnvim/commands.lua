--- Commands
---
--- Returns a single function that creates user commands.
---@module scnvim.commands
---@local

local sclang = require 'scnvim.sclang'
local help = require 'scnvim.help'
local extensions = require 'scnvim.extensions'
local get_cache_dir = require('scnvim.path').get_cache_dir

local function add_command(name, fn, desc)
  vim.api.nvim_buf_create_user_command(0, name, fn, { desc = desc })
end

return function()
  add_command('SCNvimStart', sclang.start, 'Start the sclang interpreter')
  add_command('SCNvimStop', sclang.stop, 'Stop the sclang interpreter')
  add_command('SCNvimRecompile', sclang.recompile, 'Recompile the sclang interpreter')
  add_command('SCNvimReboot', sclang.reboot, 'Reboot sclang interpreter')
  add_command('SCNvimStatusLine', sclang.poll_server_status, 'Display the server status')
  add_command('SCNvimGenerateAssets', function()
    local on_done = function()
      print('[scnvim] Assets written to ' .. get_cache_dir())
    end
    sclang.generate_assets(on_done)
  end, 'Generate syntax highlightning and snippets')

  local options = { nargs = 1, desc = 'Open help for subject' }
  local open_help = function(tbl)
    help.open_help_for(tbl.args)
  end
  vim.api.nvim_buf_create_user_command(0, 'SCNvimHelp', open_help, options)

  vim.api.nvim_buf_create_user_command(0, 'SCNvimExt', extensions.run_user_command, {
    nargs = '+',
    complete = [[customlist,v:lua.require'scnvim.extensions'.cmd_complete]],
    desc = 'Run an extension command',
  })

  -- deprecated
  add_command('SCNvimTags', function()
    print '[scnvim] SCNvimTags is deprecated. Please use SCNvimGenerateAssets.'
  end)
end
