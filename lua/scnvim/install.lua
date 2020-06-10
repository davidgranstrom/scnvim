--- SCNvim installation module
--- Cross platform installation of SCNvim SuperCollider classes.

local M = {}
local utils = require('scnvim/utils')
local uv = vim.loop

-- Get the root directory of the plugin
local function get_scnvim_root_dir()
  local package_path = package.searchpath('scnvim', package.path)
  package_path = vim.split(package_path, utils.path_sep, true)
  local path_len = utils.tbl_len(package_path)
  table.remove(package_path, path_len)
  table.remove(package_path, path_len - 1)
  local dir = ''
  for _, element in ipairs(package_path) do
    -- first element is empty on unix
    if element == '' then
      dir = utils.path_sep
    else
      dir = dir .. element .. utils.path_sep
    end
  end
  assert(dir ~= '', '[scnvim] Could not get scnvim root path')
  dir = dir:sub(1, -2) -- delete trailing slash
  return dir
end

local scnvim_root_dir = get_scnvim_root_dir()
local home_dir = uv.os_homedir()

-- indexed with keys returned by uname
local extension_dirs = {
  Darwin = home_dir .. '/Library/Application Support/SuperCollider/Extensions',
  Linux = home_dir .. '/.local/share/SuperCollider/Extensions',
  Windows = home_dir .. '\\AppData\\Local\\SuperCollider\\Extensions',
}

-- Utils

local function is_symlink(path)
  local stat = uv.fs_lstat(path)
  if stat then
    return stat.type == 'link'
  end
  return false
end

local function get_ext_dir()
  local sysname = uv.os_uname().sysname
  -- Windows is Windows_NT or WindowsNT
  sysname = sysname:gsub('_NT',''):gsub('NT','')
  local dir = extension_dirs[sysname]
  if not dir then
    return nil, 'Could not get SuperCollider Extensions dir'
  end
  return dir
end

local function get_target_dir()
  local ext_dir = assert(get_ext_dir())
  return ext_dir .. utils.path_sep .. 'scide_scnvim'
end

-- Interface

--- Create a symlink to the SCNvim classes
function M.link()
  local link_target = get_target_dir()
  local target_exists = uv.fs_stat(link_target)
  -- create the link
  if not target_exists then
    local source = scnvim_root_dir .. utils.path_sep .. 'scide_scnvim'
    assert(uv.fs_symlink(source, link_target, {dir = true, junction = true}))
    print('[scnvim] Installed to: ' .. link_target)
  end
end

--- Remove symlink to the SCNvim classes
function M.unlink()
  local link_target = get_target_dir()
  -- remove the link
  if is_symlink(link_target) then
    assert(uv.fs_unlink(link_target))
    print('[scnvim] Uninstalled ' .. link_target)
  end
end

--- Check if classes are linked
function M.check()
  local link_target = get_target_dir()
  return is_symlink(link_target) and link_target or nil
end

return M
