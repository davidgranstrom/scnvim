--- scnvim help system
-- @module help

local utils = require('utils')
local uv = vim.loop
local M = {}

M.docmap = nil

--- Get json document of all classes
local function get_docmap(target_dir)
  if M.docmap then
    return M.docmap
  end
  local stat = uv.fs_stat(target_dir)
  assert(stat, 'Could not find docmap.json')
  local fd = uv.fs_open(target_dir, 'r', 0)
  local size = stat.size
  local file = uv.fs_read(fd, size, 0)
  local err, result = utils.json_decode(file)
  assert(err, result)
  uv.fs_close(fd)
  return result
end

--- Open a vim buffer for uri with an optional pattern.
-- @param uri Help file URI
-- @param (optional) move cursor to line matching regex pattern
function M.open(uri, pattern)
  vim.call('scnvim#help#open', uri, pattern)
end

--- Find a method
function M.handle_method(name, target_dir)
  local path = vim.fn.expand(target_dir)
  local docmap = get_docmap(path .. utils.path_sep .. 'docmap.json')
  local results = {}
  for key, value in pairs(docmap) do
    for i, method in ipairs(value.methods) do
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
    vim.call('setqflist', results)
    vim.api.nvim_command('copen')
    vim.api.nvim_command('nnoremap <silent><buffer> <Enter> :call scnvim#help#open_from_quickfix(line("."))<cr>')
  else
    print('No results for ' .. name)
  end
end

return M
