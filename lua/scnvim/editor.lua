local sclang = require'scnvim.sclang'
local config = require'scnvim.config'.get()
local api = vim.api
local uv = vim.loop
local M = {}

local function get_range(lstart, lend)
  return api.nvim_buf_get_lines(0, lstart - 1, lend, false)
end

local function flash_once(start, finish, delta, options)
  local ns = api.nvim_create_namespace('scnvim_flash')
  local timer = uv.new_timer()
  vim.highlight.range(0, ns, 'SCNvimEval', start, finish, options)
  timer:start(delta, 0, vim.schedule_wrap(function()
    api.nvim_buf_clear_namespace(0, ns, 0, -1)
  end))
end

function M.flash(start, finish, options)
  local duration = config.eval.flash_duration
  local repeats = config.eval.flash_repeats
  if duration == 0 or repeats == 0 then
    return
  end
  if repeats == 1 then
    flash_once(start, finish, duration, options)
    return
  else
    local delta = duration / 2
    local timer = uv.new_timer()
    local count = 0
    flash_once(start, finish, delta, options)
    timer:start(duration, 0, vim.schedule_wrap(function()
      flash_once(start, finish, delta, options)
      count = count + 1
      if count == repeats then
        timer:stop()
      end
    end))
  end
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
function M.send_line(cb, flash)
  local linenr = api.nvim_win_get_cursor(0)[1]
  local line = get_range(linenr, linenr)
  M.send_lines(line, cb)
  if flash then
    local linenr = api.nvim_win_get_cursor(0)[1]
    M.flash({linenr - 1, 0}, {linenr, 0})
  end
end

--- Get the current block of code and send it to sclang.
---@param cb An optional callback function.
function M.send_block(cb, flash)
  local lstart, lend = unpack(vim.fn['scnvim#editor#get_block']())
  if lstart == 0 or lend == 0 then
    M.send_line(cb, flash)
    return
  end
  local lines = get_range(lstart, lend)
  local last_line = lines[#lines]
  local block_end = string.find(last_line, ')')
  lines[#lines] = last_line:sub(1, block_end)
  M.send_lines(lines, cb)
  if flash then
    M.flash({lstart - 1, 0}, {lend, 0})
  end
end

--- Send a visual selection.
---@param cb An optional callback function.
function M.send_selection(cb, flash)
  local ret = vim.fn['scnvim#editor#get_visual_selection']()
  M.send_lines(ret.lines)
  if flash then
    M.flash({ret.line_start - 1, ret.col_start - 1}, {ret.line_end - 1, ret.col_end - 1})
  end
end

--- Send a "hard stop" to the interpreter.
function M.hard_stop(cb)
  if cb then cb() end
  sclang.send('thisProcess.stop', true)
end

return M
