if vim.b.did_ft_scnvim_commands then
  return
end
vim.b.did_ft_scnvim_commands = true

local sclang = require 'scnvim.sclang'
local editor = require 'scnvim.editor'
local path = require 'scnvim.path'
local help = require 'scnvim.help'

local function add_command(name, fn, desc)
  vim.api.nvim_buf_create_user_command(0, name, fn, { desc = desc })
end

add_command('SCNvimStart', sclang.start, 'Start the sclang interpreter')
add_command('SCNvimStop', sclang.stop, 'Stop the sclang interpreter')
add_command('SCNvimRecompile', sclang.recompile, 'Recompile the sclang interpreter')
add_command('SCNvimStatusLine', sclang.poll_server_status, 'Display the server status')
add_command('SCNvimGenerateAssets', function()
  local on_done = function()
    print('[scnvim] assets were written to ' .. path.get_cache_dir())
  end
  editor.generate_assets(on_done)
end, 'Generate syntax highlightning and snippets')

local options = { nargs = 1, desc = 'Open help for subject' }
local open_help = function(tbl)
  help.prepare_help_for(tbl.args)
end
vim.api.nvim_buf_create_user_command(0, 'SCNvimHelp', open_help, options)

--- Deprecated

add_command('SCNvimTags', function()
  print '[scnvim] SCNvimTags is deprecated. Please use SCNvimGenerateAssets.'
end)
