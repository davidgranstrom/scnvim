--- Connects nvim and the sclang process.
--- Applies autocommands and forwards text to be evaluated to the sclang process.
---@module scnvim.editor

local sclang = require 'scnvim.sclang'
local config = require 'scnvim.config'
local commands = require 'scnvim.commands'
local settings = require 'scnvim.settings'
local action = require 'scnvim.action'
local api = vim.api
local uv = vim.loop
local M = {}

--- Actions
---@section actions

--- Action that runs to highlight buffer content sent to sclang.
--- The default function depends on the user config.
---@param start Start range ({row, col} zero indexed)
---@param finish End range ({row, col} zero indexed)
M.on_highlight = action.new(function(start, finish) end) -- luacheck: ignore

--- Action that runs when buffer content is sent to sclang.
--- The default is to send the content as a string to sclang.
---@param lines Table with the lines.
---@param callback Optional callback function.
M.on_send = action.new(function(lines, callback)
  if callback then
    lines = callback(lines)
  end
  sclang.send(table.concat(lines, '\n'))
end)

--- Functions
---@section functions

--- Get a range of lines.
---@param lstart Start index.
---@param lend  End index.
---@return A table with strings.
local function get_range(lstart, lend)
  return api.nvim_buf_get_lines(0, lstart - 1, lend, false)
end

--- Flash once.
---@param start Start range.
---@param finish End range.
---@param delay How long to highlight the text.
local function flash_once(start, finish, delay)
  local ns = api.nvim_create_namespace 'scnvim_flash'
  vim.highlight.range(0, ns, 'SCNvimEval', start, finish, { inclusive = true })
  vim.defer_fn(function()
    api.nvim_buf_clear_namespace(0, ns, 0, -1)
  end, delay)
end

--- Apply a flashing effect to a text region.
---@param start starting position (tuple {line,col} zero indexed)
---@param finish finish position (tuple {line,col} zero indexed)
---@local
local function flash_region(start, finish)
  local duration = config.editor.highlight.flash.duration
  local repeats = config.editor.highlight.flash.repeats
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

--- Apply a fading effect to a text region.
---@param start starting position (tuple {line,col} zero indexed)
---@param finish finish position (tuple {line,col} zero indexed)
---@local
local function fade_region(start, finish)
  local lstart = start[1]
  local lend = finish[1]
  local width = 1
  if vim.fn.mode() == 'v' then
    width = finish[2]
  else
    local lines = get_range(lstart + 1, lend + 1)
    for _, line in ipairs(lines) do
      if #line > width then
        width = #line
      end
    end
  end
  local curwin = api.nvim_get_current_win()
  local buf = M.fade_buf or api.nvim_create_buf(false, true)
  local options = {
    relative = 'win',
    win = curwin,
    width = width > 0 and width or 1,
    height = lend - lstart + 1,
    bufpos = { lstart - 1, 0 },
    focusable = false,
    style = 'minimal',
    border = 'none',
    anchor = lstart > 0 and 'NW' or 'SE',
  }
  local id = api.nvim_open_win(buf, false, options)
  api.nvim_win_set_option(id, 'winhl', 'Normal:' .. 'SCNvimEval')
  local timer = uv.new_timer()
  local rate = 50
  local accum = 0
  local duration = math.floor(config.editor.highlight.fade.duration)
  timer:start(
    0,
    rate,
    vim.schedule_wrap(function()
      accum = accum + rate
      if accum > duration then
        accum = duration
      end
      local value = math.pow(accum / duration, 2.5)
      api.nvim_win_set_option(id, 'winblend', math.floor(100 * value))
      if accum >= duration then
        timer:stop()
        api.nvim_win_close(id, true)
      end
    end)
  )
  M.fade_buf = buf
end

--- Applies keymaps from the user configuration.
local function apply_keymaps(mappings)
  for key, value in pairs(mappings) do
    -- handle list of keymaps to same key
    if value[1] ~= nil then
      for _, v in ipairs(value) do
        local opts = {
          buffer = true,
          desc = v.options.desc,
        }
        vim.keymap.set(v.modes, key, v.fn, opts)
      end
    else
      local opts = {
        buffer = true,
        desc = value.options.desc,
      }
      vim.keymap.set(value.modes, key, value.fn, opts)
    end
  end
end

--- Create a highlight command
---@return The highlight ex command string
---@local
local function create_hl_group()
  local color = config.editor.highlight.color
  if type(color) == 'string' then
    color = string.format('highlight default link SCNvimEval %s', color)
  elseif type(color) == 'table' then
    color = string.format(
      'highlight default SCNvimEval guifg=%s guibg=%s ctermfg=%s ctermbg=%s',
      color.guifg or 'black',
      color.guibg or 'white',
      color.ctermfg or 'black',
      color.ctermbg or 'white'
    )
  end
  vim.cmd(color)
  return color
end

--- Create autocommands
local function create_autocmds()
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
    desc = 'Apply keymaps',
    callback = function()
      apply_keymaps(config.keymaps)
    end,
  })
  local doc_maps = config.documentation.keymaps
  if doc_maps then
    api.nvim_create_autocmd('FileType', {
      group = id,
      pattern = 'help.supercollider',
      desc = 'Apply keymaps for the help window',
      callback = function()
        doc_maps = type(doc_maps) == 'table' and doc_maps or config.keymaps
        apply_keymaps(doc_maps)
      end,
    })
  end
  local postwin_maps = config.postwin.keymaps
  if postwin_maps then
    api.nvim_create_autocmd('FileType', {
      group = id,
      desc = 'Apply keymaps for the post window',
      pattern = 'scnvim',
      callback = function()
        postwin_maps = type(postwin_maps) == 'table' and postwin_maps or config.keymaps
        apply_keymaps(postwin_maps)
      end,
    })
  end
  if config.editor.signature.auto then
    api.nvim_create_autocmd('InsertCharPre', {
      group = id,
      desc = 'Insert mode function signature',
      pattern = { '*.scd', '*.sc', '*.quark' },
      callback = require('scnvim.signature').ins_show,
    })
  end
  if config.editor.force_ft_supercollider then
    api.nvim_create_autocmd({
      'BufNewFile',
      'BufRead',
      'BufEnter',
      'BufWinEnter',
    }, {
      group = id,
      desc = 'Set *.sc to filetype supercollider',
      pattern = '*.sc',
      command = 'set filetype=supercollider',
    })
  end
  local hl_cmd = create_hl_group()
  api.nvim_create_autocmd('ColorScheme', {
    group = id,
    desc = 'Reapply custom highlight group',
    pattern = '*',
    command = hl_cmd,
  })
end

--- Setup function.
---
--- Called from the main module.
---@see scnvim
---@local
function M.setup()
  create_autocmds()
  local highlight = config.editor.highlight
  if highlight.type == 'flash' then
    M.on_highlight:replace(flash_region)
  elseif highlight.type == 'fade' then
    M.on_highlight:replace(fade_region)
  else -- none
    M.on_highlight:replace(function() end)
  end
end

--- Get the current line and send it to sclang.
---@param cb An optional callback function.
---@param flash Highlight the selected text
function M.send_line(cb, flash)
  flash = flash == nil and true or flash
  local linenr = api.nvim_win_get_cursor(0)[1]
  local line = get_range(linenr, linenr)
  M.on_send(line, cb)
  if flash then
    local start = { linenr - 1, 0 }
    local finish = { linenr - 1, #line[1] }
    M.on_highlight(start, finish)
  end
end

--- Get the current block of code and send it to sclang.
---@param cb An optional callback function.
---@param flash Highlight the selected text
function M.send_block(cb, flash)
  flash = flash == nil and true or flash
  local lstart, lend = unpack(vim.fn['scnvim#editor#get_block']())
  if lstart == 0 or lend == 0 then
    M.send_line(cb, flash)
    return
  end
  local lines = get_range(lstart, lend)
  local last_line = lines[#lines]
  local block_end = string.find(last_line, ')')
  lines[#lines] = last_line:sub(1, block_end)
  M.on_send(lines, cb)
  if flash then
    local start = { lstart - 1, 0 }
    local finish = { lend - 1, 0 }
    M.on_highlight(start, finish)
  end
end

--- Send a visual selection.
---@param cb An optional callback function.
---@param flash Highlight the selected text
function M.send_selection(cb, flash)
  flash = flash == nil and true or flash
  local ret = vim.fn['scnvim#editor#get_visual_selection']()
  M.on_send(ret.lines, cb)
  if flash then
    local start = { ret.line_start - 1, ret.col_start - 1 }
    local finish = { ret.line_end - 1, ret.col_end - 1 }
    M.on_highlight(start, finish)
  end
end

return M
