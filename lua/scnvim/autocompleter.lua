--- auto completion
-- @module scnvim
-- @author David Granström
-- @license GPLv3

local introspection = require'scnvim.introspection'

local M = {}
local api = vim.api

M.float_id = 0

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

local function get_hl_ranges(str)
  local ranges = {}
  local offset = 0
  local _, n = str:gsub(',', '')
  local len = string.len(str)
  n = n + 1
  for i = 1, n do
    local start = str:find(',', offset + 1)
    -- last item
    start = start or len
    ranges[i] = {offset, start}
    offset = start
  end
  return ranges, n
end

local arg_count = 1

function M.echo_args()
  local char = api.nvim_get_vvar('char')
  M.highlight_arg()
  if char ~= '(' then
    return
  end
  -- local cursor = vim.api.nvim_win_get_cursor(0)
  -- local row, col = unpack(cursor)
  -- -- local col = cursor[2]
  -- local curline = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
  local pos = api.nvim_win_get_cursor(0)
  local line = api.nvim_get_current_line()
  local line_to_cursor = line:sub(1, pos[2])
  -- Get the start position of the current keyword
  -- local textMatch = vim.fn.match(line_to_cursor, '\\k*$')
  -- local prefix = line_to_cursor:sub(textMatch+1)

  -- TODO: remove items after inserting closing brace
  local items = vim.split(line_to_cursor, '(', true)
  P(items)
  -- utils.send_to_sc(string.format('SCNvim.methodArgs("%s")', items[#items]))
  -- print(row, col, line, line_to_cursor, prefix)
  -- print(vim.inspect())
end

function M.highlight_arg()
  if M.float_id == 0 then
    return
  end
  local char = api.nvim_get_vvar('char')
  -- local 
  if char == ',' then
    arg_count = arg_count + 1
  end
  local start, offset = unpack(M.hl_ranges[arg_count])
  api.nvim_buf_add_highlight(M.hl_bufnr, -1, 'SCNvimCurrentArg', 0, start, offset)
end

function M.show_signature(args)
  local result, float = pcall(api.nvim_get_var, 'scnvim_arghints_float')
  if not result then
    return
  end
  -- user opt-out
  if float == 0 then
    print(args)
    return
  end
  -- make sure only one float is open at a time
  M.try_close_float()
  -- extract functions args
  local str = args:match('%((.+)%)')
  local bufnr = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(bufnr, 0, -1, true, {str})
  local options = create_float_options(str)
  local winnr = api.nvim_open_win(bufnr, false, options)
  M.float_id = winnr
  api.nvim_command([[
    autocmd InsertLeave <buffer> ++once lua require("scnvim.introspection").try_close_float()
  ]])
  -- highlight
  M.current_args = str
  local ranges, count = get_hl_ranges(str)
  M.hl_ranges = ranges
  M.hl_ranges_count = count
  M.hl_bufnr = bufnr
  local start, offset = unpack(ranges[1])
  api.nvim_buf_add_highlight(bufnr, -1, 'SCNvimArgActive', 0, start, offset)
end

function M.try_close_float()
  if M.float_id > 0 then
    vim.api.nvim_win_close(M.float_id, true)
    M.float_id = 0
  end
end

return M
