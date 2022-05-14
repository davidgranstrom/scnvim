--- Path
--- Path related functions
---@module scnvim.path

local M = {}
local is_win = require('scnvim.utils').is_windows
local uv = vim.loop

local function escape(path)
  if is_win and not vim.opt.shellslash:get() then
    return vim.fn.escape(path, '\\')
  else
    return path
  end
end

--- TODO: remove this from utils and refactor
M.sep = is_win and '\\' or '/'

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
