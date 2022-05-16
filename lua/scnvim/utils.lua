--- Utility functions
---@module scnvim.utils

local M = {}
local _path = require 'scnvim.path'

--- Returns the content of a lua file on disk
---@param path The path to the file to load
function M.load_file(path)
  -- this check is here because loadfile will read from stdin if nil
  if not path then
    error '[scnvim] no path to read'
  end
  local func, err = loadfile(path)
  if not func then
    error(err)
  end
  local ok, content = pcall(func)
  if not ok then
    error(content)
  end
  return content
end

--- Match an exact occurence of word
--- (replacement for \b word boundary)
---@param input The input string
---@param word The word to match
---@return True if word matches, otherwise false
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

--- Get the content of the auto generated snippet file.
---@return A table with the snippets.
function M.get_snippets()
  return M.load_file(_path.get_asset 'snippets')
end

return M
