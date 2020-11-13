--- scnvim main module.
-- @module scnvim
-- @author David Granström
-- @license GPLv3

local sclang = require('scnvim/sclang')
local scnvim = {}

--- Public interface

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

return scnvim
