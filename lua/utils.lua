local M = {}

function M.json_encode(data)
  return pcall(vim.fn.json_encode, data)
end

function M.json_decode(data)
  return pcall(vim.fn.json_decode, data)
end

--- Send a command to SuperCollider
function M.send_to_sc(args)
  vim.api.nvim_call_function('scnvim#sclang#send_silent', {args})
end

------------------
--- String
------------------

--- Match an exact occurence of word
-- (replacement for \b word boundary)
function M.str_match_exact(input, word)
  return string.find(input, "%f[%a]" .. word .. "%f[%A]") ~= nil
end

--- Get the system path separator
-- '\' on Windows, '/' on all other systems
M.path_sep = package.config:sub(1,1)

------------------
--- Table
------------------

--- Get table length
function M.tbl_len(T)
  local count = 0
  for _ in pairs(T)
  do
    count = count + 1
  end
  return count
end

return M
