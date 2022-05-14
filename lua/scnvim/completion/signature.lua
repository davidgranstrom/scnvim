--- Signature help.
--- @module scnvim.completion.signature
--- TODO: refactor to use vim.diagnostic?

local sclang = require 'scnvim.sclang'
local config = require 'scnvim.config'
local api = vim.api
local lsp_util = vim.lsp.util

local M = {}

local function get_method_signature(object, cb)
  local cmd = string.format([[SCNvim.methodArgs(\"%s\")]], object)
  sclang.eval(cmd, cb)
end

local function is_outside_of_statment(line, line_to_cursor)
  local line_endswith = vim.endswith(line, ')') or vim.endswith(line, ';')
  local curs_line_endswith = vim.endswith(line_to_cursor, ')') or vim.endswith(line_to_cursor, ';')
  return line_endswith and curs_line_endswith
end

local function extract_objects_helper(str)
  local objects = vim.split(str, '(', true)
  -- split arguments
  objects = vim.tbl_map(function(s)
    return vim.split(s, ',', true)
  end, objects)
  objects = vim.tbl_flatten(objects)
  objects = vim.tbl_map(function(s)
    -- filter out empty strings (nvim 0.5.1 compatability fix, use
    -- vim.split(..., {trimempty = true}) for nvim 0.6)
    if s == '' then
      return nil
    end
    -- filter out strings
    s = vim.trim(s)
    if s:sub(1, 1) == '"' then
      return nil
    end
    -- filter out trailing parens (from insert mode)
    s = s:gsub('%)', '')
    local obj_start = s:find '%u'
    return obj_start and s:sub(obj_start, -1)
  end, objects)
  objects = vim.tbl_filter(function(s)
    return s ~= nil
  end, objects)
  local len = #objects
  if len > 0 then
    return vim.trim(objects[len])
  end
  return ''
end

local function get_line_info()
  local _, col = unpack(api.nvim_win_get_cursor(0))
  local line = api.nvim_get_current_line()
  local line_to_cursor = line:sub(1, col + 1)
  return line, line_to_cursor
end

local function extract_object()
  local line, line_to_cursor = get_line_info()
  -- outside of any statement
  if is_outside_of_statment(line, line_to_cursor) then
    return ''
  end
  -- inside a multiline call
  if not line_to_cursor:find '%(' then
    local lnum = vim.fn.searchpair('(', '', ')', 'bnzW')
    if lnum > 0 then
      local ok, res = pcall(api.nvim_buf_get_lines, 0, lnum - 1, lnum, true)
      if ok then
        line_to_cursor = res[1]
      end
    end
  end
  -- ignore completed calls
  local ignore = line_to_cursor:match '%((.*)%)'
  if ignore then
    ignore = ignore .. ')'
    line_to_cursor = line_to_cursor:gsub(vim.pesc(ignore), '')
  end
  line_to_cursor = line_to_cursor:match '.*%('
  return extract_objects_helper(line_to_cursor)
end

local function ins_extract_object()
  local _, line_to_cursor = get_line_info()
  return extract_objects_helper(line_to_cursor)
end

local function show_signature(object)
  if object ~= '' then
    local float = config.completion.signature.float
    local float_conf = config.completion.signature.config
    get_method_signature(object, function(res)
      local signature = res:match '%((.+)%)'
      if signature then
        if float then
          lsp_util.open_floating_preview({ signature }, 'supercollider', float_conf)
        else
          print(signature)
        end
      end
    end)
  end
end

--- Show signature from normal mode
function M.show()
  local ok, object = pcall(extract_object)
  if ok then
    pcall(show_signature, object)
  end
end

--- Show signature from insert mode
function M.ins_show()
  if vim.v.char == '(' then
    local ok, object = pcall(ins_extract_object)
    if ok then
      pcall(show_signature, object)
    end
  end
end

return M
