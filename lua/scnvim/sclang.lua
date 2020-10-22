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

local function print_to_postwin(line)
  if postwin_bufnr then
    vim.api.nvim_buf_set_lines(postwin_bufnr, -1, -1, true, {line})
  end
end

local on_stdout = function(fd) 
  local s = ''
  uv.read_start(fd, function(err, data)
    assert(not err, err)
    if data then
      s = s .. data
      local lines = vim.gsplit(s, '[\r\n]+')
      for line in lines do
        if line ~= '' then
          vim.schedule_wrap(function()
            print_to_postwin(line)
          end)()
        else
          s = ''
        end
      end
    end
  end)
end

function M.is_running()
  return handle and true or false
end

function M.start()
  -- if M.is_running then
  --   utils.vimcall('scnvim#util#err', {'sclang is already running'})
  --   return
  -- end

  local settings = utils.vimcall('scnvim#util#get_user_settings', {})
  local sclang = settings.paths.sclang_executable
  local cwd = utils.vimcall('expand', {'%:p:h'})
  local options = {
    stdio = {
      stdin,
      stdout,
      stderr,
    },
    args = {sclang, '-i', 'scnvim', '-d', rundir}, -- TODO: get scnvim_sclang_options 
    cwd = cwd,
    hide = true,
    verbatim = true,
  }

  local on_exit = function(code, signal)
    stdout:close()
    stderr:close()
    handle:close()
    -- on_handle_exit(code)
  end

  handle, pid = uv.spawn(sclang, options, on_exit)
  assert(handle, 'Could not open sclang process')

  postwin_bufnr = utils.vimcall('scnvim#postwindow#create', {})

  scnvim.init()
  utils.vimcall('scnvim#document#set_current_path', {})

  on_stdout(stdout)
end

function M.stop()
end

return M
