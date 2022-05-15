--- Utility functions
---@module scnvim.utils

local M = {}

--- Get the content of the generated snippets file.
---@return The file contents. A lua table or a string depending on `scnvim_snippet_format`.
-- function M.get_snippets()
--   local root_dir = M.get_scnvim_root_dir()
--   local format = M.get_var 'scnvim_snippet_format' or 'snippets.nvim'
--   local snippet_dir = root_dir .. _path.sep .. 'scnvim-data'
--   if format == 'snippets.nvim' or format == 'luasnip' then
--     local filename = snippet_dir .. _path.sep .. 'scnvim_snippets.lua'
--     local ok, file = pcall(loadfile(filename))
--     if ok then
--       return file
--     else
--       print('File does not exist:' .. filename)
--       print 'Call :SCNvimTags to generate snippets.'
--     end
--   elseif format == 'ultisnips' then
--     local filename = snippet_dir .. _path.sep .. 'supercollider.snippets'
--     local file = assert(io.open(filename, 'rb'), 'File does not exists: ' .. filename)
--     local content = file:read '*all'
--     file:close()
--     return content
--   end
-- end

--- Match an exact occurence of word
-- (replacement for \b word boundary)
function M.str_match_exact(input, word)
  return string.find(input, '%f[%a]' .. word .. '%f[%A]') ~= nil
end

--- Print a highlighted message to the command line.
---@param message The message to print.
---@param hlgroup The highlight group to use. Default = ErrorMsg
function M.print(message, hlgroup)
  local expr = string.format([[echohl %s | echom '[scnvim] ' . %s | echohl None]], hlgroup or 'ErrorMsg', message)
  vim.cmd(expr)
end

return M
