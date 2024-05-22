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
StatusLineMode
StatusLineFileInfo
StatlsLineBranch
StatlsLineLnum
StatusLineReadOnly
StatusLineEncoding
```

### License MIT
