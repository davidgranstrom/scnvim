--- Health
--- Performs health checks.
---@module scnvim.health

local health = require 'health'
local install = require 'scnvim.install'
local sclang = require 'scnvim.sclang'
local config = require 'scnvim.config'
local M = {}

local function check_nvim_version()
  local supported = vim.fn.has 'nvim-0.7' == 1
  if not supported then
    health.report_error 'scnvim needs nvim version 0.7 or higher.'
    health.report_info 'if you are unable to upgrade, use the `0.6-compat` branch'
  else
    health.report_ok 'nvim version is 0.7 or higher.'
  end
end

local function check_classes_installed()
  local class_path = install.check()
  if not class_path then
    health.report_error 'scnvim classes are not installed.'
    health.report_info 'use `ensure_installed = true` in the scnvim setup function'
  else
    health.report_ok('scnvim classes are installed: ' .. class_path)
  end
end

local function check_mappings()
  if vim.tbl_count(config.mapping) == 0 then
    health.report_info 'no mappings defined'
  else
    health.report_ok 'mappings are defined'
  end
end

local function check_documentation()
  local doc = config.documentation
  if not doc then
    health.report_info 'using HelpBrowser for documentation'
  elseif doc.cmd then
    local exe_path = vim.fn.exepath(doc.cmd)
    if exe_path ~= '' then
      health.report_ok(doc.cmd)
    end
    if doc.args then
      local vin = false
      local vout = false
      for _, arg in ipairs(doc.args) do
        if arg == '$1' then
          vin = true
        elseif arg == '$2' then
          vout = true
        end
      end
      if vin and vout then
        health.report_ok(vim.inspect(doc.args))
      elseif vin and not vout then
        health.report_error 'argument list is missing input placeholder ($1)'
      elseif vout and not vin then
        health.report_error 'argument list is missing output placeholder ($2)'
      end
    else
      health.report_error('no argument list found for ' .. doc.cmd)
    end
    if doc.selector then
      health.report_info 'using external selector for methods'
    end
  end
end

local function check_sclang()
  local ok, ret = pcall(sclang.find_sclang_executable)
  if ok then
    health.report_ok('sclang executable: ' .. ret)
  else
    health.report_error(ret)
  end
end

function M.check()
  health.report_start 'scnvim'
  check_nvim_version()
  check_sclang()
  check_classes_installed()
  check_mappings()
  health.report_start 'scnvim documentation'
  check_documentation()
end

return M
