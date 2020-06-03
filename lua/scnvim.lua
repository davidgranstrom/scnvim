local udp = require('udp')
local utils = require('utils')
local help = require('help')

local scnvim = {}
local eval_callback = nil

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

--- Receive data from sclang
function Methods.eval(result)
  assert(result)
  if eval_callback then
    eval_callback(result)
    eval_callback = nil
  end
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
      assert(object, '[scnvim] Could not decode json chunk')
      local func = Methods[object.action]
      assert(func, '[scnvim] Unrecognized handler')
      func(object.args)
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

function scnvim.eval(expr, cb)
  local cmd = string.format('SCNvim.eval("%s");', expr)
  eval_callback = cb
  utils.send_to_sc(cmd)
end

function scnvim.send(expr)
  utils.send_to_sc(expr)
end

local function get_path()
  local ret, data = pcall(vim.api.nvim_get_var, 'scnvim_root_dir')
  local is_running = utils.vimcall('scnvim#sclang#is_running', {})
  if is_running == 0 then
    return nil, '[scnvim] Start sclang first :SCNvimStart'
  end
  if ret
    then return data .. utils.path_sep .. 'scide_scnvim'
  else
    return nil, '[scnvim] Could not get scnvim root directory.'
  end
end

function scnvim.install()
  local path = assert(get_path())
  local cmd = string.format([[
    LanguageConfig.addIncludePath("%s");
    LanguageConfig.store;
  ]], path)
  utils.send_to_sc(cmd)
  print('[scnvim] Installed, please recompile class library.')
end

function scnvim.uninstall()
  local path = assert(get_path())
  local cmd = string.format([[
    LanguageConfig.removeIncludePath("%s");
    LanguageConfig.store;
  ]], path)
  utils.send_to_sc(cmd)
  print('[scnvim] Uninstalled, please recompile class library.')
end

return scnvim
