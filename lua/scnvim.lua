--- scnvim public interface.
-- @module scnvim
-- @author David Granström
-- @license GPLv3

local sclang = require'scnvim.sclang'
local default = require'scnvim.config'()
local installer = require'scnvim.install'
local path = require'scnvim.path'
local scnvim = {}

scnvim.config = {}

function scnvim.setup(config)
  if config.ensure_installed then
    local ok, msg = pcall(installer.link)
    if not ok then
      error(msg)
    end
  end
  config = config or {}
  scnvim.config = vim.tbl_deep_extend('keep', config, default)
  path.resolve_config(scnvim.config)
end

--- Evalute a SuperCollider expression.
-- @param expr Any valid SuperCollider expression.
function scnvim.send(expr)
  sclang.send(expr, false)
end

--- Evalute a SuperCollider expression without feedback from the post window.
-- @param expr Any valid SuperCollider expression.
function scnvim.send_silent(expr)
  sclang.send(expr, true)
end

--- Evalute a SuperCollider expression and get the result in a callback.
-- @param expr Any valid SuperCollider expression.
-- @param cb A callback with a result argument.
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
-- @returns True if sclang is running otherwise false.
function scnvim.is_running()
  return sclang.is_running()
end

return scnvim
