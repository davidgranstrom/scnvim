--- Utility functions
---@module scnvim.utils

local M = {}
local _path = require 'scnvim.path'

function M.get_var(name)
  local result, value = pcall(vim.api.nvim_get_var, name)
  if result then
    return value
  end
  return nil
end

--- Get the content of the generated snippets file.
---@return The file contents. A lua table or a string depending on `scnvim_snippet_format`.
function M.get_snippets()
  local root_dir = M.get_scnvim_root_dir()
  local format = M.get_var 'scnvim_snippet_format' or 'snippets.nvim'
  local snippet_dir = root_dir .. _path.sep .. 'scnvim-data'
  if format == 'snippets.nvim' or format == 'luasnip' then
    local filename = snippet_dir .. _path.sep .. 'scnvim_snippets.lua'
    local ok, file = pcall(loadfile(filename))
    if ok then
      return file
    else
      print('File does not exist:' .. filename)
      print 'Call :SCNvimTags to generate snippets.'
    end
  elseif format == 'ultisnips' then
    local filename = snippet_dir .. _path.sep .. 'supercollider.snippets'
    local file = assert(io.open(filename, 'rb'), 'File does not exists: ' .. filename)
    local content = file:read '*all'
    file:close()
    return content
  end
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

--- Get the root directory of the plugin.
---@return The root directory of the plugin
function M.get_scnvim_root_dir()
  if M.plugin_root_dir then
    return M.plugin_root_dir
  end
  local package_path = debug.getinfo(1).source:gsub('@', '')
  --vim uses inconsistent path separators on Windows
  --safer to change all to Unix style first
  if M.is_windows then
    package_path = package_path:gsub('@', ''):gsub('\\', '/')
  end
  package_path = vim.split(package_path, '/', { plain = false, trimempty = true })
  -- find index of plugin root dir
  local index = 1
  local found = false
  for i, v in ipairs(package_path) do
    if v == 'scnvim' then
      found = true
      index = i
      break
    end
  end
  if not found then
    error '[scnvim] could not find plugin root dir'
  end
  local path = {}
  for i, v in ipairs(package_path) do
    if i > index then
      break
    end
    path[i] = v
  end
  local dir = ''
  if not M.is_windows then
    dir = '/'
  end
  for _, v in ipairs(path) do
    dir = dir .. v .. _path.sep
  end
  assert(#dir > 1, '[scnvim] Could not get scnvim root path')
  dir = dir:sub(1, -2) -- delete trailing slash
  M.plugin_root_dir = dir
  return dir
end

--- Get table length
function M.tbl_len(T)
  local count = 0
  for _ in pairs(T) do
    count = count + 1
  end
  return count
end

return M
