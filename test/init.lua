local TestRunner = require'harness.runner'

local test_list = {
  './spec/sclang_spec',
}

local function run_all()
  local count = #test_list
  local runner = TestRunner:new({ headless = true })
  for _, test in ipairs(test_list) do
    runner:run_test(test, function(_)
      count = count - 1
    end)
  end
  vim.wait(10000, function()
    return count == 0
  end)
  os.exit(count)
end

run_all()
