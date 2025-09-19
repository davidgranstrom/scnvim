--- Sclang wrapper.
---@module scnvim.sclang

local postwin = require 'scnvim.postwin'
local udp = require 'scnvim.udp'
local path = require 'scnvim.path'
local config = require 'scnvim.config'
local action = require 'scnvim.action'

local uv = vim.loop
local M = {}

local cmd_char = {
  interpret_print = string.char(0x0c),
  interpret = string.char(0x1b),
  recompile = string.char(0x18),
}

--- Utilities

local on_stdout = function()
  local stack = { '' }
  return function(err, data)
    assert(not err, err)
    if data then
      table.insert(stack, data)
      local str = table.concat(stack, '')
      local got_line = vim.endswith(str, '\n')
      if got_line then
        local lines = vim.split(str, '\n')
        if #lines > 0 and lines[#lines] == "" then
          table.remove(lines)
        end
        for _, line in pairs(lines) do
          M.on_output(line)
        end
        stack = { '' }
      end
    end
  end
end

local function safe_close(handle)
  if handle and not handle:is_closing() then
    handle:close()
  end
end

--- Actions
---@section actions

--- Action that runs before sclang is started.
--- The default is to open the post window.
M.on_init = action.new(function()
  postwin.open()
end)

--- Action that runs on sclang exit
--- The default is to destory the post window.
---@param code The exit code
---@param signal Terminating signal
M.on_exit = action.new(function(code, signal) -- luacheck: no unused args
  postwin.destroy()
end)

--- Action that runs on sclang output.
--- The default is to print a line to the post window.
---@param line A complete line of sclang output.
M.on_output = action.new(function(line)
  postwin.post(line)
end)

--- Functions
---@section functions

function M.find_sclang_executable()
  if config.sclang.cmd then
    return config.sclang.cmd
  end
  local exe_path = vim.fn.exepath 'sclang'
  if exe_path ~= '' then
    return exe_path
  end
  local system = path.get_system()
  if system == 'macos' then
    local app = 'SuperCollider.app/Contents/MacOS/sclang'
    local locations = { '/Applications', '/Applications/SuperCollider' }
    for _, loc in ipairs(locations) do
      local app_path = string.format('%s/%s', loc, app)
      if vim.fn.executable(app_path) ~= 0 then
        return app_path
      end
    end
  elseif system == 'windows' then -- luacheck: ignore
    -- TODO: a default path for Windows
  elseif system == 'linux' then -- luacheck: ignore
    -- TODO: a default path for Windows
  end
  error 'Could not find `sclang`. Add `sclang.path` to your configuration.'
end

local function on_exit(code, signal)
  M.stdin:shutdown()
  M.stdout:read_stop()
  M.stderr:read_stop()
  safe_close(M.stdin)
  safe_close(M.stdout)
  safe_close(M.stderr)
  safe_close(M.proc)
  M.on_exit(code, signal)
  M.proc = nil
end

local function start_process()
  M.stdin = uv.new_pipe(false)
  M.stdout = uv.new_pipe(false)
  M.stderr = uv.new_pipe(false)
  local sclang = M.find_sclang_executable()
  local options = {}
  options.stdio = {
    M.stdin,
    M.stdout,
    M.stderr,
  }
  options.cwd = vim.fn.expand '%:p:h'
  for _, arg in ipairs(config.sclang.args) do
    if arg:match '-i' then
      error '[scnvim] invalid sclang argument "-i"'
    end
    if arg:match '-d' then
      error '[scnvim] invalid sclang argument "-d"'
    end
  end
  options.args = { '-i', 'scnvim', '-d', options.cwd, unpack(config.sclang.args) }
  options.hide = true
  return uv.spawn(sclang, options, vim.schedule_wrap(on_exit))
end

--- Set the current document path
---@local
function M.set_current_path()
  if M.is_running() then
    local curpath = vim.fn.expand '%:p'
    curpath = vim.fn.escape(curpath, [[ \]])
    curpath = string.format('SCNvim.currentPath = "%s"', curpath)
    M.send(curpath, true)
  end
end

--- Start polling the server status
---@local
function M.poll_server_status()
  local cmd = string.format('SCNvim.updateStatusLine(%d)', config.statusline.poll_interval)
  M.send(cmd, true)
end

--- Generate assets. tags syntax etc.
---@param on_done Optional callback that runs when all assets have been created.
function M.generate_assets(on_done)
  assert(M.is_running(), '[scnvim] sclang not running')
  local format = config.snippet.engine.name
  local expr = string.format([[SCNvim.generateAssets("%s", "%s")]], path.get_cache_dir(), format)
  M.eval(expr, on_done)
end

--- Send a "hard stop" to the interpreter.
function M.hard_stop()
  M.send('thisProcess.stop', true)
end

--- Check if the process is running.
---@return True if running otherwise false.
function M.is_running()
  return M.proc and M.proc:is_active() or false
end

--- Send code to the interpreter.
---@param data The code to send.
---@param silent If true will not echo output to the post window.
function M.send(data, silent)
  silent = silent or false
  if M.is_running() then
    M.stdin:write {
      data,
      not silent and cmd_char.interpret_print or cmd_char.interpret,
    }
  end
end

--- Evaluate a SuperCollider expression and return the result to lua.
---@param expr The expression to evaluate.
---@param cb The callback with a single argument that contains the result.
function M.eval(expr, cb)
  vim.validate {
    expr = { expr, 'string' },
    cb = { cb, 'function' },
  }
  expr = vim.fn.escape(expr, '"')
  local id = udp.push_eval_callback(cb)
  local cmd = string.format('SCNvim.eval("%s", "%s");', expr, id)
  M.send(cmd, true)
end

--- Start the sclang process.
function M.start()
  if M.is_running() then
    vim.notify('sclang already started', vim.log.levels.INFO)
    return
  end

  M.on_init()

  M.proc = start_process()
  assert(M.proc, 'Could not start sclang process')

  local port = udp.start_server()
  assert(port > 0, 'Could not start UDP server')
  M.send(string.format('SCNvim.port = %d', port), true)
  M.set_current_path()

  local onread = on_stdout()
  M.stdout:read_start(vim.schedule_wrap(onread))
  M.stderr:read_start(vim.schedule_wrap(onread))
end

--- Stop the sclang process.
function M.stop(_, callback)
  if not M.is_running() then
    return
  end
  udp.stop_server()
  M.send('0.exit', true)
  local timer = uv.new_timer()
  timer:start(1000, 0, function()
    if M.proc then
      local ret = M.proc:kill 'sigkill'
      if ret == 0 then
        timer:close()
        if callback then
          vim.schedule(callback)
        end
        M.proc = nil
      end
    else
      -- process exited during timer loop
      timer:close()
      if callback then
        vim.schedule(callback)
      end
    end
  end)
end

function M.reboot()
  M.stop(nil, M.start)
end

--- Recompile the class library.
function M.recompile()
  if not M.is_running() then
    vim.notify('sclang not started', vim.log.levels.ERROR)
    return
  end
  M.send(cmd_char.recompile, true)
  M.send(string.format('SCNvim.port = %d', udp.port), true)
  M.set_current_path()
end

return M
