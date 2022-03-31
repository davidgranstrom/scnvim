local scnvim = require'scnvim'

function add_command(name, fn, desc)
  vim.api.nvim_buf_add_user_command(0, name, fn, {desc = desc})
end

add_command('SCNvimStart', scnvim.start, 'Start the sclang interpreter')
add_command('SCNvimStop', scnvim.stop, 'Stop the sclang interpreter')
add_command('SCNvimRecompile', scnvim.recompile, 'Recompile the sclang interpreter')
add_command('SCNvimTags', 'call scnvim#util#generate_tags()', 'Generate syntax highlightning and snippets')
add_command('SCNvimStatusLine', 'call scnvim#statusline#sclang_poll()', 'Display the server status')

local options = {nargs = 1, desc = 'Open help for subject'}
local open_help = function(tbl)
  vim.call('scnvim#help#open_help_for', tbl.args)
end
vim.api.nvim_buf_add_user_command(0, 'SCNvimHelp', open_help, options)
