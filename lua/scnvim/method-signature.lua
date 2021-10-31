--- Method signature help.
-- @module scnvim.method-signature
-- @author David Granström
-- @license GPLv3

local sclang = require'scnvim.sclang'
local api = vim.api

local M = {}

M.win_id = 0

local function open_float_win(object)
  M.try_close_float()
  local str = object:match('%((.+)%)')
  if not str then
    return
  end
  local is_first_line = api.nvim_win_get_cursor(0)[1] == 1
  local options = {
    relative = 'cursor',
    width = string.len(str),
    height = 1,
    col = 0,
    row = is_first_line and 1 or 0,
    anchor = is_first_line and 'NW' or 'SW',
    style = 'minimal'
  }
  local bufnr = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(bufnr, 0, -1, true, {str})
  local handle = api.nvim_open_win(bufnr, false, options)
  M.win_id = handle
end

local function get_method_signature(object, cb)
  local cmd = string.format('SCNvim.methodArgs(\\"%s\\")', object);
  sclang.eval(cmd, cb)
end

local function extract_objects()
  local _, col = unpack(api.nvim_win_get_cursor(0))
  local line = api.nvim_get_current_line()
  local line_to_cursor = line:sub(1, col + 1)

  local ignore = line_to_cursor:match'%((.*)%)'
  if ignore then
    ignore = ignore .. ')'
    line_to_cursor = line_to_cursor:gsub(vim.pesc(ignore), '')
  end

  local objects = vim.split(line_to_cursor, '(', {plain = true, trimempty = true})

  objects = vim.tbl_map(function(s)
    local obj_start = s:find('%u')
    return obj_start and s:sub(obj_start, -1)
  end, objects)

  objects = vim.tbl_filter(function(s)
    return s:find'%.'
  end, objects)

  local len = #objects
  if len > 0 then
    return vim.trim(objects[len])
  end
  return ''
end

function M.show_fn_signature()
  local object = extract_objects()
  if object ~= '' then
    get_method_signature(object, function(res)
      open_float_win(res)
    end)
  end
end

function M.show()
  M.show_fn_signature()
  vim.cmd [[
    autocmd CursorMoved <buffer> ++once lua require'scnvim.method-signature'.try_close_float()
  ]]
end

function M.ins_show()
  if vim.v.char == '(' then
    M.show_fn_signature()
    vim.cmd [[
      autocmd InsertLeave <buffer> ++once lua require'scnvim.method-signature'.try_close_float()
    ]]
  end
end

function M.try_close_float()
  if M.win_id > 0 then
    api.nvim_win_close(M.win_id, true)
    M.win_id = 0
  end
end

return M
