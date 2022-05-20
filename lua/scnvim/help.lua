--- Help system.
--- Convert schelp files into plain text by using an external program (e.g. pandoc) and display them in nvim.
--- Uses the built-in HelpBrowser if no `config.documentation.cmd` is found.
---@module scnvim.help
---@see scnvim.config

local sclang = require 'scnvim.sclang'
local config = require 'scnvim.config'
local _path = require 'scnvim.path'
local utils = require 'scnvim.utils'

local uv = vim.loop
local api = vim.api
local win_id = 0
local M = {}

--- Open a vim buffer for uri with an optional pattern.
---@param uri Help file URI
---@param pattern (optional) move cursor to line matching regex pattern
local function open_help_file(uri, pattern)
  local is_open = vim.fn.win_gotoid(win_id) == 1
  local expr = string.format('edit %s', uri)
  if pattern then
    expr = string.format('edit +/%s %s', pattern, uri)
  end
  if is_open then
    vim.cmd(expr)
  else
    local horizontal = config.documentation.horizontal
    local direction = config.documentation.direction
    if direction == 'top' or direction == 'left' then
      direction = 'leftabove'
    elseif direction == 'right' or direction == 'bot' then
      direction = 'rightbelow'
    else
      error '[scnvim] invalid config.documentation.direction'
    end
    local win_cmd = string.format('%s %s | %s', direction, horizontal and 'split' or 'vsplit', expr)
    vim.cmd(win_cmd)
    win_id = vim.fn.win_getid()
  end
end

--- Get the render arguments with correct input and output file paths.
---@param input_path The input path to use.
---@param output_path The output path to use.
---@return A table with '$1' and '$2' replaced by @p input_path and @p output_path
local function get_render_args(input_path, output_path)
  local args = vim.deepcopy(config.documentation.args)
  for index, str in ipairs(args) do
    if str == '$1' then
      args[index] = str:gsub('$1', input_path)
    end
    if str == '$2' then
      args[index] = str:gsub('$2', output_path)
    end
  end
  return args
end

--- TODO: cache. compare timestamp of help source with rendered .txt
local function render_help_file(subject, on_done)
  local cmd = string.format([[SCNvim.getHelpUri(\"%s\")]], subject)
  sclang.eval(cmd, function(input_path)
    local basename = input_path:gsub('%.html%.scnvim', '')
    local output_path = basename .. '.txt'
    local args = get_render_args(input_path, output_path)
    local options = {
      args = args,
      hide = true,
    }
    local prg = config.documentation.cmd
    uv.spawn(
      prg,
      options,
      vim.schedule_wrap(function(code)
        if code ~= 0 then
          error(string.format('%s error: %d', prg, code))
        end
        local ret = uv.fs_unlink(input_path)
        if not ret then
          print('[scnvim] Could not unlink ' .. input_path)
        end
        on_done(output_path)
      end)
    )
  end)
end

--- Helper function for the default browser implementation
---@param index The item to get from the quickfix list
local function open_from_quickfix(index)
  local list = vim.fn.getqflist()
  local item = list[index]
  if item then
    local uri = vim.fn.bufname(item.bufnr)
    if uv.fs_stat(uri) then
      open_help_file(uri, item.pattern)
    else
      local cmd = string.format([[SCNvim.getFileNameFromUri(\"%s\")]], uri)
      sclang.eval(cmd, function(subject)
        render_help_file(subject, function(result)
          open_help_file(result, item.pattern)
        end)
      end)
    end
  end
end

--- Default selector implementation
---@param err nil if no error otherwise string
---@param results Table with results
local function default_selector(err, results)
  assert(not err, err)
  local id = api.nvim_create_augroup('scnvim_qf_conceal', { clear = true })
  api.nvim_create_autocmd('BufWinEnter', {
    group = id,
    desc = 'Apply quickfix conceal',
    pattern = 'quickfix',
    callback = function()
      vim.cmd [[syntax match SCNvimConcealResults /^.*Help\/\|.txt\||.*|\|/ conceal]]
      vim.opt_local.conceallevel = 2
      vim.opt_local.concealcursor = 'nvic'
    end,
  })
  vim.fn.setqflist(results)
  vim.cmd [[ copen ]]
  vim.keymap.set('n', '<Enter>', function()
    local linenr = api.nvim_win_get_cursor(0)[1]
    open_from_quickfix(linenr)
  end, { buffer = true })
end

--- Get a table with a documentation overview
---@param target_dir The target help directory (SCDoc.helpTargetDir)
---@return A JSON formatted string
function M.get_docmap(target_dir)
  if M.docmap then
    return M.docmap
  end
  local stat = uv.fs_stat(target_dir)
  assert(stat, 'Could not find docmap.json')
  local fd = uv.fs_open(target_dir, 'r', 0)
  local size = stat.size
  local file = uv.fs_read(fd, size, 0)
  local ok, result = pcall(vim.fn.json_decode, file)
  uv.fs_close(fd)
  if not ok then
    error(result)
  end
  return result
end

--- Find help files for a method
---@param name Method name to find.
---@param target_dir The help target dir (SCDoc.helpTargetDir)
---@return A table with method entries that is suitable for the quickfix list.
function M.find_methods(name, target_dir)
  local path = vim.fn.expand(target_dir)
  local docmap = M.get_docmap(_path.concat(path, 'docmap.json'))
  local results = {}
  for _, value in pairs(docmap) do
    for _, method in ipairs(value.methods) do
      local match = utils.str_match_exact(method, name)
      if match then
        local destpath = path .. _path.sep .. value.path .. '.txt'
        table.insert(results, {
          filename = destpath,
          text = string.format('.%s', name),
          pattern = string.format('^\\.%s', name),
        })
      end
    end
  end
  return results
end

--- Prepare a help file.
---@param subject The help subject (SinOsc, tanh, etc.)
function M.prepare_help_for(subject)
  if not sclang.is_running() then
    print '[scnvim] sclang not running'
    return
  end

  if not config.documentation.cmd then
    local cmd = string.format([[HelpBrowser.openHelpFor(\"%s\")]], subject)
    sclang.send(cmd, true)
    return
  end

  local is_class = subject:sub(1, 1):match '%u'
  if is_class then
    render_help_file(subject, function(result)
      open_help_file(result)
    end)
  else
    sclang.eval('SCDoc.helpTargetDir', function(dir)
      local results = M.find_methods(subject, dir)
      local err = nil
      if #results == 0 then
        err = 'No results for ' .. tostring(subject)
      end
      local selector = config.documentation.selector
      if selector then
        selector(err, results)
      else
        default_selector(err, results)
      end
    end)
  end
end

--- Render all help files.
---@param callback Run this callback on completion.
---@param include_extensions Include SCClassLibrary extensions.
---@param concurrent_jobs Number of parallel jobs (default: 8)
function M.render_all(callback, include_extensions, concurrent_jobs)
  include_extensions = include_extensions or true
  concurrent_jobs = concurrent_jobs or 8
  if not config.documentation.cmd then
    error '[scnvim] `config.documentation.cmd` must be defined'
  end
  local cmd = string.format('SCNvimDoc.renderAll(%s)', include_extensions)
  sclang.eval(cmd, function()
    sclang.eval('SCDoc.helpTargetDir', function(help_path)
      local sep = _path.sep
      local sc_help_dir = help_path .. sep .. 'Classes'

      local threads = {}
      local active_threads = 0
      local is_done = false

      local function schedule(n)
        if is_done then
          return
        end
        active_threads = n
        for i = 1, n do
          local thread = threads[i]
          if not thread then
            print '[scnvim] Help file conversion finished.'
            if callback then
              callback()
            end
            break
          end
          coroutine.resume(thread)
          table.remove(threads, i)
        end
      end

      local function on_done(exit_code, filename)
        if exit_code ~= 0 then
          local err = string.format('[scnvim] ERROR: Could not convert help file %s (code: %d)', filename, exit_code)
          print(err)
        end
        active_threads = active_threads - 1
        local last_run = active_threads > #threads
        if active_threads == 0 or last_run and not is_done then
          local num_jobs = concurrent_jobs
          if last_run then
            num_jobs = #threads
            is_done = true
          end
          schedule(num_jobs)
        end
      end

      local handle = assert(uv.fs_scandir(sc_help_dir), 'Could not open SuperCollider help directory.')
      repeat
        local filename, type = uv.fs_scandir_next(handle)
        if type == 'file' and vim.endswith(filename, 'scnvim') then
          local basename = filename:gsub('%.html%.scnvim', '')
          local input_path = sc_help_dir .. sep .. filename
          local output_path = sc_help_dir .. sep .. basename .. '.txt'
          local options = {
            args = get_render_args(input_path, output_path),
            hide = true,
          }
          local co = coroutine.create(function()
            uv.spawn(config.documentation.cmd, options, function(code)
              local ret = uv.fs_unlink(input_path)
              if not ret then
                print('[scnvim] ERROR: Could not unlink ' .. input_path)
              end
              on_done(code, input_path)
            end)
          end)
          threads[#threads + 1] = co
        end
      until not filename

      print '[scnvim] Converting help files (this might take a while..)'
      schedule(concurrent_jobs)
    end)
  end)
end

return M
