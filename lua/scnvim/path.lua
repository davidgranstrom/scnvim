--- Path
--- Path and host related functions
---@module scnvim.path

local M = {}
local uv = vim.loop
local config = require 'scnvim.config'

local function escape(path)
  if M.is_windows and not vim.opt.shellslash:get() then
    return vim.fn.escape(path, '\\')
  else
    return path
  end
end

local function get_snippet_file()
  local filename = 'scnvim_snippets.lua'
  if config.snippet.engine.name == 'ultisnips' then
    filename = 'supercollider.snippets'
  end
  return M.concat(M.get_cache_dir(), filename)
end

--- Get the host system
---@return 'windows', 'macos', 'linux'
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

--- Get the path to a generated assset
---@param name The asset to get.
--- one of: snippets, syntax, tags
function M.get_asset(name)
  local ret
  if name == 'snippets' then
    ret = get_snippet_file()
  elseif name == 'syntax' then
    ret = M.concat(M.get_cache_dir(), 'classes.vim')
  elseif name == 'tags' then
    ret = M.concat(M.get_cache_dir(), 'tags')
  end
  if not M.exists(ret) then
    error('[scnvim] No such file: ' .. tostring(ret))
  end
  return ret
end

--- Normalize a path.
---@param path The path to normalize.
---@return A normalized path.
function M.normalize(path)
  return escape(vim.fn.expand(path))
end

--- Concatenate items using the system path separator
---@vararg strings to concatenate into a path
function M.concat(...)
  local items = { ... }
  return table.concat(items, M.sep)
end

--- Get the root dir of this plugin
---@return Absolute path to the plugin root dir or nil if not not found
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
  return nil
end

return M
