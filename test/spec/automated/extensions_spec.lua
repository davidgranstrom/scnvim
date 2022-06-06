local scnvim = require 'scnvim'

require 'scnvim.commands'()

scnvim.setup {
  ensure_installed = false,
  extensions = {
    ['unit-test'] = {
      some_var = 123,
    },
  },
}

describe('extensions', function()
  it('can be loaded', function()
    local ext = scnvim.load_extension 'unit-test'
    assert.is_true(type(ext) == 'table')
    ext.test_setup()
  end)

  it('can run user commands', function()
    assert.is_true((pcall(vim.cmd, 'SCNvimExt unit-test.test_setup')))
    assert.is_false((pcall(vim.cmd, 'SCNvimExt unit-test.foobar')))
  end)

  it('can run user commands with arguments', function()
    assert.is_true((pcall(vim.cmd, 'SCNvimExt unit-test.test_args 777 foo 666')))
  end)
end)
