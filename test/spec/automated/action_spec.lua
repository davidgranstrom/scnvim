local action = require 'scnvim.action'

describe('actions', function()
  it('can replace and restore default function', function()
    local x = 0
    local a = action.new(function()
      x = x + 1
    end)
    a()
    assert.are_equal(1, x)
    a:replace(function()
      x = x - 1
    end)
    a()
    assert.are_equal(0, x)
    a:restore()
    a()
    assert.are_equal(1, x)
  end)

  it('can append and remove functions', function()
    local x = 0
    local a = action.new(function()
      x = x + 1
    end)
    local id = a:append(function()
      x = x - 1
    end)
    assert.not_nil(id)
    a()
    assert.are.equal(0, x)
    a:remove(id)
    a()
    assert.are.equal(1, x)
  end)
end)
