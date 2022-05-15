--- scnvim public interface.
---@module scnvim
---@author David Granström
---@license GPLv3

local sclang = require 'scnvim.sclang'
local installer = require 'scnvim.install'
local map = require 'scnvim.map'
local editor = require 'scnvim.editor'
local help = require 'scnvim.help'
local postwin = require 'scnvim.postwin'
local path = require 'scnvim.path'
local utils = require 'scnvim.utils'
local config = require 'scnvim.config'
local scnvim = {}

scnvim.map = map

function scnvim.setup(user_config)
  if config.ensure_installed then
    local ok, msg = pcall(installer.link)
    if not ok then
      error(msg)
    end
  end
  user_config = user_config or {}
  config.resolve(user_config)
  local modules = {
    editor,
    help,
    map,
    postwin,
  }
  for _, module in ipairs(modules) do
    local ok, err = pcall(module.setup, config)
    if not ok then
      print(string.format('[scnvim] %s error: %s', module.name, err))
    end
  end
end

--- Evalute a SuperCollider expression.
---@param expr Any valid SuperCollider expression.
function scnvim.send(expr)
  sclang.send(expr, false)
end

--- Evalute a SuperCollider expression without feedback from the post window.
---@param expr Any valid SuperCollider expression.
function scnvim.send_silent(expr)
  sclang.send(expr, true)
end

--- Evalute a SuperCollider expression and get the result in a callback.
---@param expr Any valid SuperCollider expression.
---@param cb A callback with a result argument.
function scnvim.eval(expr, cb)
  sclang.eval(expr, cb)
end

--- Start sclang.
function scnvim.start()
  sclang.start()
end

--- Stop sclang.
function scnvim.stop()
  sclang.stop()
end

--- Recompile class library.
function scnvim.recompile()
  sclang.recompile()
end

--- Determine if a sclang process is active.
---@return True if sclang is running otherwise false.
function scnvim.is_running()
  return sclang.is_running()
end

--- Get the content of the auto generated snippet file
---@return Table with the contents of the snippet file
function scnvim.get_snippets()
  local filename = path.get_snippet_file()
  if path.exists(filename) then
    return utils.load_file(filename)
  end
end

return scnvim
