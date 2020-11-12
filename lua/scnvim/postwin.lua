local api = vim.api
local utils = require'scnvim/utils'
local settings = vim.call('scnvim#util#get_user_settings')
local toggle_on_err = settings.post_window.auto_toggle
local max_lines = vim.g.scnvim_postwin_scrollback or 5000
local M = {}

function M.create()
  M.bufnr = vim.call('scnvim#postwindow#create')
end

function M.open()
  vim.call('scnvim#postwindow#open')
end

function M.close()
  vim.call('scnvim#postwindow#close')
end

function M.destroy()
  vim.call('scnvim#postwindow#destroy')
end

function M.toggle()
  vim.call('scnvim#postwindow#toggle')
end

local function is_valid()
  return api.nvim_buf_is_loaded(M.bufnr)
end

function M.get_winid()
  return vim.fn.bufwinid(M.bufnr)
end

function M.is_open()
  return is_valid() and vim.fn.bufwinnr(M.bufnr) > 0
end

function M.print(line)
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
  if num_lines > max_lines then
    vim.api.nvim_buf_set_lines(M.bufnr, 0, max_lines, true, {})
    num_lines = vim.api.nvim_buf_line_count(M.bufnr)
  end

  if M.is_open() then
    vim.api.nvim_win_set_cursor(M.get_winid(), {num_lines, 0})
  end
end

return M
