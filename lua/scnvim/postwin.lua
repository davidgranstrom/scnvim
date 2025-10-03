--- Post window.
--- The interpreter's post window.
---@module scnvim.postwin

local path = require 'scnvim.path'
local config = require 'scnvim.config'
local action = require 'scnvim.action'
local api = vim.api
local M = {}

--- Actions
---@section actions

--- Action for when the post window opens.
--- The default is to apply the post window settings.
M.on_open = action.new(function()
  vim.opt_local.buftype = 'nofile'
  vim.opt_local.bufhidden = 'hide'
  vim.opt_local.swapfile = false
  local decorations = {
    'number',
    'relativenumber',
    'modeline',
    'wrap',
    'cursorline',
    'cursorcolumn',
    'foldenable',
    'list',
  }
  for _, s in ipairs(decorations) do
    vim.opt_local[s] = false
  end
  vim.opt_local.colorcolumn = ''
  vim.opt_local.foldcolumn = '0'
  vim.opt_local.winfixwidth = true
  vim.opt_local.tabstop = 4
end)

--- Functions
---@section functions

--- Test that the post window buffer is valid.
---@return True if the buffer is valid otherwise false.
---@private
local function buf_is_valid()
  return M.buf and api.nvim_buf_is_loaded(M.buf)
end

--- Create a scratch buffer for the post window output.
---@return A buffer handle.
---@private
local function create()
  if buf_is_valid() then
    return M.buf
  end
  local buf = api.nvim_create_buf(true, true)
  api.nvim_buf_set_option(buf, 'filetype', 'scnvim')
  api.nvim_buf_set_name(buf, '[scnvim]')
  M.buf = buf
  return buf
end

--- Save the last size of the post window.
--@private
local function save_last_size()
  if not config.postwin.float.enabled then
    if not config.postwin.horizontal then
      M.last_size = api.nvim_win_get_width(M.win)
    else
      M.last_size = api.nvim_win_get_height(M.win)
    end
  end
end

local function resolve(v)
  if type(v) == 'function' then
    return v()
  end
  return v
end

--- Open a floating post window
---@private
local function open_float()
  local width = resolve(config.postwin.float.width)
  local height = resolve(config.postwin.float.height)
  local row = resolve(config.postwin.float.row)
  local col = resolve(config.postwin.float.col)
  local options = {
    relative = 'editor',
    anchor = 'NE',
    row = row,
    col = col,
    width = math.floor(width),
    height = math.floor(height),
    border = 'single',
    style = 'minimal',
  }
  options = vim.tbl_deep_extend('keep', config.postwin.float.config, options)
  local id = api.nvim_open_win(M.buf, false, options)
  local callback = config.postwin.float.callback
  if callback then
    callback(id)
  end
  return id
end

--- Open a post window as a split
---@private
local function open_split()
  local horizontal = config.postwin.horizontal
  local direction = config.postwin.direction
  if direction == 'top' or direction == 'left' then
    direction = 'topleft'
  elseif direction == 'right' or direction == 'bot' then
    direction = 'botright'
  else
    error '[scnvim] invalid config.postwin.direction'
  end
  local win_cmd = string.format('%s %s', direction, horizontal and 'split' or 'vsplit')
  vim.cmd(win_cmd)
  local id = api.nvim_get_current_win()
  local size
  if config.postwin.fixed_size then
    size = config.postwin.fixed_size
  else
    size = M.last_size or config.postwin.size
  end
  if horizontal then
    api.nvim_win_set_height(id, math.floor(size or vim.o.lines / 3))
  else
    api.nvim_win_set_width(id, math.floor(size or vim.o.columns / 2))
  end
  api.nvim_win_set_buf(id, M.buf)
  vim.cmd [[ wincmd p ]]
  return id
end

--- Open the post window.
---@return A window handle.
function M.open()
  if M.is_open() then
    return M.win
  end
  if not buf_is_valid() then
    create()
  end
  if config.postwin.float.enabled then
    M.win = open_float()
  else
    M.win = open_split()
  end
  vim.api.nvim_win_call(M.win, M.on_open)
  return M.win
end

--- Test if the window is open.
---@return True if open otherwise false.
function M.is_open()
  return M.win ~= nil and api.nvim_win_is_valid(M.win)
end

--- Close the post window.
function M.close()
  if M.is_open() then
    save_last_size()
    -- This call can fail if its the last window
    pcall(api.nvim_win_close, M.win, true)
    M.win = nil
  end
end

--- Destroy the post window.
--- Calling this function closes the post window and deletes the buffer.
function M.destroy()
  if M.is_open() then
    -- This call can fail if its the last window
    pcall(api.nvim_win_close, M.win, true)
    M.win = nil
  end
  if buf_is_valid() then
    api.nvim_buf_delete(M.buf, { force = true })
    M.buf = nil
  end
  M.last_size = nil
end

--- Toggle the post window.
function M.toggle()
  if M.is_open() then
    M.close()
  else
    M.open()
  end
end

--- Clear the post window buffer.
function M.clear()
  if buf_is_valid() then
    api.nvim_buf_set_lines(M.buf, 0, -1, true, {})
  end
end

--- Open the post window and move to it.
function M.focus()
  local win = M.open()
  vim.fn.win_gotoid(win)
end

--- Print a line to the post window.
---@param line The line to print.
function M.post(line)
  if not buf_is_valid() then
    return
  end

  local auto_toggle_error = config.postwin.auto_toggle_error
  local scrollback = config.postwin.scrollback

  local found_error = line:match '^ERROR'
  if found_error and auto_toggle_error then
    if not M.is_open() then
      M.open()
    end
  end

  if path.is_windows then
    line = line:gsub('\r', '')
  end
  vim.api.nvim_buf_set_lines(M.buf, -1, -1, true, { line })

  local num_lines = vim.api.nvim_buf_line_count(M.buf)
  if scrollback > 0 and num_lines > scrollback then
    vim.api.nvim_buf_set_lines(M.buf, 0, 1, true, {})
    num_lines = vim.api.nvim_buf_line_count(M.buf)
  end

  if M.is_open() then
    vim.api.nvim_win_set_cursor(M.win, { num_lines, 0 })
  end
end

return M
