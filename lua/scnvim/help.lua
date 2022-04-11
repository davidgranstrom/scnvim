--- scnvim help system.
-- @module scnvim/help
-- @author David Granström
-- @license GPLv3

local utils = require'scnvim.utils'
local sclang

local vimcall = utils.vimcall
local uv = vim.loop
local M = {}

M.docmap = nil

--- Get a JSON document with documentation overview
-- @param target_dir The target help directory
-- @return A JSON string with the document map
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

--- Open a vim buffer for uri with an optional pattern.
-- @param uri Help file URI
-- @param (optional) move cursor to line matching regex pattern
function M.open(uri, pattern)
  vimcall('scnvim#help#open', {uri, pattern})
end

--- Find a method
function M.handle_method(name, target_dir)
  -- uncomment for nvim 0.5.x
  -- local path = vim.fn.expand(target_dir)
  local path = vimcall('expand', target_dir)
  local docmap = M.get_docmap(path .. utils.path_sep .. 'docmap.json')
  local results = {}
  for _, value in pairs(docmap) do
    for _, method in ipairs(value.methods) do
      local match = utils.str_match_exact(method, name)
      if match then
        local destpath = path .. utils.path_sep .. value.path .. '.txt'
        table.insert(results, {
            filename = destpath,
            text = string.format('.%s', name),
            pattern = string.format('^.%s', name),
          })
      end
    end
  end
  if utils.tbl_len(results) then
    vimcall('setqflist', {results})
    vim.api.nvim_command('copen')
    vim.api.nvim_command('nnoremap <silent><buffer> <Enter> :call scnvim#help#open_from_quickfix(line("."))<cr>')
  else
    print('No results for ' .. name)
  end
end

function M.render_all(callback, include_extensions, concurrent_jobs)
  include_extensions = include_extensions or true
  concurrent_jobs = concurrent_jobs or 8
  sclang = sclang or require'scnvim.sclang'
  local settings = vim.fn['scnvim#util#get_user_settings']()
  local render_prg = settings.paths.scdoc_render_prg
  if not render_prg:match('pandoc') then
    print('[scnvim] ERROR: Must use pandoc render program for batch conversion')
    return
  end
  local cmd = string.format('SCNvimDoc.renderAll(%s)', include_extensions)
  sclang.eval(cmd, function()
    sclang.eval('SCDoc.helpTargetDir', function(help_path)
      local sep = utils.path_sep
      local sc_help_dir = help_path .. sep .. 'Classes'

      local threads = {}
      local active_threads = 0
      local is_done = false

      local function schedule(n)
        if is_done then return end
        active_threads = n
        for i = 1, n do
          local thread = threads[i]
          if not thread then
            print('[scnvim] Help file conversion finished.')
            if callback then callback() end
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
            args = {input_path, '--from', 'html', '--to', 'plain', '-o', output_path},
            hide = true,
          }
          local co = coroutine.create(function()
            uv.spawn(render_prg, options, function(code)
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

      print('[scnvim] Converting help files (this might take a while..)')
      schedule(concurrent_jobs)
    end)
  end)
end

return M
