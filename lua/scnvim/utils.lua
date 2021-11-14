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

--- Get the content of the generated snippets file.
-- @returns The file contents. A lua table or a string depending on `scnvim_snippet_format`.
function M.get_snippets()
  local root_dir = M.get_scnvim_root_dir()
  local format = M.get_var('scnvim_snippet_format') or 'snippets.nvim'
  local snippet_dir = root_dir .. M.path_sep .. 'scnvim-data'
  if format == 'snippets.nvim' or format == 'luasnip' then
    local filename = snippet_dir .. M.path_sep .. 'scnvim_snippets.lua'
    local ok, file = pcall(loadfile(filename))
    if ok then
      return file
    else
      print('File does not exist:' .. filename)
      print('Call :SCNvimTags to generate snippets.')
    end
  elseif format == 'ultisnips' then
    local filename = snippet_dir .. M.path_sep .. 'supercollider.snippets'
    local file = assert(io.open(filename, 'rb'), 'File does not exists: ' .. filename)
    local content = file:read('*all')
    file:close()
    return content
  end
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

------------------
--- Path
------------------

function M.get_system()
  local sysname = vim.loop.os_uname().sysname
  if sysname:match('Windows') then
    return 'windows'
  elseif sysname:match('Darwin') then
    return 'macos'
  else
    return 'linux'
  end
end

--- Get the system path separator
M.is_windows = M.get_system() == 'windows'
M.path_sep = M.is_windows and '\\' or '/'

--- Get the root directory of the plugin.
function M.get_scnvim_root_dir()
  local package_path = debug.getinfo(1).source:gsub('@', '')
  --vim uses inconsistent path separators on Windows
  --safer to change all to Unix style first
  if M.is_windows then
    package_path = package_path:gsub('@', ''):gsub("\\", "/")
  end
  package_path = vim.split(package_path, '/', {plain=false, trimempty=true})
  -- find index of plugin root dir
  local index = 1
  local found = false
  for i, v in ipairs(package_path) do
    if v == 'scnvim' then
      found = true
      index = i
      break
    end
  end
  if not found then
    error('[scnvim] could not find plugin root dir')
  end
  local path = {}
  for i, v in ipairs(package_path) do
    if i > index then
      break
    end
    path[i] = v
  end
  local dir = ''
  if not M.is_windows then
    dir = '/'
  end
  for _, v in ipairs(path) do
    dir = dir .. v .. M.path_sep
  end
  assert(#dir > 1, '[scnvim] Could not get scnvim root path')
  dir = dir:sub(1, -2) -- delete trailing slash
  return dir
end

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

------------------
--- Output
------------------

local function format_message(msg, level)
  if not level then
    level = ']'
  else
    level = level .. ']'
  end
  return string.format('[scnvim %s %s', level, msg or '(nil)')
end

function M.print_info(msg)
  print(format_message(msg, 'INFO'))
end

function M.print_err(msg)
  print(format_message(msg, 'ERROR'))
end

function M.print_warn(msg)
  print(format_message(msg, 'WARNING'))
end

return M
