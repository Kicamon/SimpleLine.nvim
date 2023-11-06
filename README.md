# SimpleLine.nvim
## Features
- minimalist
- statusline and bufferline
- not support configuration

## Screenshots
![tabline](img/tabline.png)
![statusline](img/statusline.png)

## Installation
<details>
<summary>lazy.nvim</summary>

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

</details>

<details>
<summary>vim-plug</summary>

```vim
Plug "Kicamon/SimpleLine.nvim"
lua require("statusline").setup()
lua require("tabline").setup()
```

</details>

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
