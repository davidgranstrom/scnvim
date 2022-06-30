local editor = require 'scnvim.editor'

local content = [[
x = 123;
(
var x = 123;
x * 2;
)
x = 7;
x = x * 2;
(
var x = 7;
// )
x * 2;
)
(
var y = 3;
y * 2;
)foo
]]

local buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_win_set_buf(0, buf)
vim.api.nvim_buf_set_option(buf, 'filetype', 'supercollider')
content = vim.split(content, '\n', { plain = true, trimempty = true })
vim.api.nvim_buf_set_lines(buf, -2, -1, false, content)

describe('editor', function()
  describe('eval', function()
    before_each(function()
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
    end)

    it('can send a single line', function()
      editor.send_line(function(data)
        assert.are.equal('x = 123;', data[1])
        return data
      end)
    end)

    it('can send a code block', function()
      vim.api.nvim_win_set_cursor(0, { 2, 0 })
      editor.send_block(function(data)
        local block = table.concat(data, '\n')
        local expected = [[
(
var x = 123;
x * 2;
)]]
        assert.are.equal(expected, block)
        return data
      end)
    end)

    it('can send linewise visual selection', function()
      vim.api.nvim_win_set_cursor(0, { 6, 0 })
      vim.cmd [[normal! V]]
      vim.api.nvim_win_set_cursor(0, { 7, 0 })
      editor.send_selection(function(data)
        local selection = table.concat(data, '\n')
        local expected = [[
x = 7;
x = x * 2;]]
        assert.are.equal(expected, selection)
        return data
      end)
    end)

    it('can send a visual selection', function()
      vim.api.nvim_win_set_cursor(0, { 6, 0 })
      vim.cmd [[normal! v]]
      vim.api.nvim_win_set_cursor(0, { 6, 4 })
      editor.send_selection(function(data)
        local selection = table.concat(data, '\n')
        local expected = 'x = 7'
        assert.are.equal(expected, selection)
        return data
      end)
    end)

    it('ignores parenthesis in comments', function()
      vim.api.nvim_win_set_cursor(0, { 8, 0 })
      editor.send_block(function(data)
        local block = table.concat(data, '\n')
        local expected = [[
(
var x = 7;
// )
x * 2;
)]]
        assert.are.equal(expected, block)
        return data
      end)
    end)

    it('ignores everything after block end', function()
      vim.api.nvim_win_set_cursor(0, { 13, 0 })
      editor.send_block(function(data)
        local block = table.concat(data, '\n')
        local expected = [[
(
var y = 3;
y * 2;
)]]
        assert.are.equal(expected, block)
        return data
      end)
    end)
  end)

  describe('autocmds', function()
    local config = require 'scnvim.config'
    it('treats .sc files as supercollider', function()
      editor.setup()
      vim.cmd [[edit Test.sc]]
      assert.are.equal('supercollider', vim.bo.filetype)
      config.editor.force_ft_supercollider = false
      editor.setup()
      vim.cmd [[edit Test.sc]]
      assert.are.equal('scala', vim.bo.filetype)
      config.editor.force_ft_supercollider = true
    end)

    it('can use user keymaps in post window', function()
      local postwin = require 'scnvim.postwin'
      local map = require('scnvim.map').map
      config.postwin.mapping = {
        q = map(function()
          postwin.close()
        end),
      }
      editor.setup() -- add autocmds
      vim.cmd [[edit maptest.scd]]
      postwin.focus()
      assert.is_true(postwin.is_open())
      assert.are.equal('scnvim', vim.bo.filetype)
      vim.cmd [[normal q]]
      assert.is_false(postwin.is_open())
    end)
  end)
end)
