--- sclang
--- Spawn a sclang process.
---@module scnvim.sclang

local postwin = require 'scnvim.postwin'
local udp = require 'scnvim.udp'
local path = require 'scnvim.path'
local utils = require 'scnvim.utils'
local config = require 'scnvim.config'

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
        local lines = vim.gsplit(str, '\n')
        for line in lines do
          if line ~= '' then
            if M.on_read then
              M.on_read(line)
            end
          end
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

local function find_sclang_executable()
  if config.sclang.path then
    return config.sclang.path
  end
  local exe_path = vim.fn.exepath 'sclang'
  if exe_path ~= '' then
    return exe_path
  end
  local system = utils.get_system()
  if system == 'macos' then
    local app = 'SuperCollider.app/Contents/MacOS/sclang'
    local locations = { '/Applications', '/Applications/SuperCollider' }
    for _, loc in ipairs(locations) do
      path = string.format('%s/%s', loc, app)
      if vim.fn.executable(path) then
        return path
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
  M.stdout:read_stop()
  M.stderr:read_stop()
  M.stdin:shutdown(function()
    safe_close(M.stdin)
  end)
  safe_close(M.stdout)
  safe_close(M.stderr)
  safe_close(M.proc)
  if M.on_exit then
    M.on_exit(code, signal)
  end
  M.proc = nil
end

local function start_process()
  M.stdin = uv.new_pipe(false)
  M.stdout = uv.new_pipe(false)
  M.stderr = uv.new_pipe(false)

  local sclang = find_sclang_executable()
  local user_opts = utils.get_var 'scnvim_sclang_options' or {}
  assert(type(user_opts) == 'table', '[scnvim] g:scnvim_sclang_options must be an array')

  local options = {}
  options.stdio = {
    M.stdin,
    M.stdout,
    M.stderr,
  }
  options.cwd = vim.fn.expand '%:p:h'
  options.args = { '-i', 'scnvim', '-d', options.cwd }
  table.insert(options.args, user_opts)
  options.args = vim.tbl_flatten(options.args)
  -- windows specific settings
  options.hide = true

  return uv.spawn(sclang, options, vim.schedule_wrap(on_exit))
end

--- Function to run on sclang start
M.on_start = function()
  postwin.open()
end

--- Function to run on sclang exit
--@param code The exit code
--@param signal The Signal
M.on_exit = function(code, signal) -- luacheck: no unused args
  postwin.destroy()
end

--- Function to run on sclang output
--@param line sclang post window output
M.on_read = function(line)
  postwin.post(line)
end

--- Set the current document path
function M.set_current_path()
  if M.is_running() then
    local curpath = vim.fn.expand '%:p'
    curpath = path.normalize(curpath)
    curpath = string.format('SCNvim.currentPath = "%s"', curpath)
    M.send(curpath, true)
  end
end

--- Start polling the server status
function M.poll_server_status()
  local cmd = string.format('SCNvim.updateStatusLine(%d)', config.sclang.server_status_interval)
  M.send(cmd, true)
end

--- Generate assets. tags syntax etc.
---@param on_done Optional callback that runs when all assets have been created.
function M.generate_assets(on_done)
  assert(M.is_running(), '[scnvim] sclang not running')
  local format = config.snippet.engine.name
  local expr = string.format([[SCNvim.generateAssets(\"%s\", \"%s\")]], path.get_cache_dir(), format)
  M.eval(expr, on_done)
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
  local id = udp.push_eval_callback(cb)
  local cmd = string.format('SCNvim.eval("%s", "%s");', expr, id)
  M.send(cmd, true)
end

--- Start the sclang process.
function M.start()
  if M.is_running() then
    utils.print 'sclang is already running'
    return
  end

  if M.on_start then
    M.on_start()
  end

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
function M.stop()
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
        M.proc = nil
      end
    else
      -- process exited during timer loop
      timer:close()
    end
  end)
end

--- Recompile the class library.
function M.recompile()
  if not M.is_running() then
    utils.print 'sclang is already running'
    return
  end
  M.send(cmd_char.recompile, true)
  M.send(string.format('SCNvim.port = %d', udp.port), true)
  M.set_current_path()
end

return M
