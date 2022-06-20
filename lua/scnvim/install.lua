---@module scnvim.install
---@local

local path = require 'scnvim.path'
local M = {}

local function get_link_target()
  local destination = path.get_user_extension_dir()
  vim.fn.mkdir(destination, 'p')
  return destination .. '/scide_scnvim'
end

--- Install the scnvim classes
---@local
function M.install()
  local source = path.concat(path.get_plugin_root_dir(), 'scide_scnvim')
  local destination = get_link_target()
  path.link(source, destination)
end

--- Uninstall the scnvim classes
---@local
function M.uninstall()
  local destination = get_link_target()
  path.unlink(destination)
end

--- Check if classes are linked
---@return Absolute path to Extensions/scide_scnvim
---@local
function M.check()
  local link_target = get_link_target()
  return path.is_symlink(link_target) and link_target or nil
end

return M
