--- Path and platform related functions.
--- '/' is the path separator for all platforms.
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

--- Get the scnvim cache directory.
---@return The absolute path to the cache directory
function M.get_cache_dir()
  local cache_path = M.concat(vim.fn.stdpath 'cache', 'scnvim')
  cache_path = M.normalize(cache_path)
  vim.fn.mkdir(cache_path, 'p')
  return cache_path
end

--- Check if a path exists
---@param path The path to test
---@return True if the path exists otherwise false
function M.exists(path)
  return uv.fs_stat(path) ~= nil
end

--- Check if a file is a symbolic link.
---@param path The path to test.
---@return True if the path is a symbolic link otherwise false
function M.is_symlink(path)
  local stat = uv.fs_lstat(path)
  if stat then
    return stat.type == 'link'
  end
  return false
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

--- Concatenate items using the path separator.
---@param ... items to concatenate into a path
---@usage
--- local cache_dir = path.get_cache_dir()
--- local res = path.concat(cache_dir, 'subdir', 'file.txt')
--- print(res) -- /Users/usr/.cache/nvim/scnvim/subdir/file.txt
function M.concat(...)
  local items = { ... }
  return table.concat(items, '/')
end

--- Normalize a path to use Unix style separators: '/'.
---@param path The path to normalize.
---@return The normalized path.
function M.normalize(path)
  return (path:gsub('\\', '/'))
end

--- Get the root dir of a plugin.
---@param plugin_name Optional plugin name, use nil to get scnvim root dir.
---@return Absolute path to the plugin root dir.
function M.get_plugin_root_dir(plugin_name)
  plugin_name = plugin_name or 'scnvim'
  local paths = vim.api.nvim_list_runtime_paths()
  for _, path in ipairs(paths) do
    local index = path:find(plugin_name)
    if index and path:sub(index, -1) == plugin_name then
      return M.normalize(path)
    end
  end
  error(string.format('Could not get root dir for %s', plugin_name))
end

--- Get the SuperCollider user extension directory.
---@return Platform specific user extension directory.
function M.get_user_extension_dir()
  local sysname = M.get_system()
  local home_dir = uv.os_homedir()
  local xdg = uv.os_getenv 'XDG_DATA_HOME'
  if xdg then
    return xdg .. '/SuperCollider/Extensions'
  end
  if sysname == 'windows' then
    return M.normalize(home_dir) .. '/AppData/Local/SuperCollider/Extensions'
  elseif sysname == 'linux' then
    return home_dir .. '/.local/share/SuperCollider/Extensions'
  elseif sysname == 'macos' then
    return home_dir .. '/Library/Application Support/SuperCollider/Extensions'
  end
  error '[scnvim] could not get SuperCollider Extensions dir'
end

--- Create a symbolic link.
---@param source Absolute path to the source.
---@param destination Absolute path to the destination.
function M.link(source, destination)
  if not uv.fs_stat(destination) then
    uv.fs_symlink(source, destination, { dir = true, junction = true })
  end
end

--- Remove a symbolic link.
---@param link_path Absolute path for the file to unlink.
function M.unlink(link_path)
  if M.is_symlink(link_path) then
    uv.fs_unlink(link_path)
  end
end

return M
