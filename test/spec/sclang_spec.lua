local setup = require('harness.setup')
require'busted.runner'(setup)

local sclang = require'scnvim.sclang'
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
    local result = false
    vim.wait(5000, function()
      if type(stdout) == 'table' then
        for _, line in ipairs(stdout) do
          if line:match('^*** Welcome to SuperCollider') then
            result = true
            return result
          end
        end
      end
    end)
    assert.is_true(result)
  end)

  -- it('should stop client', function()
  --   sclang.stop()
  -- end)

  -- it('should fail', function()
  --   -- assert.are.equal(1, 2)
  -- end)
end)
