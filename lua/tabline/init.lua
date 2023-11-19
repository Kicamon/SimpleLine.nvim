local Simple_Tab = {}

local function tbl_hl(name, attr)
  vim.api.nvim_set_hl(0, "Simple_Tab" .. name, attr)
  return "Simple_Tab" .. name
end

local function getinfo(bufnr)
  return {
    file = vim.fn.bufname(bufnr),
    buftype = vim.fn.getbufvar(bufnr, '&buftype'),
    filetype = vim.fn.getbufvar(bufnr, '&filetype')
  }
end

Simple_Tab.devicon = function(bufnr, isSelected)
  local icon, devhl
  local info = getinfo(bufnr)
  local buftype, filetype = info.buftype, info.filetype
  local ok, devicons = pcall(require, 'nvim-web-devicons')
  if not ok then
    return ''
  end
  if buftype == 'terminal' then
    icon, devhl = devicons.get_icon_color_by_filetype('zsh', { default = true })
  else
    icon, devhl = devicons.get_icon_color_by_filetype(filetype, { default = true })
  end
  if icon then
    local attr = {
      fg = devhl,
    }
    local hl = tbl_hl(filetype, attr)
    local selectedHlStart = (isSelected and hl) and '%#' .. hl .. '#' or ''
    return selectedHlStart .. icon .. ' '
  end
  return ''
end

Simple_Tab.title = function(bufnr)
  local name
  local info = getinfo(bufnr)
  local file, buftype, filetype = info.file, info.buftype, info.filetype

  if buftype == 'help' then
    name = 'help:' .. vim.fn.fnamemodify(file, ':t:r')
  elseif filetype == 'TelescopePrompt' then
    name = 'Telescope'
  elseif buftype == 'terminal' then
    local _, mtch = string.match(file, "term:(.*):(%a+)")
    name = mtch ~= nil and mtch or vim.fn.fnamemodify(vim.env.SHELL, ':t')
  elseif file == '' then
    name = '[No Name]'
  else
    name = vim.fn.pathshorten(vim.fn.fnamemodify(file, ':p:~:t'))
  end
  return '%#TabLineSel#' .. name
end

Simple_Tab.modified = function(bufnr)
  local modicon = vim.fn.getbufvar(bufnr, '&modified') == 1 and '●' or ''
  local hl = tbl_hl("modified", { fg = "#ff461f" })
  modicon = '%#' .. hl .. '#' .. modicon
  return modicon
end

Simple_Tab.cell = function(index)
  local isSelected = vim.fn.tabpagenr() == index
  local buflist = vim.fn.tabpagebuflist(index)
  local winnr = vim.fn.tabpagewinnr(index)
  local bufnr = buflist[winnr]
  local hl = (isSelected and '%#TabLineSel#' or '%#TabLine#')

  return hl .. '%' .. index .. 'T' .. ' ' ..
      Simple_Tab.devicon(bufnr, isSelected) ..
      Simple_Tab.title(bufnr) .. ' ' ..
      Simple_Tab.modified(bufnr) .. '%T'
end

Simple_Tab.tabline = function()
  local cell = Simple_Tab.cell
  local line = ''
  for i = 1, vim.fn.tabpagenr('$'), 1 do
    line = line .. cell(i)
  end
  line = line .. '%#TabLineFill#%='
  return line
end

local setup = function()
  vim.opt.tabline = "%!v:lua.require'tabline'.tabline.tabline()"
end

return {
  tabline = Simple_Tab,
  setup = setup,
}
