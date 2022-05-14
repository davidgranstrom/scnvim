--- Post window.
---@module scnvim/postwin
---@author David Granström
---@license GPLv3

local utils = require 'scnvim.utils'
local config = require 'scnvim.config'
local api = vim.api
local M = {}

--- Values to be cached
local scrollback
local auto_toggle_error
local direction
local orientation
local fixed_size

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

--- Open the post window.
---@return A window handle.
function M.open()
  if M.is_open() then
    return M.win
  end
  if not buf_is_valid() then
    create()
  end
  vim.cmd(string.format('%s %s new', orientation, direction))
  local id = api.nvim_get_current_win()
  if orientation == 'vertical' then
    local width = fixed_size or math.floor(vim.o.columns / 2)
    api.nvim_win_set_width(id, width)
  else
    local height = fixed_size or math.floor(vim.o.lines / 3)
    api.nvim_win_set_height(id, height)
  end
  api.nvim_win_set_buf(id, M.buf)
  vim.cmd [[ wincmd p ]]
  M.win = id
  return id
end

--- Test if the window is open.
---@return True if open otherwise false.
function M.is_open()
  return M.win and api.nvim_win_is_valid(M.win)
end

--- Close the post window.
function M.close()
  if M.is_open() then
    api.nvim_win_close(M.win, false)
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
    if buf_is_valid() then
      api.nvim_buf_delete(M.buf, true)
      M.buf = nil
    end
  end
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

--- Print a line to the post window.
---@param line The line to print.
function M.post(line)
  if not buf_is_valid() then
    return
  end

  local found_error = line:match '^ERROR'
  if found_error and auto_toggle_error then
    if not M.is_open() then
      M.open()
    end
  end

  if utils.is_windows then
    line = line:gsub('\r', '')
  end
  vim.api.nvim_buf_set_lines(M.buf, -1, -1, true, { line })

  local num_lines = vim.api.nvim_buf_line_count(M.buf)
  if scrollback > 0 then
    if num_lines > scrollback then
      local num = math.floor(scrollback - vim.o.lines)
      vim.api.nvim_buf_set_lines(M.buf, 0, num, true, {})
      num_lines = vim.api.nvim_buf_line_count(M.buf)
    end
  end

  if M.is_open() then
    vim.api.nvim_win_set_cursor(M.win, { num_lines, 0 })
  end
end

--- Setup function.
--- Cache some values.
---@private
function M.setup()
  if config.postwin.direction == 'right' then
    direction = 'botright'
  elseif config.direction == 'left' then
    direction = 'topleft'
  end
  orientation = 'vertical'
  if config.postwin.horizontal then
    orientation = ''
  end
  auto_toggle_error = config.postwin.auto_toggle_error
  scrollback = config.postwin.scrollback
  fixed_size = config.postwin.fixed_size
end

return M
