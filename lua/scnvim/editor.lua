local sclang = require 'scnvim.sclang'
local path = require 'scnvim.path'
local config = require'scnvim.config'
local api = vim.api
local uv = vim.loop
local M = {}

local flash_ns = api.nvim_create_namespace 'scnvim_flash'

local function get_range(lstart, lend)
  return api.nvim_buf_get_lines(0, lstart - 1, lend, false)
end

local function flash_once(start, finish, delay, options)
  options = vim.tbl_extend('keep', { inclusive = true }, options)
  vim.highlight.range(0, flash_ns, 'SCNvimEval', start, finish, options)
  vim.defer_fn(function()
    api.nvim_buf_clear_namespace(0, flash_ns, 0, -1)
  end, delay)
end

function M.setup()
  M.flash_duration = config.editor.flash.duration
  M.flash_repeats = config.editor.flash.repeats
  M.snippet_format = config.snippet.engine.name

  local hl_group = config.editor.flash.hl_group
  local guifg = config.editor.flash.guifg
  local guibg = config.editor.flash.guibg
  local ctermfg = config.editor.flash.ctermfg
  local ctermbg = config.editor.flash.ctermbg
  local hl_cmd
  if guifg or guibg or ctermfg or ctermbg then
    hl_cmd = string.format(
      'highlight default SCNvimEval guifg=%s guibg=%s ctermfg=%s ctermbg=%s',
      guifg or 'black',
      guibg or 'white',
      ctermfg or 'black',
      ctermbg or 'white'
    )
  else
    hl_cmd = string.format('highlight default link SCNvimEval %s', hl_group)
  end

  -- Create the highlight group
  vim.cmd(hl_cmd)

  local id = api.nvim_create_augroup('scnvim_editor', { clear = true })
  api.nvim_create_autocmd('ColorScheme', {
    group = id,
    desc = 'Reapply custom highlight group',
    pattern = '*',
    command = hl_cmd,
  })
  api.nvim_create_autocmd('VimLeavePre', {
    group = id,
    desc = 'Stop sclang on Nvim exit',
    pattern = '*',
    callback = sclang.stop,
  })
  api.nvim_create_autocmd({ 'BufEnter', 'BufNewFile', 'BufRead' }, {
    group = id,
    desc = 'Set the document path in sclang',
    pattern = { '*.scd', '*.sc', '*.quark' },
    callback = sclang.set_current_path,
  })
  if config.completion and config.completion.signature then
    local signature = require 'scnvim.completion.signature'
    api.nvim_create_autocmd('InsertCharPre', {
      group = id,
      desc = 'Insert mode function signature',
      pattern = { '*.scd', '*.sc', '*.quark' },
      callback = signature.ins_show,
    })
  end
end

--- Flash a text region.
---@param start starting position (tuple {line,col} zero indexed)
---@param finish finish position (tuple {line,col} zero indexed)
---@param options optional parameters:
--- * duration set the flash duration in ms
--- * repeats set the number of repeats
function M.flash(start, finish, options)
  options = options or {}
  local duration = options.duration or M.flash_duration
  local repeats = options.repeats or M.flash_repeats
  if duration == 0 or repeats == 0 then
    return
  end
  local delta = duration / repeats
  flash_once(start, finish, delta, options)
  if repeats > 1 then
    local count = 0
    local timer = uv.new_timer()
    timer:start(
      duration,
      duration,
      vim.schedule_wrap(function()
        flash_once(start, finish, delta, options)
        count = count + 1
        if count == repeats - 1 then
          timer:stop()
        end
      end)
    )
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
    local start = { linenr - 1, 0 }
    local finish = { linenr - 1, #line[1] }
    M.flash(start, finish)
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
    local start = { lstart - 1, 0 }
    local finish = { lend - 1, 0 }
    M.flash(start, finish)
  end
end

--- Send a visual selection.
---@param cb An optional callback function.
function M.send_selection(cb, flash)
  local ret = vim.fn['scnvim#editor#get_visual_selection']()
  M.send_lines(ret.lines, cb)
  if flash then
    local start = { ret.line_start - 1, ret.col_start - 1 }
    local finish = { ret.line_end - 1, ret.col_end - 1 }
    M.flash(start, finish)
  end
end

--- Send a "hard stop" to the interpreter.
function M.hard_stop()
  sclang.send('thisProcess.stop', true)
end

function M.postwin_toggle()
  require('scnvim.postwin').toggle()
end

function M.postwin_clear()
  require('scnvim.postwin').clear()
end

function M.show_signature()
  require('scnvim.completion.signature').show()
end

--- Generate assets. tags syntax etc.
---@param on_done Optional callback that runs when all assets have been created.
function M.generate_assets(on_done)
  assert(sclang.is_running(), '[scnvim] sclang not running')
  local expr = string.format([[SCNvim.generateAssets(\"%s\", \"%s\")]], path.get_cache_dir(), M.snippet_format)
  sclang.eval(expr, on_done)
end

return M
