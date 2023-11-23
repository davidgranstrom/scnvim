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

--- Start the UDP server.
function M.start_server()
  local rpc_addr = assert(vim.fn.serverstart('scnvim.sock'), 'Could not start RPC server')
  local client = assert(uv.new_udp 'inet', 'Could not create UDP client')
  local server = assert(uv.new_udp 'inet', 'Could not create UDP server')
  local socket = assert(uv.new_pipe(false), 'Could not create pipe')

  socket:connect(rpc_addr)
  server:bind(HOST, PORT, { reuseaddr = true })
  server:recv_start(vim.schedule_wrap(function(err, chunk)
    assert(not err, err)
    if chunk then
      socket:write(chunk)
    end
  end))

  local tmp = { '' }
  local max_size = socket:recv_buffer_size()
  socket:read_start(function(err, chunk)
    assert(not err, err)
    table.insert(tmp, chunk)
    local chunk_size = string.len(chunk)
    if (chunk_size < max_size) then
      local data = table.concat(tmp, '')
      local num_chunks = math.ceil(#data / max_size)
      local chunk_id = 1
      for i = 1, #data, max_size do
        local payload = {
          chunk_id,
          num_chunks,
          data:sub(i, i + max_size - 1),
        }
        local ok, bytes = pcall(vim.mpack.encode, payload)
        if not ok then
          print(string.format('[scnvim] Could not encode msgpack payload [%d/%d]: %s', chunkId, num_chunks, bytes))
        end
        client:send(bytes, HOST, 9999)
        chunk_id = chunk_id + 1
      end
      tmp = { '' }
    end
  end)

  M.handles = {
    socket = socket,
    client = client,
    server = client,
  }

  return server:getsockname().port
end

--- Stop the UDP server.
function M.stop_server()
  local server = M.handles.server
  local client = M.handles.client
  local socket = M.handles.socket
  if server then
    server:recv_stop()
    if not server:is_closing() then
      server:close()
    end
    M.handles.server = nil
  end
  if socket then
    if not socket:is_closing() then
      socket:close()
    end
    M.handles.socket = nil
  end
  if client then
    if not client:is_closing() then
      client:close()
    end
    M.handles.client = nil
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
