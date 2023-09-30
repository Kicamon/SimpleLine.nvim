local M = {}

M.mode_map = {
  ['n']   = '󰋜 ',
  ['no']  = '󰋜 ',
  ['niI'] = '󰋜 ',
  ['niR'] = '󰋜 ',
  ['no'] = '󰋜 ',
  ['niV'] = '󰋜 ',
  ['nov'] = '󰋜 ',
  ['noV'] = '󰋜 ',
  ['i']   = ' ',
  ['ic']  = ' ',
  ['ix']  = ' ',
  ['s']   = ' ',
  ['S']   = ' ',
  ['v']   = ' ',
  ['V']   = ' ',
  ['']   = ' ',
  ['r']   = ' ',
  ['r?']  = ' ',
  ['c']   = ' ',
  ['t']   = ' ',
  ['!']   = ' ',
  ['R']   = ' ',
}

M.separator = {
  left = '╲',
  right = '╱'
}

M.CurSor = function(opt, bufnr)
  if opt == "row" then
    return vim.api.nvim_win_get_cursor(bufnr)[1]
  end
  return vim.api.nvim_win_get_cursor(bufnr)[2]
end

M.filename = function(bufnr)
  local file = vim.fn.bufname(bufnr)
  local buftype = vim.fn.getbufvar(bufnr, '&buftype')
  local filetype = vim.fn.getbufvar(bufnr, '&filetype')

  if buftype == 'help' then
    return 'help:' .. vim.fn.fnamemodify(file, ':t:r')
  elseif buftype == 'quickfix' then
    return 'quickfix'
  elseif filetype == 'TelescopePrompt' then
    return 'Telescope'
  elseif filetype == 'git' then
    return 'Git'
  elseif filetype == 'fugitive' then
    return 'Fugitive'
  elseif file:sub(file:len() - 2, file:len()) == 'FZF' then
    return 'FZF'
  elseif buftype == 'terminal' then
    local _, mtch = string.match(file, "term:(.*):(%a+)")
    return mtch ~= nil and mtch or vim.fn.fnamemodify(vim.env.SHELL, ':t')
  elseif file == '' then
    return '[No Name]'
  else
    return vim.fn.pathshorten(vim.fn.fnamemodify(file, ':p:~:t'))
  end
end

M.branch = function()
end

return M
