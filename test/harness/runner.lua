--- scnvim test runner.
-- @module test/harness/runner
-- @author David Granström
-- @license GPLv3

local TestRunner = {}
TestRunner.__index = TestRunner

function TestRunner:new(tbl)
  tbl = tbl or {
    headless = false,
  }
  return setmetatable(tbl, self)
end

function TestRunner:stdout_outputter(data)
  if data then
    print(data)
  end
end

function TestRunner:nvim_outputter(data)
  if data then
    print(data)
  end
end

function TestRunner:run_test(test, on_exit)
  local cmd = {
    'nvim',
    '--headless',
    '-u', './vim/init.vim',
    '-c', string.format("lua require'%s'", test),
  }
  local stdout_data = ''
  local stderr_data = ''
  local options = {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      -- print(vim.inspect(data))
      stdout_data = data[1]
      stdout_data = stdout_data:gsub('\n', ''):gsub('\r', '')
    end,
    on_stderr = function(_, data)
      print(vim.inspect(data))
      stderr_data = data[1]
      stderr_data = stderr_data:gsub('\n', ''):gsub('\r', '')
    end,
    on_exit = vim.schedule_wrap(function(_, data)
      assert(data == 0, 'Error code: '..data)
      local result = stdout_data..stderr_data
      if self.headless then
        self:stdout_outputter(result)
      else
        self:nvim_outputter(result)
      end
      on_exit(result)
    end),
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
