local utils = require('utils')
local M = {
  udp = nil,
}

local HOST = '127.0.0.1'
local PORT = 0

local uv = vim.loop

function M.start_server(on_receive)
  local handle = uv.new_udp('inet')
  assert(handle, 'Could not create UDP handle')
  handle:bind(HOST, PORT, {reuseaddr=true})
  handle:recv_start(on_receive)
  M.udp = handle
  print('server running on: ', handle:getsockname().port)
end

function M.stop_server()
  if M.udp then
    M.udp:close()
  end
end

return M
