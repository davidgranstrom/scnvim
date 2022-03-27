--- Communication between nvim and sclang.
-- @module scnvim/udp
-- @author David Granström
-- @license GPLv3

local help = require'scnvim.help'

local uv = vim.loop
local M = {}

local HOST = '127.0.0.1'
local PORT = 0
local eval_callbacks = {}

--- UDP handlers.
-- Run the matching function in this table for the incoming 'action' parameter.
-- @see on_receive
local Handlers = {}

--- Update status line widgets
function Handlers.status_line(args)
  if not args then return end
  vim.api.nvim_set_var('scnvim_stl_widgets', args)
end

--- Print function signature
function Handlers.method_args(args)
  if not args then return end
  print(args)
end

--- Open a help file
function Handlers.help_open_file(args)
  if not args then return end
  help.open(args.uri, args.pattern)
end

--- Search for a method name
function Handlers.help_find_method(args)
  if not args then return end
  help.handle_method(args.method_name, args.helpTargetDir)
end

--- Evaluate a piece of lua code sent from sclang
function Handlers.luaeval(codestring)
  if not codestring then return end
  local func = loadstring(codestring)
  func()
end

--- Receive data from sclang
function Handlers.eval(result)
  assert(result)
  local callback = table.remove(eval_callbacks)
  if callback then
    callback(result)
  end
end

--- Callback for UDP datagrams
local function on_receive(err, chunk)
  assert(not err, err)
  if chunk then
    local ok, object = pcall(vim.fn.json_decode, chunk)
    if not ok then
      error('[scnvim] Could not decode json chunk: ' .. object)
    end
    local func = Handlers[object.action]
    assert(func, '[scnvim] Unrecognized handler')
    func(object.args)
  end
end

--- Start the UDP server.
function M.start_server()
  local handle = uv.new_udp('inet')
  assert(handle, 'Could not create UDP handle')
  handle:bind(HOST, PORT, {reuseaddr=true})
  handle:recv_start(vim.schedule_wrap(on_receive))
  M.port = handle:getsockname().port
  M.udp = handle
  return M.port
end

--- Stop the UDP server.
function M.stop_server()
  if M.udp then
    M.udp:recv_stop()
    if not M.udp:is_closing() then
      M.udp:close()
    end
    M.udp = nil
  end
end

--- Push a callback to be evaluated later.
-- utility function for the scnvim.eval API.
function M.push_eval_callback(cb)
  -- need to check this for nvim versions < 0.5
  if vim.validate then
    vim.validate{
      cb = {cb, 'function'}
    }
  end
  table.insert(eval_callbacks, cb)
end

return M
