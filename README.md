# SimpleLine.nvim
## Features
- minimalist
- statusline
- not support configuration

## Installation
<details>
<summary>lazy.nvim</summary>

```lua
{
  "Kicamon/SimpleLine.nvim",
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require("statusline").setup()
  end
}
```

</details>

<details>
<summary>vim-plug</summary>

```vim
Plug "Kicamon/SimpleLine.nvim"
lua require("statusline").setup()
```

</details>

## Heilght groups
```
StatusLineMode = { fg = "#afd787" },
StatusLineFileInfo = { fg = "#88abda" },
StatusLineBranch = { fg = "#88abda" },
StatusLineLsp = { fg = "#a9a1e1" },
StatusLineEncoding = { fg = "#afd787" },
StatlsLineLnum = { fg = "#afd787" },
```

### License MIT
