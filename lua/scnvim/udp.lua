local utils = require('scnvim/utils')
local uv = vim.loop

local M = {
  udp = nil,
}

local HOST = '127.0.0.1'
local PORT = 0

function M.start_server(on_receive)
  local handle = uv.new_udp('inet')
  assert(handle, 'Could not create UDP handle')
  handle:bind(HOST, PORT, {reuseaddr=true})
  handle:recv_start(on_receive)
  M.udp = handle
  -- let sclang know which port the server is running on
  local port = handle:getsockname().port
  utils.send_to_sc('SCNvim.port = '..port)
end

function M.stop_server()
  if M.udp then
    M.udp:recv_stop()
    M.udp:close()
    M.udp = nil
  end
end

return M
