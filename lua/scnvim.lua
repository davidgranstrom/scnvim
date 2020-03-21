local udp = require('udp')
local utils = require('utils')
local help = require('help')

local scnvim = {}

--- Method table
-- run the matching function from incoming 'action'
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

--- Callback for UDP commands
local function on_receive(err, chunk)
  assert(not err, err)
  if chunk then
    vim.schedule_wrap(function()
      -- uncomment for nvim 0.5.x
      -- local status, object = utils.json_decode(chunk)
      -- assert(status, object)
      local object = utils.json_decode(chunk)
      local func = Methods[object.action]
      if func then
        func(object.args)
      end
    end)()
  end
end

--- Public interface
function scnvim.init()
  udp.start_server(on_receive)
end

function scnvim.deinit()
  udp.stop_server()
end

return scnvim
