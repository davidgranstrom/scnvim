--- Perform health checks.
---@module scnvim.health
---@usage :checkhealth scnvim
---@local

local health = require 'health'
local install = require 'scnvim.install'
local sclang = require 'scnvim.sclang'
local config = require 'scnvim.config'
local extensions = require 'scnvim.extensions'

local M = {}

local function check_nvim_version()
  local supported = vim.fn.has 'nvim-0.7' == 1
  if not supported then
    health.report_error 'scnvim needs nvim version 0.7 or higher.'
    health.report_info 'if you are unable to upgrade, use the `0.6-compat` branch'
  else
    local v = vim.version()
    health.report_ok(string.format('nvim version %d.%d.%d', v.major, v.minor, v.patch))
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
  if not doc.cmd then
    health.report_info 'using HelpBrowser for documentation'
  else
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
      elseif vout and not vin then
        health.report_error 'argument list is missing input placeholder ($1)'
      elseif vin and not vout then
        health.report_error 'argument list is missing output placeholder ($2)'
      else
        health.report_error 'argument list is missing both input and output placeholders ($1/$2)'
      end
    end
    if doc.on_open then
      health.report_info 'using external function for on_open'
    end
    if doc.on_select then
      health.report_info 'using external function for on_select'
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

local function check_extensions()
  local installed = {}
  for name, _ in pairs(extensions.manager) do
    installed[#installed + 1] = name
  end
  table.sort(installed)
  for _, name in ipairs(installed) do
    local health_check = extensions._health[name]
    if health_check then
      health.report_start(string.format('extension: "%s"', name))
      health_check()
    else
      health.report_ok(string.format('No health check for "%s"', name))
    end
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
  health.report_start 'scnvim extensions'
  check_extensions()
end

return M
