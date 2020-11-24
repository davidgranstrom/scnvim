local setup = require('../harness/setup')
require'busted.runner'(setup)

local sclang = require'scnvim/sclang'
local stdout

sclang.on_start = function()
  stdout = {''}
end

sclang.on_read = function(line)
  table.insert(stdout, line)
end

sclang.on_exit = function(code, signal)
  stdout = nil
end

describe('sclang', function()
  it('should start client', function()
    sclang.start()
    assert.are.equal(type(stdout), 'table')
  end)

  -- it('should stop client', function()
  --   -- print(vim.inspect(sclang))
  --   sclang.stop()
  --   assert.are.is_nil(stdout)
  -- end)
end)
