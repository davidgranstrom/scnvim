local utils = require('utils')
local M = {}
local uv = vim.loop

--- Open a vim buffer for uri with an optional pattern.
--- @param uri Help file URI
--- @param pattern Regex pattern
function M.open(uri, pattern)
  vim.call('scnvim#help#open', uri, pattern)
end

local function get_docmap(target_dir)
  local stat = uv.fs_stat(target_dir)
  local fd = uv.fs_open(target_dir, 'r', 0)
  local size = stat.size
  local docmap = uv.fs_read(fd, size, 0)
  uv.fs_close(fd)
  return docmap
end

function M.handle_method(name, target_dir)
  local data = get_docmap(target_dir)
  local err, result = utils.json_decode(data)
  assert(err, result)
  print(vim.inspect(result))
end

return M
