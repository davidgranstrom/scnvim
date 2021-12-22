--- scnvim help system.
-- @module scnvim/help
-- @author David Granström
-- @license GPLv3

local utils = require'scnvim.utils'

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

return M
