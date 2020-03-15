local M = {}

--- update the status line widgets
function M.update(object)
  local status = object['server_status']
  local meter = object['level_meter']
  local widgets = vim.api.get_var('scnvim_stl_widgets')
  vim.list_extend(widgets, {
      server_status = status
      level_meter = meter
    })
  vim.api.set_var('scnvim_stl_widgets', widgets)
end

return M
