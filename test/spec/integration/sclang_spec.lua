local sclang = require 'scnvim.sclang'
local config = require 'scnvim.config'
local timeout = 5000
local sclang_path = vim.loop.os_getenv 'SCNVIM_SCLANG_PATH'
local stdout

config.sclang.cmd = sclang_path

sclang.on_init:append(function()
  stdout = { '' }
end)

sclang.on_output:append(function(line)
  table.insert(stdout, line)
end)

sclang.on_exit:append(function()
  stdout = nil
end)

describe('sclang', function()
  it('can start the interpreter', function()
    sclang.start()
    local result = false
    vim.wait(timeout, function()
      if type(stdout) == 'table' then
        for _, line in ipairs(stdout) do
          if line:match '^*** Welcome to SuperCollider' then
            result = true
            return result
          end
        end
      end
    end)
    assert.is_true(result)
    assert.is_true(sclang.is_running())
  end)

  it('can recompile the interpreter', function()
    sclang.recompile()
    local result = 0
    vim.wait(timeout, function()
      for _, line in ipairs(stdout) do
        -- this line should now appear twice in the output
        if line:match '^*** Welcome to SuperCollider' then
          result = result + 1
        end
        if result == 2 then
          return true
        end
      end
    end)
    assert.are.equal(2, result)
  end)

  it('can evaluate an expression', function()
    local result
    sclang.send('1 + 1', false)
    vim.wait(timeout, function()
      result = stdout[#stdout]
      return result == '-> 2'
    end)
    assert.are.equal('-> 2', result)
  end)

  it('can pass results to a lua callback', function()
    local result
    sclang.eval('7 * 7', function(res)
      result = res
    end)
    vim.wait(timeout, function()
      return result == 49
    end)
    assert.are.equal(49, result)
  end)

  it('eval correctly escapes strings', function()
    local result
    sclang.eval('"hello"', function(res)
      result = res
    end)
    vim.wait(timeout, function()
      return result == 'hello'
    end)
    assert.are.equal('hello', result)
  end)

  it('can stop the interpreter', function()
    sclang.stop()
    vim.wait(timeout, function()
      return not stdout
    end)
    assert.is_nil(stdout)
    assert.is_false(sclang.is_running())
  end)
end)
