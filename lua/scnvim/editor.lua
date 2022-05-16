--- Editor
--- Defines functions available for key mappings (scnvim.map.<func_name>).
--- It is also responsible for extracting the text from the buffer that is sent to sclang.
---@module scnvim.editor
local sclang = require 'scnvim.sclang'
local config = require 'scnvim.config'
local postwin = require 'scnvim.postwin'
local commands = require 'scnvim.commands'
local settings = require 'scnvim.settings'
local signature = require 'scnvim.completion.signature'
local api = vim.api
local uv = vim.loop
local M = {}

local flash_ns = api.nvim_create_namespace 'scnvim_flash'

local function get_range(lstart, lend)
  return api.nvim_buf_get_lines(0, lstart - 1, lend, false)
end

local function flash_once(start, finish, delay)
  vim.highlight.range(0, flash_ns, 'SCNvimEval', start, finish, { inclusive = true })
  vim.defer_fn(function()
    api.nvim_buf_clear_namespace(0, flash_ns, 0, -1)
  end, delay)
end

local function apply_keymaps()
  for key, value in pairs(config.mapping) do
    -- handle list of mappings to same key
    if value[1] ~= nil then
      for _, v in ipairs(value) do
        vim.keymap.set(v.modes, key, v.fn, { buffer = true })
      end
    else
      vim.keymap.set(value.modes, key, value.fn, { buffer = true })
    end
  end
end

function M.setup()
  local id = api.nvim_create_augroup('scnvim_editor', { clear = true })
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
  api.nvim_create_autocmd('FileType', {
    group = id,
    desc = 'Apply commands',
    pattern = 'supercollider',
    callback = commands,
  })
  api.nvim_create_autocmd('FileType', {
    group = id,
    desc = 'Apply settings',
    pattern = 'supercollider',
    callback = settings,
  })
  api.nvim_create_autocmd('FileType', {
    group = id,
    pattern = 'supercollider',
    desc = 'Apply mappings',
    callback = apply_keymaps,
  })
  api.nvim_create_autocmd('FileType', {
    group = id,
    desc = 'Apply post window settings',
    pattern = 'scnvim',
    callback = postwin.settings,
  })
  if config.completion.signature.auto then
    api.nvim_create_autocmd('InsertCharPre', {
      group = id,
      desc = 'Insert mode function signature',
      pattern = { '*.scd', '*.sc', '*.quark' },
      callback = signature.ins_show,
    })
  end

  if not config.editor.flash then
    return
  end

  M.flash_duration = config.editor.flash.duration
  M.flash_repeats = config.editor.flash.repeats

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
  api.nvim_create_autocmd('ColorScheme', {
    group = id,
    desc = 'Reapply custom highlight group',
    pattern = '*',
    command = hl_cmd,
  })
end

--- Flash a text region.
---@param start starting position (tuple {line,col} zero indexed)
---@param finish finish position (tuple {line,col} zero indexed)
function M.flash(start, finish)
  if not config.editor.flash then
    return
  end
  local duration = M.flash_duration
  local repeats = M.flash_repeats
  if duration == 0 or repeats == 0 then
    return
  end
  local delta = duration / repeats
  flash_once(start, finish, delta)
  if repeats > 1 then
    local count = 0
    local timer = uv.new_timer()
    timer:start(
      duration,
      duration,
      vim.schedule_wrap(function()
        flash_once(start, finish, delta)
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
---@param flash Highlight the selected text
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
---@param flash Highlight the selected text
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
---@param flash Highlight the selected text
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
  postwin.toggle()
end

function M.postwin_clear()
  postwin.clear()
end

function M.show_signature()
  signature.show()
end

return M
