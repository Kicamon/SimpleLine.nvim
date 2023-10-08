local pd = require('statusline.provider')
local sp = {}

function sp.sep()
  return {
    stl = ' ',
    name = 'sep',
    attr = {
      background = 'NONE',
      foreground = 'NONE',
    },
  }
end

function sp.sp()
  return {
    stl = '█',
    name = 'sepblock',
    attr = {
      background = 'NONE',
      foreground = pd.stl_bg(),
    },
  }
end

return sp
