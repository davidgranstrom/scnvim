-- luacheck: globals assert

local x = nil

return require('scnvim').register_extension {
  setup = function(ext, user)
    assert.is_true(type(ext) == 'table')
    assert.is_true(type(user) == 'table')
    x = ext.some_var
  end,
  exports = {
    test_args = function(a, b, c)
      assert.are.equal(777, tonumber(a))
      assert.are.equal('foo', b)
      assert.are.equal(666, tonumber(c))
    end,
    test_setup = function()
      assert.are.equal(123, x)
    end,
  },
  health = function() end,
}
