local M = {}
local utils = require('utils')
local api = vim.api

local function call(fn, args)
  return utils.vimcall(fn, args or {})
end

local function create_float_options(str)
  local is_first_line = call('line', {'.'}) == 1
  local anchor = is_first_line and 'NW' or 'SW'
  -- one line below cursor
  local row = is_first_line and 1 or 0
  return {
    relative = 'cursor',
    width = string.len(str),
    height = 1,
    col = 0,
    row = row,
    anchor = anchor,
    style = 'minimal'
  }
end

function M.show_signature(args)
  local float = api.nvim_get_var('scnvim_arghints_float')
  -- user opt-out
  if float == 0 then
    print(args)
    return
  end
  -- extract functions args
  local str = args:match('%((.+)%)')
  local bufnr = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(bufnr, 0, -1, true, {str})
  local options = create_float_options(str)
  local winnr = api.nvim_open_win(bufnr, false, options)
  api.nvim_buf_set_var(0, 'scnvim_arghints_float_id', winnr)
  api.nvim_command('autocmd InsertLeave <buffer> ++once lua pcall(vim.api.nvim_win_close, '..winnr..', true)')
end

return M
