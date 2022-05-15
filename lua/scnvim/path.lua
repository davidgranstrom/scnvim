--- Path
--- Path and host related functions
---@module scnvim.path

local M = {}
local uv = vim.loop

local function escape(path)
  if is_win and not vim.opt.shellslash:get() then
    return vim.fn.escape(path, '\\')
  else
    return path
  end
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
---@return An absolute path to the cache directory
function M.get_cache_dir()
  local cache_path = vim.fn.stdpath 'cache'
  cache_path = cache_path .. M.sep .. 'scnvim'
  if not uv.fs_stat(cache_path) then
    uv.fs_mkdir(cache_path, tonumber('777', 8))
  end
  return cache_path
end

--- Normalize a path.
---@param path The path to normalize.
---@return A normalized path.
function M.normalize(path)
  return escape(vim.fn.expand(path))
end

return M
