--- Perform health checks.
---@module scnvim.health
---@usage :checkhealth scnvim
---@local

local health = vim.health or require 'health'
local install = require 'scnvim.install'
local sclang = require 'scnvim.sclang'
local config = require 'scnvim.config'
local extensions = require 'scnvim.extensions'

local M = {}

local function check_nvim_version()
  local supported = vim.fn.has 'nvim-0.7' == 1
  if not supported then
    health.error 'scnvim needs nvim version 0.7 or higher.'
    health.info 'if you are unable to upgrade, use the `0.6-compat` branch'
  else
    local v = vim.version()
    health.ok(string.format('nvim version %d.%d.%d', v.major, v.minor, v.patch))
  end
end

local function check_classes_installed()
  local class_path = install.check()
  if not class_path then
    health.error 'scnvim classes are not installed.'
    health.info 'use `ensure_installed = true` in the scnvim setup function'
  else
    health.ok('scnvim classes are installed: ' .. class_path)
  end
end

local function check_keymaps()
  if vim.tbl_count(config.keymaps) == 0 then
    health.info 'no keymaps defined'
  else
    health.ok 'keymaps are defined'
  end
end

local function check_documentation()
  local doc = config.documentation
  if not doc.cmd then
    health.info 'using HelpBrowser for documentation'
  else
    local exe_path = vim.fn.exepath(doc.cmd)
    if exe_path ~= '' then
      health.ok(doc.cmd)
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
        health.ok(vim.inspect(doc.args))
      elseif vout and not vin then
        health.error 'argument list is missing input placeholder ($1)'
      elseif vin and not vout then
        health.error 'argument list is missing output placeholder ($2)'
      else
        health.error 'argument list is missing both input and output placeholders ($1/$2)'
      end
    end
    if doc.on_open then
      health.info 'using external function for on_open'
    end
    if doc.on_select then
      health.info 'using external function for on_select'
    end
  end
end

local function check_sclang()
  local ok, ret = pcall(sclang.find_sclang_executable)
  if ok then
    health.ok('sclang executable: ' .. ret)
  else
    health.error(ret)
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
      health.start(string.format('extension: "%s"', name))
      health_check()
      local link = extensions._linked[name]
      if link then
        health.ok(string.format('installed classes "%s"', link))
      else
        health.ok 'no classes to install'
      end
    else
      health.ok(string.format('No health check for "%s"', name))
    end
  end
end

function M.check()
  health.start 'scnvim'
  check_nvim_version()
  check_sclang()
  check_classes_installed()
  check_keymaps()
  health.start 'scnvim documentation'
  check_documentation()
  health.start 'scnvim extensions'
  check_extensions()
end

return M
