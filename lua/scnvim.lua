--- scnvim main module.
-- @module scnvim
-- @author David Granström
-- @license GPLv3

local udp = require('scnvim/udp')
local utils = require('scnvim/utils')
local help = require('scnvim/help')

local scnvim = {}
local eval_callback = nil

--- Method table.
-- Run the matching function in this table for the incoming 'action' parameter.
-- @see on_receive
local Methods = {}

--- Update status line widgets
function Methods.status_line(args)
  if not args then return end
  vim.api.nvim_set_var('scnvim_stl_widgets', args)
end

--- Print function signature
function Methods.method_args(args)
  if not args then return end
  print(args)
end

--- Open a help file
function Methods.help_open_file(args)
  if not args then return end
  help.open(args.uri, args.pattern)
end

--- Search for a method name
function Methods.help_find_method(args)
  if not args then return end
  help.handle_method(args.method_name, args.helpTargetDir)
end

--- Receive data from sclang
function Methods.eval(result)
  assert(result)
  if eval_callback then
    eval_callback(result)
    eval_callback = nil
  end
end

--- Callback for UDP datagrams
local function on_receive(err, chunk)
  assert(not err, err)
  if chunk then
    vim.schedule_wrap(function()
      local object = utils.json_decode(chunk)
      assert(object, '[scnvim] Could not decode json chunk')
      local func = Methods[object.action]
      assert(func, '[scnvim] Unrecognized handler')
      func(object.args)
    end)()
  end
end

--- Public interface

--- Initialize scnvim
-- @note This function is called automatically on `:SCNvimStart`
function scnvim.init()
  udp.start_server(on_receive)
end

--- Deinitialize scnvim
-- @note This function is called automatically on `:SCNvimStop` or VimLeave.
function scnvim.deinit()
  udp.stop_server()
end

--- Evalute a SuperCollider expression and get the result in a callback.
-- @param expr Any valid SuperCollider expression.
-- @param cb A callback with a result argument.
function scnvim.eval(expr, cb)
  local cmd = string.format('SCNvim.eval("%s");', expr)
  eval_callback = cb
  utils.send_to_sc(cmd)
end

--- Evalute a SuperCollider expression.
-- @param expr Any valid SuperCollider expression.
function scnvim.send(expr)
  utils.send_to_sc(expr)
end

return scnvim
