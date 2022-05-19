--- Path and platform related functions
---@module scnvim.path

local M = {}
local uv = vim.loop
local config = require 'scnvim.config'

--- Get the host system
---@return 'windows', 'macos' or 'linux'
function M.get_system()
  local sysname = uv.os_uname().sysname
  if sysname:match 'Windows' then
    return 'windows'
  elseif sysname:match 'Darwin' then
    return 'macos'
  else
    return 'linux'
  end
end

--- Returns true if current system is Windows otherwise false
M.is_windows = (M.get_system() == 'windows')

--- System path separator
--- '/' on macOS and Linux and '\\' on Windows
M.sep = M.is_windows and '\\' or '/'

--- Get the scnvim cache directory.
---@return The absolute path to the cache directory
function M.get_cache_dir()
  local cache_path = M.concat(vim.fn.stdpath 'cache', 'scnvim')
  vim.fn.mkdir(cache_path, 'p')
  return cache_path
end

--- Check if a path exists
---@param path The path to test
---@return True if the path exists otherwise false
function M.exists(path)
  return uv.fs_stat(path) ~= nil
end

--- Get the path to a generated assset.
---
--- * snippets
--- * syntax
--- * tags
---
---@param name The asset to get.
---@return Absolute path to the asset
---@usage path.get_asset 'snippets'
function M.get_asset(name)
  local cache_dir = M.get_cache_dir()
  if name == 'snippets' then
    local filename = 'scnvim_snippets.lua'
    if config.snippet.engine.name == 'ultisnips' then
      filename = 'supercollider.snippets'
    end
    return M.concat(cache_dir, filename)
  elseif name == 'syntax' then
    return M.concat(cache_dir, 'classes.vim')
  elseif name == 'tags' then
    return M.concat(cache_dir, 'tags')
  end
  error '[scnvim] wrong asset type'
end

--- Concatenate items using the system path separator
---@param ... items to concatenate into a path
---@usage
--- local cache_dir = path.get_cache_dir()
--- local res = path.concat(cache_dir, 'subdir', 'file.txt')
--- print(res) -- /Users/usr/.cache/nvim/scnvim/subdir/file.txt
function M.concat(...)
  local items = { ... }
  return table.concat(items, M.sep)
end

--- Get the root dir of this plugin
---@return Absolute path to the plugin root dir
function M.get_plugin_root_dir()
  if M.root_dir then
    return M.root_dir
  end
  local paths = vim.api.nvim_list_runtime_paths()
  for _, path in ipairs(paths) do
    local index = path:find 'scnvim'
    if index and path:sub(index, -1) == 'scnvim' then
      M.root_dir = path
      return path
    end
  end
  error '[scnvim] could not get plugin root dir'
end

return M
