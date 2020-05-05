--- SCNvim installation module
--- Cross platform installation of SCNvim SuperCollider classes.

local M = {}
local utils = require('utils')
local uv = vim.loop

local scnvim_root_dir = vim.api.nvim_get_var('scnvim_root_dir')
local home_dir = uv.os_homedir()
-- indexed with keys returned by uname
local extension_dirs = {
  Darwin = home_dir .. '/Library/Application Support/SuperCollider/Extensions',
  Linux = home_dir .. '/.local/share/SuperCollider/Extensions',
  Windows = '%LOCALAPPDATA%\\SuperCollider\\Extensions',
}

-- Utils

local function get_ext_dir()
  local sysname = uv.os_uname().sysname
  local dir = extension_dirs[sysname]
  if not dir then
    return nil, 'Could not get SuperCollider Extensions dir'
  end
  return dir
end

-- return Extensions dir with path separator post-fix
local function get_scide_dir()
  local ext_dir = assert(get_ext_dir())
  return ext_dir .. utils.path_sep .. 'scide_scvim'
end

local function is_symlink(path)
  local stat = uv.fs_lstat(path)
  if stat then
    return stat.type == 'link'
  end
  return false
end

local function is_dir(path)
  local stat = uv.fs_stat(path)
  if stat then
    return stat.type == 'directory'
  end
  return false
end

-- Stages

--- Remove 'scide_scvim' symlink if it exists, otherwise do nothing.
local function unlink_old_install()
  local lpath = get_scide_dir()
  if is_symlink(lpath) then
    return assert(uv.fs_unlink(lpath), 'Could not unlink ' .. lpath)
  end
  return true
end

--- Create a symlink to the SCNvim classes
local function link_classes()
  local scide_dir = get_scide_dir()
  local link_target = scide_dir .. utils.path_sep .. 'scnvim'
  if not is_dir(scide_dir) then
    -- libuv does not have mkdir -p
    utils.vimcall('mkdir', {scide_dir, 'p'})
  end
  -- create the link
  if not is_symlink(link_target) then
    local source = scnvim_root_dir .. utils.path_sep .. 'sc'
    assert(uv.fs_symlink(source, link_target, {'dir', true}))
  end
  return true
end

-- Interface

function M.install_classes()
  assert(unlink_old_install())
  assert(link_classes())
end

return M
