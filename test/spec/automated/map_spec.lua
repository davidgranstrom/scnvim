local map = require('scnvim.map').map

describe('map', function()
  it('validates input strings', function()
    assert.has_error(function()
      map 'foo.send_line'
    end)
    assert.has_error(function()
      map 'editor send_line'
    end)
  end)

  it('accepts functions', function()
    local ret = map(function() end)
    assert.not_nil(ret.fn)
  end)

  it('uses normal mode as default', function()
    local ret = map(function() end)
    assert.are.equal('n', ret.modes[1])
  end)

  it('can use callbacks for editor keymaps', function()
    local editor = require 'scnvim.editor'
    local ret = map('editor.send_line', 'n', function(data)
      assert.are.equal('foo', data[1])
      return data
    end)
    editor.on_send:replace(function(lines, cb)
      if cb then
        cb(lines)
      end
    end)
    vim.api.nvim_buf_set_lines(0, -2, -1, false, { 'foo' })
    ret.fn()
    editor.on_send:restore()
  end)
end)
