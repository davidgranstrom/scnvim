local install = require 'scnvim.install'

local is_ci = vim.loop.os_getenv 'SCNVIM_CI'
if is_ci then
  require('scnvim.path').get_plugin_root_dir = function()
    return vim.fn.expand '%:p:h:h'
  end
end

describe('install', function()
  it('can link scnvim classes', function()
    install.install()
    assert.not_nil(install.check())
  end)

  it('can unlink scnvim classes', function()
    install.uninstall()
    assert.is_nil(install.check())
    install.install() -- reset for next test
  end)
end)
