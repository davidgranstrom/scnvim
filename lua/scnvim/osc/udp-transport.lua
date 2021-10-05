--------------------------------
-- UDP client/server for Neovim.
--
-- @module osc.udp-transport
-- @author David Granström
-- @license MIT
-- @copyright David Granström 2021

local lib_paths = require'scnvim.lib'
local Timetag = require(lib_paths.losc .. '.timetag')
local Pattern = require(lib_paths.losc .. '.pattern')
local Packet = require(lib_paths.losc .. '.packet')
local uv = vim.loop

local M = {}
M.__index = M
--- Fractional precision for bundle scheduling.
-- 1000 is milliseconds. 1000000 is microseconds etc. Any precision is valid
-- that makes sense for the plugin's scheduling function.
M.precision = 1000

--- Create a new instance.
-- @tparam[options] table options Options.
-- @usage local udp = plugin.new()
-- @usage
-- local udp = plugin.new {
--   sendAddr = '127.0.0.1',
--   sendPort = 9000,
--   recvAddr = '127.0.0.1',
--   recvPort = 8000,
-- }
function M.new(options)
  local self = setmetatable({}, M)
  self.options = options or {}
  self.handle = uv.new_udp('inet')
  assert(self.handle, 'Could not create UDP handle.')
  return self
end

--- Create a Timetag with the current time.
-- Precision is in milliseconds.
-- @return Timetag object with current time.
function M:now() -- luacheck: ignore
  local s, m = uv.gettimeofday()
  return Timetag.new(s, m / M.precision)
end

--- Schedule a OSC method for dispatch.
--
-- @tparam number timestamp When to schedule the bundle.
-- @tparam function handler The OSC handler to call.
function M:schedule(timestamp, handler) -- luacheck: ignore
  timestamp = math.max(0, timestamp)
  if timestamp > 0 then
    local timer = uv.new_timer()
    timer:start(timestamp, 0, handler)
  else
    handler()
  end
end

--- Start UDP server.
-- @tparam string host IP address (e.g. '127.0.0.1').
-- @tparam number port The port to listen on.
function M:open(host, port)
  host = host or self.options.recvAddr
  port = port or self.options.recvPort
  self.handle:bind(host, port, {reuseaddr=true})
  self.handle:recv_start(function(err, data, addr)
    assert(not err, err)
    if data then
      self.remote_info = addr
      local ok, errormsg = pcall(Pattern.dispatch, data, self)
      if not ok then
        print(errormsg)
      end
    end
  end)
end

--- Close UDP server.
function M:close()
  self.handle:recv_stop()
  if not self.handle:is_closing() then
    self.handle:close()
  end
  self.handle = nil
end

--- Get the port
function M:get_port()
  assert(self.handle, 'Must call open first')
  return self.handle:getsockname().port
end

--- Send a OSC packet.
-- @tparam table packet The packet to send.
-- @tparam string address The IP address to send to.
-- @tparam number port The port to send to.
function M:send(packet, address, port)
  address = address or self.options.sendAddr
  port = port or self.options.sendPort
  packet = assert(Packet.pack(packet))
  self.handle:try_send(packet, address, port)
end

return M
