--- Post window.
-- @module scnvim/postwin
-- @author David Granström
-- @license GPLv3

local utils = require'scnvim.utils'

local api = vim.api
local vimcall = utils.vimcall
local settings = vimcall('scnvim#util#get_user_settings')
local toggle_on_err = settings.post_window.auto_toggle
local max_lines = utils.get_var('scnvim_postwin_scrollback') or 5000
local M = {}

function M.create()
  M.bufnr = vimcall('scnvim#postwindow#create')
end

function M.open()
  vimcall('scnvim#postwindow#open')
end

function M.close()
  vimcall('scnvim#postwindow#close')
end

function M.destroy()
  vimcall('scnvim#postwindow#destroy')
end

function M.toggle()
  vimcall('scnvim#postwindow#toggle')
end

function M.clear()
  vimcall('scnvim#postwindow#clear')
end

local function is_valid()
  return api.nvim_buf_is_loaded(M.bufnr)
end

function M.get_winid()
  return vimcall('bufwinid', M.bufnr)
end

function M.is_open()
  return is_valid() and vimcall('bufwinnr', M.bufnr) > 0
end

function M.post(line)
  if not is_valid() then
    return
  end

  local found_error = line:match('^ERROR')
  if found_error and toggle_on_err then
    if not M.is_open() then
      M.open()
    end
  end

  if utils.is_windows then
    line = line:gsub('\r', '')
  end
  vim.api.nvim_buf_set_lines(M.bufnr, -1, -1, true, {line})

  local num_lines = vim.api.nvim_buf_line_count(M.bufnr)
  if max_lines > 0 then
    if num_lines > max_lines then
      vim.api.nvim_buf_set_lines(M.bufnr, 0, max_lines, true, {})
      num_lines = vim.api.nvim_buf_line_count(M.bufnr)
    end
  end

  if M.is_open() then
    vim.api.nvim_win_set_cursor(M.get_winid(), {num_lines, 0})
  end
end

return M
