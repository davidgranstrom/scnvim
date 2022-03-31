--- Paths used by scnvim
-- @module scnvim.paths
-- @author David Granström
-- @license GPLv3

local M = {}
local utils = require'scnvim.utils'
local is_win = utils.is_windows

-- Store the cache path
M.cache = vim.fn.stdpath('cache')

local function escape(path)
  if is_win and not vim.opt.shellslash:get() then
    return vim.fn.escape(path, '\\')
  else
    return path
  end
end

local function normalize(path)
  return escape(vim.fn.expand(path))
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

local function find_scdoc_render_program(cmd)
  local path = vim.fn.exepath(cmd) -- default render program
  if path ~= '' then
    return normalize(path)
  end
  error('Could not find documentation.cmd. Please specify documentation.cmd in the setup function')
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

--- Try and resolve paths missing from the config
--@param config The configuration to resolve
function M.resolve_config(config)
  if not config.sclang.path then
    config.sclang.path = resolve(find_sclang_executable, nil)
  end

  if config.documentation then
    local cmd = config.documentation.cmd
    if cmd then
      config.documentation.cmd = resolve(find_scdoc_render_program, cmd)
    end
  end
end

return M
