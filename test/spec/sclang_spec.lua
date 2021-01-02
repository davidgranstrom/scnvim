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
  it('can start client', function()
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
    assert.is_true(sclang.is_running())
  end)

  it('can receive commands', function()
    sclang.send('1 + 1', false)
    vim.cmd('sleep 1')
    assert.are.equal('-> 2', stdout[#stdout])
  end)

  it('can pass results to lua callback', function()
    sclang.eval('7 * 7', function(res)
      assert.are.equal(49, res)
    end)
    vim.cmd('sleep 1')
  end)

  it('can recompile client', function()
    sclang.recompile()
    vim.cmd('sleep 1')
    local result = 0
    for _, line in ipairs(stdout) do
      -- this line should now appear twice in the output
      if line:match('^*** Welcome to SuperCollider') then
        result = result + 1
      end
    end
    assert.are.equal(2, result)
  end)

  it('can stop client', function()
    sclang.stop()
    vim.cmd('sleep 1')
    assert.is_nil(stdout)
    assert.is_false(sclang.is_running())
  end)
end)
