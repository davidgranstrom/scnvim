--- scnvim test runner.
-- @module test/harness/runner
-- @author David Granström
-- @license GPLv3

local TestRunner = {}

function TestRunner:new(tbl)
  tbl = tbl or {}
  setmetatable(tbl, self)
  self.__index = self
  return tbl
end

function TestRunner:run_test(test, on_exit)
  local cmd = {
    'nvim',
    '--headless',
    '-c', string.format([['lua require"%s"']], test),
  }
  local stdout_data
  local stderr_data
  local options = {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(id, data, event)
      stdout_data = data[1]
    end,
    on_stderr = function(id, data, event)
      stderr_data = data[1]
    end,
    on_exit = function(id, data, event)
      assert(data == 0, 'Error code: '..data)
      local result = stdout_data..stderr_data
      on_exit(result)
    end,
  }
  local job = vim.fn.jobstart(table.concat(cmd, ' '), options)
  if job == 0 then
    error('invalid arguments to job')
  elseif job < 0 then
    error('could not start nvim executable')
  end
  return job
end

return TestRunner
