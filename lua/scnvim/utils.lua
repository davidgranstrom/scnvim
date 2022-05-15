--- Utility functions
---@module scnvim.utils

local M = {}

--- Returns the content of a lua file on disk
---@param path The path to the file to load
function M.load_file(path)
  -- this check is here because loadfile will read from stdin if nil
  if not path then
    error('[scnvim] no path to read')
  end
  local content, err = loadfile(path)
  if not content then
    error(err)
  end
  return content
end

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
