--- Spawn a sclang process.
-- @module scnvim/sclang
-- @author David Granström
-- @license GPLv3

local uv = vim.loop
local postwin = require('scnvim/postwin')
local udp = require('scnvim/udp')
local utils = require('scnvim/utils')
local vimcall = utils.vimcall
local endswith = vim.endswith or utils.str_endswidth
local M = {}

local cmd_char = {
  interpret_print = string.char(0x0c),
  interpret = string.char(0x1b),
  recompile = string.char(0x18),
}

--- Utilities

local on_stdout = function()
  local stack = {''}
  return function(err, data)
    assert(not err, err)
    if data then
      table.insert(stack, data)
      local str = table.concat(stack, '')
      -- TODO: not sure if \r is needed.. need to check on windows.
      local got_line = endswith(str, '\n') or endswith(str, '\r')
      if got_line then
        local lines = vim.gsplit(str, '[\n\r]')
        for line in lines do
          if line ~= '' then
            if M.on_read then
              M.on_read(line)
            end
          end
        end
        stack = {''}
      end
    end
  end
end

local function safe_close(handle)
  if handle and not handle:is_closing() then
    handle:close()
  end
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

  local settings = vimcall('scnvim#util#get_user_settings')
  local sclang = settings.paths.sclang_executable
  local user_opts = utils.get_var('scnvim_sclang_options') or {}
  assert(type(user_opts) == 'table', '[scnvim] g:scnvim_sclang_options must be an array')

  local options = {}
  options.stdio = {
    M.stdin,
    M.stdout,
    M.stderr,
  }
  options.cwd = vimcall('expand', '%:p:h')
  options.args = {'-i', 'scnvim', '-d', options.cwd}
  table.insert(options.args, user_opts)
  options.args = vim.tbl_flatten(options.args)
  -- windows specific settings
  options.hide = true

  return uv.spawn(sclang, options, vim.schedule_wrap(on_exit))
end

--- Interface

--- Function to run on sclang start
M.on_start = function()
  postwin.create()
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

function M.is_running()
  return M.proc and M.proc:is_active() or false
end

function M.send(data, silent)
  silent = silent or false
  if M.is_running() then
    M.stdin:write({
      data,
      not silent and cmd_char.interpret_print or cmd_char.interpret
    })
  end
end

function M.eval(expr, cb)
  local cmd = string.format('SCNvim.eval("%s");', expr)
  udp.push_eval_callback(cb)
  M.send(cmd, true)
end

function M.start()
  if M.is_running() then
    vimcall('scnvim#util#err', 'sclang is already running')
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
  vimcall('scnvim#document#set_current_path')

  local onread = on_stdout()
  M.stdout:read_start(vim.schedule_wrap(onread))
  M.stderr:read_start(vim.schedule_wrap(onread))
end

function M.stop()
  if not M.is_running() then
    return
  end
  udp.stop_server()
  M.send('0.exit', true)
  local timer = uv.new_timer()
  timer:start(1000, 0, function()
    if M.proc then
      local ret = M.proc:kill("sigkill")
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

function M.recompile()
  if not M.is_running() then
    vimcall('scnvim#util#err', 'sclang is already running')
    return
  end
  M.send(cmd_char.recompile, true)
  M.send(string.format('SCNvim.port = %d', udp.port), true)
  vimcall('scnvim#document#set_current_path')
end

return M
