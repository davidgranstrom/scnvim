local lib_paths = require'scnvim.lib'
local losc = require(lib_paths.losc)
local udp_transport = require'scnvim.osc.udp-transport'

local M = {}
M.__index = M

-- Be able to access the losc API from this module
M.losc = losc
 
function M.new(options)
  local self = setmetatable({}, M)
  options = vim.tbl_extend('keep', options or {}, {
    recvAddr = '127.0.0.1',
    recvPort = 0,
    sendAddr = '127.0.0.1',
    sendPort = 57120,
  })
  local transport = udp_transport.new(options)
  self.handle = losc.new{plugin = transport}
  return self
end

function M:start()
  assert(self.handle, 'Must call .new first')
  self.handle:open()
end

function M:stop()
  assert(self.handle, 'Must call .new first')
  self.handle:close()
end

function M:add_handler(name, cb)
  assert(self.handle, 'Must call .new first')
  self.handle:add_handler(name, cb)
end

function M:remove_handler(name)
  assert(self.handle, 'Must call .new first')
  self.handle:remove_handler(name)
end

function M:send(message)
  assert(self.handle, 'Must call .new first')
  self.handle:send(message)
end

function M:get_recv_port()
  assert(self.handle, 'Must call .new first')
  return self.handle.plugin:get_port()
end

return M
