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

--- Send the current line.
---@param cb An optional callback function.
function M.send_line(cb)
  local line = get_current_line()
  M.send_lines(line, cb)
end

function M.send_block()
  local lstart, lend = get_block()
  local lines = get_range(lstart - 1, lend)
  local last_line = lines[#lines]
  local block_end = string.find(last_line, ')')
  lines[#lines] = last_line:sub(1, block_end)
  M.send_lines(lines)
  -- TODO: flash
end

return M
