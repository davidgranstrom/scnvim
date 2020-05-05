local M = {}

------------------
--- Compat
------------------

--- vim.fn and vim.call is not present in nvim 0.4.3 or earlier
M.vimcall = vim.api.nvim_call_function
M.vimcmd = vim.api.nvim_command

------------------
--- Various
------------------

function M.json_encode(data)
  -- uncomment for nvim 0.5.x
  -- return pcall(vim.fn.json_encode, data)
  return M.vimcall('json_encode', {data})
end

function M.json_decode(data)
  -- uncomment for nvim 0.5.x
  -- return pcall(vim.fn.json_decode, data)
  return M.vimcall('json_decode', {data})
end

--- Send a command to SuperCollider
function M.send_to_sc(args)
  M.vimcall('scnvim#sclang#send_silent', {args})
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
M.path_sep = vim.loop.os_uname().sysname == 'Windows' and '\\' or '/'

------------------
--- Table
------------------

--- Get table length
function M.tbl_len(T)
  local count = 0
  for _ in pairs(T) do
    count = count + 1
  end
  return count
end

return M
