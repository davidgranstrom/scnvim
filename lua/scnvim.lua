--- Main interface
---@module scnvim
---@author David Granström
---@license GPLv3

local sclang = require 'scnvim.sclang'
local editor = require 'scnvim.editor'
local config = require 'scnvim.config'

local scnvim = {}

--- Map helper.
---
--- Returns a function with the signature `(modes, callback, flash)`
---
--- The actions that can be mapped are documented in `scnvim.editor`
---
--- * modes - table of vim modes ('i', 'n', 'x' etc.). A string can be used for a single mode.
--- * callback - An optional callback that receives a table of lines as its only
--- argument. The function must always return a table.
--- * flash - Apply the editor flash for this action (default is true)
---
---@see scnvim.editor
---@usage scnvim.map.send_line('n'),
---@usage scnvim.map.send_line({'i', 'n'}, function(data)
---    local line = data[1]
---    line = line:gsub('goodbye', 'hello')
---    return {line}
---  end)
scnvim.map = require 'scnvim.map'

--- Setup function.
---
--- This function is called from the user's config to initialize scnvim.
---@param user_config A user config or an empty table.
function scnvim.setup(user_config)
  if config.ensure_installed then
    local installer = require 'scnvim.install'
    local ok, msg = pcall(installer.link)
    if not ok then
      error(msg)
    end
  end
  user_config = user_config or {}
  config.resolve(user_config)
  editor.setup()
end

--- Evalute an expression.
---@param expr Any valid SuperCollider expression.
function scnvim.send(expr)
  sclang.send(expr, false)
end

--- Evalute an expression without feedback from the post window.
---@param expr Any valid SuperCollider expression.
function scnvim.send_silent(expr)
  sclang.send(expr, true)
end

--- Evalute an expression and get the return value in lua.
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

return scnvim
