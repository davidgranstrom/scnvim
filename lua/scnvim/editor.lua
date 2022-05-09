local sclang = require'scnvim.sclang'
local api = vim.api
local M = {}

local function get_range(lstart, lend)
  return api.nvim_buf_get_lines(0, lstart - 1, lend, false)
end

local function get_current_line()
  local linenr = api.nvim_win_get_cursor(0)[1]
  return get_range(linenr, linenr)
end

--- Send lines.
---@param lines Table with the lines to send.
---@param callback Optional callback function.
--- Will receive the input lines as a table and must return a table.
--- Can be used for text substitution.
function M.send_lines(lines, callback)
  if callback then
    lines = callback(lines)
  end
  sclang.send(table.concat(lines, '\n'))
end

--- Get the current line and send it to sclang.
---@param cb An optional callback function.
function M.send_line(cb)
  local line = get_current_line()
  M.send_lines(line, cb)
end

--- Get the current block of code and send it to sclang.
---@param cb An optional callback function.
function M.send_block(cb)
  local lstart, lend = unpack(vim.fn['scnvim#editor#get_block']())
  if lstart == 0 or lend == 0 then
    M.send_line(cb)
    return
  end
  local lines = get_range(lstart, lend)
  local last_line = lines[#lines]
  local block_end = string.find(last_line, ')')
  lines[#lines] = last_line:sub(1, block_end)
  M.send_lines(lines, cb)
end

--- Send a visual selection.
---@param cb An optional callback function.
function M.send_selection(cb)
  local ret = vim.fn['scnvim#editor#get_visual_selection']()
  M.send_lines(ret.lines)
end

--- Send a "hard stop" to the interpreter.
function M.hard_stop(cb)
  if cb then cb() end
  sclang.send('thisProcess.stop', true)
end

return M
