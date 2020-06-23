--- scnvim help system.
-- @module scnvim/help
-- @author David Granström
-- @license GPLv3

local utils = require('scnvim/utils')
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
  -- uncomment for nvim 0.5.x
  -- local err, result = utils.json_decode(file)
  -- assert(err, result)
  local result = utils.json_decode(file)
  uv.fs_close(fd)
  return result
end

--- Open a vim buffer for uri with an optional pattern.
-- @param uri Help file URI
-- @param (optional) move cursor to line matching regex pattern
function M.open(uri, pattern)
  utils.vimcall('scnvim#help#open', {uri, pattern})
end

--- Find a method
function M.handle_method(name, target_dir)
  -- uncomment for nvim 0.5.x
  -- local path = vim.fn.expand(target_dir)
  local path = utils.vimcall('expand', {target_dir})
  local docmap = get_docmap(path .. utils.path_sep .. 'docmap.json')
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
    -- uncomment for nvim 0.5.x
    -- vim.call('setqflist', results)
    utils.vimcall('setqflist', {results})
    utils.vimcmd('copen')
    utils.vimcmd('nnoremap <silent><buffer> <Enter> :call scnvim#help#open_from_quickfix(line("."))<cr>')
  else
    print('No results for ' .. name)
  end
end

return M
