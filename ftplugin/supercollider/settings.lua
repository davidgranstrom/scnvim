if vim.g.did_ft_scnvim_settings then
  return
end
vim.g.did_ft_scnvim_settings = true

local path = require'scnvim.path'
local api = vim.api
local uv = vim.loop

-- tags
local tags_file = path.get_cache_dir() .. '/tags'
if uv.fs_stat(tags_file) then
  vim.opt_local.tags:append(tags_file)
end

--- help system
vim.opt_local.keywordprg = ':SCNvimHelp'

--- comments
vim.opt_local.commentstring = '//%s'

--- matchit
--- TODO: are these really needed?
api.nvim_buf_set_var(0, 'match_skip', 's:scComment|scString|scSymbol')
api.nvim_buf_set_var(0, 'match_words', '(:),[:],{:}')
