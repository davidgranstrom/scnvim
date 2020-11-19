--- Utility functions.
-- @module scnvim/utils
-- @author David Granström
-- @license GPLv3

local M = {}

------------------
--- Compat
------------------

--- vim.call is not present in nvim 0.4.4 or earlier
function M.vimcall(fn, args)
  if args and type(args) ~= 'table' then
    args = {args}
  end
  args = args or {}
  return vim.api.nvim_call_function(fn, args)
end

function M.get_var(name)
  local result, value = pcall(vim.api.nvim_get_var, name)
  if result then
    return value
  end
  return nil
end

------------------
--- Various
------------------

function M.json_encode(data)
  -- uncomment for nvim 0.5.x
  -- return pcall(vim.fn.json_encode, data)
  return M.vimcall('json_encode', data)
end

function M.json_decode(data)
  -- uncomment for nvim 0.5.x
  -- return pcall(vim.fn.json_decode, data)
  return M.vimcall('json_decode', data)
end

------------------
--- String
------------------

--- Match an exact occurence of word
-- (replacement for \b word boundary)
function M.str_match_exact(input, word)
  return string.find(input, "%f[%a]" .. word .. "%f[%A]") ~= nil
end

-- modified version of vim.endswith (runtime/lua/vim/shared.lua)
-- needed for nvim versions < 0.5
function M.str_endswidth(s, suffix)
  return #suffix == 0 or s:sub(-#suffix) == suffix
end

--- Get the system path separator
M.is_windows = vim.loop.os_uname().sysname:match('Windows')
M.path_sep = M.is_windows and '\\' or '/'

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
