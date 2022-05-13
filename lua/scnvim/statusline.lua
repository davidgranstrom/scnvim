local M = {}

local widgets = {
  statusline = '',
}

--- Set the server status
---@param str The server status string.
function M.set_server_status(str)
  widgets.statusline = str
end

--- Get the server status.
---@return A string containing the server status.
function M.get_server_status()
  return widgets.statusline or ''
end

return M
