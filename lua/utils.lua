local M = {}

function M.json_encode(data)
  return pcall(vim.fn.json_encode, data)
end

function M.json_decode(data)
  print(data)
  return pcall(vim.fn.json_decode, data)
end

local Log = {}

function Log.error(message)
  print(vim.inspect('[scnvim] ERROR: ' .. message))
end

function Log.info(message)
  print(vim.inspect('[scnvim] ' .. message))
end

M.log = Log

return M
