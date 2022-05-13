local health = require 'health'
local install = require 'scnvim.install'
local M = {}

local function check_nvim_version()
  local supported = vim.fn.has 'nvim-0.7' == 1
  if not supported then
    health.report_error 'scnvim needs nvim version 0.7 or higher.'
    health.report_info 'if you are unable to upgrade, use the `0.6-compat branch`'
  else
    health.report_ok 'nvim version is 0.7 or higher.'
  end
end

local function check_classes_installed()
  local class_path = install.check()
  if not class_path then
    health.report_error 'scnvim classes are not installed.'
    health.report_info 'use `ensure_install = true` in the scnvim setup function'
  else
    health.report_ok('scnvim classes are installed: ' .. class_path)
  end
end

--- TODO: check sclang binary
--- TODO: check scdoc render program

function M.check()
  health.report_start 'scnvim'
  check_nvim_version()
  check_classes_installed()
end

return M
