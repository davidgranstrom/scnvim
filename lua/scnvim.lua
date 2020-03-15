local udp = require('udp')
local utils = require('utils')
local help = require('help')

local scnvim = {
  utils = utils,
  help = help,
  udp = udp,
}

-- Method table
local Methods = {}

function Methods.update_status_line()
  print('statusline updated')
end

local function on_receive(err, chunk)
  assert(not err, err)
  if chunk then
    vim.schedule_wrap(function()
      local status, object = utils.json_decode(chunk)
      assert(status, object)
      local func = Methods[object.action]
      if func then
        func(object.args)
      end
    end)()
  end
end

function scnvim.init()
  udp.start_server(on_receive)
end

function scnvim.deinit()
  udp.stop_server()
end

return scnvim
