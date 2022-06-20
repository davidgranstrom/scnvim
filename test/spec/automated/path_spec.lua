local path = require 'scnvim.path'

local eq = assert.are.same
local is_ci = vim.loop.os_getenv 'SCNVIM_CI'

describe('path', function()
  it('tests that a directory exists', function()
    local cur_dir = vim.fn.expand '%:p:h'
    local dir = path.concat(cur_dir, 'spec', 'fixtures')
    assert.is_true(path.exists(dir))
    dir = path.concat(cur_dir, 'spec', 'nop')
    assert.is_false(path.exists(dir))
  end)

  it('tests that a file exists', function()
    local cur_dir = vim.fn.expand '%:p:h'
    local file = path.concat(cur_dir, 'spec', 'fixtures', 'file.lua')
    assert.is_true(path.exists(file))
    file = path.concat(cur_dir, 'spec', 'fixtures', 'nop.lua')
    assert.is_false(path.exists(file))
  end)

  it('concatenates items into a path', function()
    local value = path.concat('this', 'is', 'a', 'file.txt')
    local expected = 'this/is/a/file.txt'
    eq(value, expected)
  end)

  it('returns asset paths', function()
    local asset = path.get_asset 'snippets'
    asset = string.match(asset, 'scnvim_snippets.lua')
    eq(asset, 'scnvim_snippets.lua')
    asset = path.get_asset 'syntax'
    asset = string.match(asset, 'classes.vim')
    eq(asset, 'classes.vim')
    asset = path.get_asset 'tags'
    asset = string.match(asset, 'tags')
    eq(asset, 'tags')
    assert.has_errors(function()
      path.get_asset 'foo'
    end)
  end)

  it('returns the cache directory', function()
    local cache_dir = path.get_cache_dir()
    assert.not_nil(cache_dir)
    cache_dir = string.match(cache_dir, 'nvim/scnvim')
    local expected = path.concat('nvim', 'scnvim')
    eq(cache_dir, expected)
  end)

  it('converts windows paths to unix style', function()
    local s = [[C:\Users\test\AppData\Local]]
    eq('C:/Users/test/AppData/Local', path.normalize(s))
  end)

  it('can create symbolic links', function()
    local dir = vim.fn.expand '%:p:h'
    local source = path.concat(dir, 'spec', 'fixtures', 'file.lua')
    local destination = path.get_cache_dir() .. '/linktest.lua'
    path.link(source, destination)
    assert.is_true(path.is_symlink(destination))
  end)

  it('can delete symbolic links', function()
    local destination = path.get_cache_dir() .. '/linktest.lua'
    path.unlink(destination)
    assert.is_false(path.exists(destination))
  end)

  -- this test will fail on CI since we're adding scnvim as a relative path to the runtimepath
  -- TODO: maybe we need to revert to the old implemenation?
  if not is_ci then
    it('returns plugin root dir', function()
      local root_dir = path.get_plugin_root_dir()
      root_dir = string.match(root_dir, 'scnvim')
      eq(root_dir, 'scnvim')
    end)
  end
end)
