--- Method signature help.
-- @module scnvim.method-signature
-- @author David Granström
-- @license GPLv3

local sclang = require'scnvim.sclang'
local api = vim.api
local lsp_util = vim.lsp.util

local M = {}

local function get_method_signature(object, cb)
  local cmd = string.format('SCNvim.methodArgs(\\"%s\\")', object);
  sclang.eval(cmd, cb)
end

local function is_outside_of_statment(line, line_to_cursor)
  local line_endswith = vim.endswith(line, ')') or vim.endswith(line, ';')
  local curs_line_endswith = vim.endswith(line_to_cursor, ')') or vim.endswith(line_to_cursor, ';')
  return line_endswith and curs_line_endswith
end

local function extract_objects()
  local _, col = unpack(api.nvim_win_get_cursor(0))
  local line = api.nvim_get_current_line()
  local line_to_cursor = line:sub(1, col + 1)
  -- outside
  if is_outside_of_statment(line, line_to_cursor)
    then return ''
  end
  -- TODO(david): refactor into two separate functions insert/normal
  -- if not vim.endswith(line_to_cursor, '(') then
  --   line_to_cursor = line_to_cursor .. '('
  -- end
  -- filter out closed method calls
  local ignore = line_to_cursor:match'%((.*)%)'
  if ignore then
    ignore = ignore .. ')'
    line_to_cursor = line_to_cursor:gsub(vim.pesc(ignore), '')
  end
  line_to_cursor = line_to_cursor:match'.*%('
  local objects = vim.split(line_to_cursor, '(', {plain = true, trimempty = true})
  -- split arguments
  objects = vim.tbl_map(function(s)
    return vim.split(s, ',', {plain = true, trimempty = true})
  end, objects)
  objects = vim.tbl_flatten(objects)
  objects = vim.tbl_map(function(s)
    -- filter out strings
    s = vim.trim(s)
    if s:sub(1, 1) == '"' then
      return nil
    end
    local obj_start = s:find('%u')
    return obj_start and s:sub(obj_start, -1)
  end, objects)
  objects = vim.tbl_filter(function(s) return s ~= nil end, objects)
  local len = #objects
  if len > 0 then
    return vim.trim(objects[len])
  end
  return ''
end

function M.show_fn_signature()
  local object = extract_objects()
  if object ~= '' then
    get_method_signature(object, function(res)
      object = object:match('%((.+)%)')
      if not object then
        return
      end
      lsp_util.open_floating_preview({object}, "supercollider", {})
    end)
  end
end

function M.show()
  M.show_fn_signature()
end

function M.ins_show()
  if vim.v.char == '(' then
    M.show_fn_signature()
  end
end

return M
