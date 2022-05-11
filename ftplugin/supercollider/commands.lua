if vim.g.did_ft_scnvim_commands then
  return
end
vim.g.did_ft_scnvim_commands = true

local scnvim = require'scnvim'
local sclang = require'scnvim.sclang'

function add_command(name, fn, desc)
  vim.api.nvim_buf_create_user_command(0, name, fn, {desc = desc})
end

add_command('SCNvimStart', scnvim.start, 'Start the sclang interpreter')
add_command('SCNvimStop', scnvim.stop, 'Stop the sclang interpreter')
add_command('SCNvimRecompile', scnvim.recompile, 'Recompile the sclang interpreter')
add_command('SCNvimStatusLine', sclang.poll_server_status, 'Display the server status')
add_command('SCNvimTags', 'call scnvim#util#generate_tags()', 'Generate syntax highlightning and snippets')

local options = {nargs = 1, desc = 'Open help for subject'}
local open_help = function(tbl)
  vim.call('scnvim#help#open_help_for', tbl.args)
end
vim.api.nvim_buf_create_user_command(0, 'SCNvimHelp', open_help, options)
