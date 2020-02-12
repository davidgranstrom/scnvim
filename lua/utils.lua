local M = {}

function M.json_encode(data)
  local err, result = pcall(vim.fn.json_encode, data)
  if err then
    return result
  else
    return nil, result
  end
end

function M.json_decode(data)
  local err, result = pcall(vim.fn.json_decode, data)
  if err then
    return result
  else
    return nil, result
  end
end

--- 0 - nothing
--- 2 - debug
local Log = {
  level = 0
}

--- we always want to show errors
function Log.error(message)
  print(vim.inspect('[scnvim] ERROR: ' .. message))
end

function Log.info(message)
  print(vim.inspect('[scnvim] ' .. message))
end

function Log.debug(message)
  if Log.level > 0 then
    print(vim.inspect(message))
  end
end

M.log = Log

return M
