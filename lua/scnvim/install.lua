--- Installer for SCNvim SuperCollider classes.
--- Cross platform installation that respects XDG Base Directory Specification.
---@module scnvim.install

local _path = require 'scnvim.path'

local uv = vim.loop
local M = {}

local function is_symlink(path)
  local stat = uv.fs_lstat(path)
  if stat then
    return stat.type == 'link'
  end
  return false
end

local function get_ext_dir()
  local sysname = _path.get_system()
  local xdg = uv.os_getenv 'XDG_DATA_HOME'
  local home_dir = uv.os_homedir()
  if sysname == 'windows' then
    return _path.escape(_path.concat(home_dir, 'AppData', 'Local', 'SuperCollider', 'Extensions'))
  end
  if xdg then
    return _path.concat(xdg, 'SuperCollider', 'Extensions')
  end
  if sysname == 'linux' then
    return _path.concat(home_dir, '.local', 'share', 'SuperCollider', 'Extensions')
  elseif sysname == 'macos' then
    return _path.concat(home_dir, 'Library', 'Application Support', 'SuperCollider', 'Extensions')
  end
  error '[scnvim] could not get SuperCollider Extensions dir'
end

local function get_target_dir()
  local ext_dir = get_ext_dir()
  vim.fn.mkdir(ext_dir, 'p')
  return _path.concat(ext_dir, 'scide_scnvim')
end

--- Create a symbolic link to the SCNvim classes
function M.link()
  local link_target = get_target_dir()
  local target_exists = uv.fs_stat(link_target)
  if not target_exists then
    local root_dir = _path.get_plugin_root_dir()
    local source = _path.concat(root_dir, 'scide_scnvim')
    uv.fs_symlink(source, link_target, { dir = true, junction = true })
  end
end

--- Remove the symbolic link to the SCNvim classes
function M.unlink()
  local link_target = get_target_dir()
  if is_symlink(link_target) then
    uv.fs_unlink(link_target)
  end
end

--- Check if classes are linked
---@return Absolute path to Extensions/scide_scnvim
function M.check()
  local link_target = get_target_dir()
  return is_symlink(link_target) and link_target or nil
end

return M
