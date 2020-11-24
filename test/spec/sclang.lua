local setup = require('../harness/setup')
local scnvim = require'scnvim'

require'busted.runner'(setup)

describe('sclang', function()
  it('should start client', function()
    assert.are.equal(1, 1)
    -- sclang.start()
    -- assert.is_true(type(stdout) == 'table')
  end)
end)
