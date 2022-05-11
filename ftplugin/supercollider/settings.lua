if vim.g.did_ft_scnvim_settings then
  return
end
vim.g.did_ft_scnvim_settings = true

local api = vim.api

--- TODO: tags
-- let s:tagsFile = expand(get(g:, 'scnvim_root_dir') . '/scnvim-data/tags')
-- if filereadable(s:tagsFile)
--   execute 'setlocal tags+=' . s:tagsFile
-- endif

--- matchit
--- TODO: are these really needed?
api.nvim_buf_set_var(0, 'match_skip', 's:scComment|scString|scSymbol')
api.nvim_buf_set_var(0, 'match_words', '(:),[:],{:}')

--- help system
vim.opt_local.keywordprg = ':SCNvimHelp'

--- comments
vim.opt_local.commentstring = '//%s'
