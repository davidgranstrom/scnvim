local create_commands = require 'scnvim.commands'

describe('commands', function()
  it('creates user commands for the current buffer', function()
    vim.cmd [[ edit commands.scd ]]
    create_commands()
    local expected = {
      'SCNvimGenerateAssets',
      'SCNvimHelp',
      'SCNvimRecompile',
      'SCNvimReboot',
      'SCNvimStart',
      'SCNvimStatusLine',
      'SCNvimStop',
      'SCNvimExt',
      'SCNvimTags', -- deprecated
    }
    local cmds = vim.api.nvim_buf_get_commands(0, {})
    assert.are.equal(#expected, vim.tbl_count(cmds))
    local count = 0
    for _, key in ipairs(expected) do
      local c = cmds[key]
      if c ~= nil then
        count = count + 1
      end
    end
    assert.are.equal(#expected, count)
    vim.cmd [[ bd! ]]
  end)
end)
