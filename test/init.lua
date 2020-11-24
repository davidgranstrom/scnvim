-- require('./harness/setup')
local TestRunner = require'./harness/runner'

local test_list = {
  './spec/sclang'
}

local function run_all()
  local tests = test_list
  local count = #tests
  local runner = TestRunner:new()
  for _, test in ipairs(tests) do
    local res = runner:run_test(test, function(result)
      print(result)
      count = count - 1
    end)
  end
  return 0
end

run_all()
