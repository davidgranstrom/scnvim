--- Spawn a sclang process.
-- @module scnvim/sclang
-- @author David Granström
-- @license GPLv3

local scnvim = require('scnvim')
local utils = require('scnvim/utils')

local M = {}
local uv = vim.loop
local handle, pid
local postwin_bufnr

local stdin = uv.new_pipe(false)
local stdout = uv.new_pipe(false)
local stderr = uv.new_pipe(false)

local function get_options(path)
  local options = {}
  options.stdio = {
    stdin,
    stdout,
    stderr,
  }
  options.cwd = vim.call('expand', '%:p:h')
  -- TODO: get sclang user options
  options.args = {'-i', 'scnvim', '-d', options.cwd}
  -- windows specific settings
  options.verbatim = true
  options.hide = true
  return options
end

local function print_to_postwin(line)
  if postwin_bufnr then
    vim.api.nvim_buf_set_lines(postwin_bufnr, -1, -1, true, {line})
  end
end

local on_stdout = function() 
  local s = ''
  return function(err, data)
    assert(not err, err)
    if data then
      s = s .. data
      local lines = vim.gsplit(s, '[\r\n]')
      for line in lines do
        if line ~= '' then
          print_to_postwin(line)
        else
          s = ''
        end
      end
    end
  end
end

function M.is_running()
  return handle and handle:is_active()
end

function M.send(data, silent)
  if M.is_running() then
    stdin:write({data, string.char(silent and 0x1b or 0x0c)})
  end
end

local function safe_close(handle)
  if not handle:is_closing() then
    handle:close()
  end
end

function M.on_exit()
  stdout:read_stop()
  stderr:read_stop()
  safe_close(stdin)
  safe_close(stdout)
  safe_close(stderr)
  safe_close(handle)
end

function M.start()
  if M.is_running() then
    vim.call('scnvim#util#err', {'sclang is already running'})
    return
  end

  local settings = vim.call('scnvim#util#get_user_settings')
  local sclang = settings.paths.sclang_executable
  local options = get_options()
  handle = uv.spawn(sclang, options, vim.schedule_wrap(M.on_exit))
  assert(handle, 'Could not open sclang process')

  postwin_bufnr = vim.call('scnvim#postwindow#create') -- TODO: should also move to lua
  scnvim.init()
  vim.call('scnvim#document#set_current_path') -- TODO: should also move to lua

  local onread = on_stdout()
  stdout:read_start(vim.schedule_wrap(onread))
  stderr:read_start(vim.schedule_wrap(onread))
end

function M.stop()
  if M.is_running() then
    -- scnvim.send('0.exit')
  else
    vim.call('scnvim#util#err', {'sclang is not running'})
  end
end

return M
