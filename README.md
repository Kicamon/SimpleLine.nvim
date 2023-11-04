# SimpleLine.nvim
## Features
- minimalist
- statusline and bufferline
- not support configuration

## Screenshots
![tabline](img/tabline.png)
![statusline](img/statusline.png)

## Installation
```lua
{
  "Kicamon/SimpleLine.nvim",
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require("statusline").setup()
    require("tabline").setup()
  end
}
```

## Heilght groups
```
StatusLineMode
StatusLineFileInfo
StatlsLineBranch
StatlsLineLnum
StatusLineReadOnly
StatusLineEncoding
TabLineTop
TabLineSel
TabLine
```

### License MIT
