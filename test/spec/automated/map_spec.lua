local map = require('scnvim.map').map
local map_expr = require('scnvim.map').map_expr

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
    local options = {
      callback = function(data)
        assert.are.equal('foo', data[1])
        return data
      end,
    }
    local ret = map('editor.send_line', 'n', options)
    editor.on_send:replace(function(lines, cb)
      if cb then
        cb(lines)
      end
    end)
    vim.api.nvim_win_set_cursor(0, {1, 0})
    vim.api.nvim_buf_set_lines(0, -2, -1, true, { 'foo' })
    ret.fn()
    editor.on_send:restore()
  end)

  it('sets a default description', function()
    local ret = map('editor.send_line', 'n')
    assert.are.equal('scnvim: editor.send_line', ret.options.desc)
    ret = map('editor.send_line', 'n', { desc = 'custom desc' })
    assert.are.equal('custom desc', ret.options.desc)
  end)
end)

describe('map_expr', function()
  it('sets a default description', function()
    local ret = map_expr('s.boot', 'n')
    assert.are.equal('sclang: s.boot', ret.options.desc)
    ret = map_expr('s.boot', 'n', { desc = 'custom desc' })
    assert.are.equal('custom desc', ret.options.desc)
  end)
end)
