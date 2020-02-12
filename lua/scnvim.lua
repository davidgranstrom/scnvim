local utils = require('utils')

local scnvim = {
  utils = utils
}

--- create a UDP server
local function create_server(host, port, on_receive)
  local server = vim.loop.new_udp('inet')
  server:bind(host, port, {reuseaddr=true})
  server:recv_start(on_receive)
  return server
end

local dispatch_table = {
  [1] = 'status_line_func'
  -- [2] = 'status_line'
}

local function on_receive(err, chunk)
  -- crash on errors
  assert(not err, err)
  if chunk then
    vim.schedule_wrap(function()
      local object, err = utils.json_decode(chunk)
      print(vim.inspect(object))
      if not object then
        print(err)
        return nil
      end
      -- dispatch_table[object.action]
    end)
  end
end

function scnvim.init()
  local server = create_server('127.0.0.1', 0, on_receive)
  -- assert(not server, '')
  local port = server:getsockname().port
  return port
end

return scnvim
