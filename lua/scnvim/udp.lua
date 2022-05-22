--- UDP
--- Receive data from sclang as UDP datagrams.
--- The data should be in the form of JSON formatted strings.
---@module scnvim.udp
---@local

local uv = vim.loop
local M = {}

local HOST = '127.0.0.1'
local PORT = 0
local eval_callbacks = {}
local callback_id = '0'

--- UDP handlers.
--- Run the matching function in this table for the incoming 'action' parameter.
local Handlers = {}

--- Evaluate a piece of lua code sent from sclang
---@local
function Handlers.luaeval(codestring)
  if not codestring then
    return
  end
  local func = loadstring(codestring)
  local ok, result = pcall(func)
  if not ok then
    print('[scnvim] luaeval: ' .. result)
  end
end

--- Receive data from sclang
---@local
function Handlers.eval(object)
  assert(object)
  local callback = eval_callbacks[object.id]
  if callback then
    callback(object.result)
    eval_callbacks[object.id] = nil
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
  local handle = uv.new_udp 'inet'
  assert(handle, 'Could not create UDP handle')
  handle:bind(HOST, PORT, { reuseaddr = true })
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
--- Utility function for the scnvim.eval API.
---@local
function M.push_eval_callback(cb)
  callback_id = tostring(tonumber(callback_id) + 1)
  eval_callbacks[callback_id] = cb
  return callback_id
end

return M
