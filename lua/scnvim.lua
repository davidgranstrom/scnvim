--- Main module
---@module scnvim
---@author David Granström
---@license GPLv3

local sclang = require 'scnvim.sclang'
local editor = require 'scnvim.editor'
local config = require 'scnvim.config'
local extensions = require 'scnvim.extensions'

local scnvim = {}

--- Map helper.
---
--- Can be used in two ways:
---
--- 1) As a table to map functions from scnvim.editor
---
--- 2) As a function to set up an arbitrary mapping.
---
--- When indexed, it returns a function with the signature `(modes, callback, flash)`
---
--- * modes: Table of vim modes ('i', 'n', 'x' etc.). A string can be used for
--- a single mode. Default mode is 'n' (normal mode).
---
--- * callback: A callback that receives a table of lines as its only
--- argument. The callback should always return a table. (Only used
--- by functions that manipulates text).
---
--- * flash: Apply the editor flash effect for the selected text (default is
---   true) (Only used by functions that manipulates text).
---
---@see scnvim.editor
---@usage scnvim.map.send_line('n'),
---@usage scnvim.map.send_line({'i', 'n'}, function(data)
---   local line = data[1]
---   line = line:gsub('goodbye', 'hello')
---   return {line}
--- end)
---@usage scnvim.map(function()
---  vim.cmd [[ SCNvimGenerateAssets ]]
--- end, { 'n' })
---@usage scnvim.map(scnvim.recompile)
local map = require 'scnvim.map'
scnvim.map = map.map
scnvim.map_expr = map.map_expr

--- Setup function.
---
--- This function is called from the user's config to initialize scnvim.
---@param user_config A user config or an empty table.
function scnvim.setup(user_config)
  user_config = user_config or {}
  config.resolve(user_config)
  editor.setup()
  if config.ensure_installed then
    local installer = require 'scnvim.install'
    local ok, msg = pcall(installer.install)
    if not ok then
      error(msg)
    end
  end
end

--- Evaluate an expression.
---@param expr Any valid SuperCollider expression.
function scnvim.send(expr)
  sclang.send(expr, false)
end

--- Evaluate an expression without feedback from the post window.
---@param expr Any valid SuperCollider expression.
function scnvim.send_silent(expr)
  sclang.send(expr, true)
end

--- Evaluate an expression and get the return value in lua.
---@param expr Any valid SuperCollider expression.
---@param cb A callback that will receive the return value as its first argument.
---@usage scnvim.eval('1 + 1', function(res)
---  print(res)
--- end)
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

--- Register an extension.
---@param ext The extension to register.
---@return The extension.
function scnvim.register_extension(ext)
  return extensions.register(ext)
end

--- Load an extension.
--- Should only be called after `scnvim.setup`.
---@param name The extension to load.
---@return The exported functions from the extension.
---@usage scnvim.load_extension('logger')
function scnvim.load_extension(name)
  return extensions.load(name)
end

return scnvim
