--- Settings
---
--- Returns a single function that applies default settings.
---@module scnvim.settings

local config = require 'scnvim.config'
local get_cache_dir = require('scnvim.path').get_cache_dir
local uv = vim.loop

return function()
  -- tags
  local tags_file = get_cache_dir() .. '/tags'
  if uv.fs_stat(tags_file) then
    vim.opt_local.tags:append(tags_file)
  end

  -- help system
  vim.opt_local.keywordprg = ':SCNvimHelp'

  -- comments
  vim.opt_local.commentstring = '//%s'

  if not config.completion.signature.float then
    -- disable showmode to be able to see the printed signature
    vim.opt_local.showmode = false
    vim.opt_local.shortmess:append 'c'
  end

  -- matchit
  -- TODO: are these really needed?
  vim.api.nvim_buf_set_var(0, 'match_skip', 's:scComment|scString|scSymbol')
  vim.api.nvim_buf_set_var(0, 'match_words', '(:),[:],{:}')
end
