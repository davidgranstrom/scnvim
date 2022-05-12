--- Paths used by scnvim
-- @module scnvim.paths
-- @author David Granström
-- @license GPLv3

local M = {}
local utils = require'scnvim.utils'
local is_win = utils.is_windows
local uv = vim.loop

--- Get the scnvim cache directory.
---@return An absolute path to the cache directory
function M.get_cache_dir()
  local cache_path = vim.fn.stdpath('cache')
  cache_path = cache_path .. utils.path_sep .. 'scnvim'
  if not uv.fs_stat(cache_path) then
    uv.fs_mkdir(cache_path, tonumber('777', 8))
  end
  return cache_path
end

function M.escape(path)
  if is_win and not vim.opt.shellslash:get() then
    return vim.fn.escape(path, '\\')
  else
    return path
  end
end

local function normalize(path)
  return M.escape(vim.fn.expand(path))
end

local function find_sclang_executable()
  local path = vim.fn.exepath('sclang')
  if path ~= '' then
    return path
  end
  local system = utils.get_system()
  if system == 'macos' then
    local app = 'SuperCollider.app/Contents/MacOS/sclang'
    local locations = {'/Applications', '/Applications/SuperCollider'}
    for _, loc in ipairs(locations) do
      path = string.format('%s/%s', loc, app)
      if vim.fn.executable(path) then
        return path
      end
    end
  elseif system == 'windows' then -- luacheck: ignore
    -- TODO: a default path for Windows
  elseif system == 'linux' then -- luacheck: ignore
    -- TODO: a default path for Windows
  end
  error('Could not find `sclang`. Please specify sclang.path in the setup function')
end

local function resolve(func, args)
  local ok, res = pcall(func, args)
  if ok then
    return normalize(res)
  else
    utils.print_err(res)
    return nil
  end
end

function M.setup(config)
  if not config.sclang.path then
    config.sclang.path = resolve(find_sclang_executable, nil)
  end
end

return M
