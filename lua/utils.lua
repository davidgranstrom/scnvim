local M = {}

function M.json_encode(data)
  return pcall(vim.fn.json_encode, data)
end

function M.json_decode(data)
  print(data)
  return pcall(vim.fn.json_decode, data)
end

function M.send_to_sc(args)
  vim.api.nvim_call_function('scnvim#sclang#send_silent', {args})
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
