local M = {}
M.tabline = require("SimpleLine.tabline")

local setup = function()
  vim.opt.tabline = '%!v:lua.require\'SimpleLine.tabline\'.tabline()'
end

return {
  SimpleLine = M,
  setup = setup,
}
