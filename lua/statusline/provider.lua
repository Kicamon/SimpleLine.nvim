local api = vim.api
local pd = {}

pd.initialized = false

local function stl_attr(group, trans)
  local color = api.nvim_get_hl_by_name(group, true)
  trans = trans or false
  return {
    bg = 'NONE',
    fg = color.foreground,
  }
end

local function alias_mode()
  return {
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
    ['R']   = ' ',
    ['c']   = ' ',
    ['t']   = ' ',
    ['!']   = ' ',
  }
end

function pd.mode()
  local alias = alias_mode()
  local result = {
    stl = function()
      local mode = api.nvim_get_mode().mode
      return alias[mode] or alias[string.sub(mode, 1, 1)] or 'UNK'
    end,
    name = 'mode',
    event = { 'ModeChanged', 'BufEnter' },
  }

  result.attr = stl_attr("StatusLineMode", true)
  result.attr.bold = true

  return result
end

local resolve

local function init_devicon()
  if resolve then
    return
  end
  local ok, devicon = pcall(require, 'nvim-web-devicons')
  if not ok then
    return
  end
  resolve = devicon
end

function pd.fileicon()
  if not resolve then
    init_devicon()
  end

  local icon, color = resolve.get_icon_color_by_filetype(vim.bo.filetype, { default = true })
  return {
    stl = function()
      return icon .. ' '
    end,
    name = 'fileicon',
    event = { 'BufEnter' },
    attr = {
      fg = color,
    },
  }
end

function pd.fileinfo()
  local function stl_file()
    local fname = api.nvim_buf_get_name(0)
    return vim.fn.pathshorten(vim.fn.fnamemodify(fname, ':p:~:t'))
  end
  local result = {
    stl = stl_file,
    name = 'fileinfo',
    event = { 'BufEnter', 'TermClose' },
  }

  result.attr = stl_attr('StatusLineFileInfo', true)
  result.attr.bold = true

  return result
end

local function gitsigns_data(type)
  if not vim.b.gitsigns_status_dict then
    return ''
  end

  local val = vim.b.gitsigns_status_dict[type]
  val = (val == 0 or not val) and '' or tostring(val) .. (type == 'head' and '' or ' ')
  return val
end

local function git_icons(type)
  local tbl = {
    ['added'] = ' ',
    ['changed'] = ' ',
    ['deleted'] = ' ',
  }
  return tbl[type]
end

function pd.gitadd()
  local result = {
    stl = function()
      local res = gitsigns_data('added')
      return #res > 0 and git_icons('added') .. res or ''
    end,
    name = 'gitadd',
    event = { 'GitSignsUpdate' },
  }
  if not pd.initialized then
    result.attr = stl_attr('DiffAdd', true)
  end
  return result
end

function pd.gitchange()
  local result = {
    stl = function()
      local res = gitsigns_data('changed')
      return #res > 0 and git_icons('changed') .. res or ''
    end,
    name = 'gitchange',
    event = { 'GitSignsUpdate' },
  }

  if not pd.initialized then
    result.attr = stl_attr('DiffChange', true)
  end
  return result
end

function pd.gitdelete()
  local result = {
    stl = function()
      local res = gitsigns_data('removed')
      return #res > 0 and git_icons('deleted') .. res or ''
    end,
    name = 'gitdelete',
    event = { 'GitSignsUpdate' },
  }

  if not pd.initialized then
    result.attr = stl_attr('DiffDelete', true)
  end
  return result
end

function pd.branch()
  local result = {
    stl = function()
      local icon = '  '
      local res = gitsigns_data('head')
      return #res > 0 and res .. icon or 'UNKOWN'
    end,
    name = 'gitbranch',
    event = { 'GitSignsUpdate' },
  }
  result.attr = stl_attr('StatlsLineBranch', true)
  result.attr.bold = true
  return result
end

function pd.pad()
  return {
    stl = '%=',
    name = 'pad',
  }
end

function pd.sep()
  return {
    stl = ' ',
    name = 'sep',
    attr = {
      background = 'NONE',
      foreground = 'NONE',
    },
  }
end

function pd.lnumcol()
  local result = {
    stl   = '%-2.(%l:%c%)  %P',
    name  = 'linecol',
    event = { 'CursorHold' },
  }

  result.attr = stl_attr('StatlsLineLnum', true)
  result.attr.bold = true
  return result
end

local function get_diag_sign(type)
  local prefix = 'DiagnosticSign'
  for _, item in ipairs(vim.fn.sign_getdefined()) do
    if item.name == prefix .. type then
      return item.text
    end
  end
end

local function diagnostic_info(severity)
  if vim.diagnostic.is_disabled(0) then
    return ''
  end
  local tbl = { 'Error', 'Warn', 'Info', 'Hint' }
  local count = #vim.diagnostic.get(0, { severity = severity })
  return count == 0 and '' or get_diag_sign(tbl[severity]) .. tostring(count) .. ' '
end

function pd.diagError()
  local result = {
    stl = function()
      return diagnostic_info(1)
    end,
    name = 'diagError',
    event = { 'DiagnosticChanged', 'BufEnter' },
  }
  if not pd.initialized then
    result.attr = stl_attr('DiagnosticError', true)
  end
  return result
end

function pd.diagWarn()
  local result = {
    stl = function()
      return diagnostic_info(2)
    end,
    name = 'diagWarn',
    event = { 'DiagnosticChanged', 'BufEnter' },
  }
  if not pd.initialized then
    result.attr = stl_attr('DiagnosticWarn', true)
  end
  return result
end

function pd.diagInfo()
  local result = {
    stl = function()
      return diagnostic_info(3)
    end,
    name = 'diaginfo',
    event = { 'DiagnosticChanged', 'BufEnter' },
  }
  if not pd.initialized then
    result.attr = stl_attr('DiagnosticInfo', true)
  end
  return result
end

function pd.diagHint()
  local result = {
    stl = function()
      return diagnostic_info(4)
    end,
    name = 'diaghint',
    event = { 'DiagnosticChanged', 'BufEnter' },
  }
  if not pd.initialized then
    result.attr = stl_attr('DiagnosticHint', true)
  end
  return result
end

function pd.readonly()
  local result = {
    stl = function()
      if vim.bo.readonly then
        return ' '
      else
        return ''
      end
    end,
    name = 'readonly',
    event = { 'BufEnter' },
  }
  result.attr = stl_attr("StatusLineReadOnly", true)
  return result
end

function pd.encoding()
  local map = {
    ['unix'] = ' ',
    ['linux'] = ' ',
    ['dos'] = ' ',
  }
  local result = {
    stl = vim.o.fileencoding .. ' ' .. map[vim.o.ff],
    name = 'fileformat',
    event = { 'BufEnter' },
  }
  result.attr = stl_attr("StatusLineEncoding", true)
  result.attr.bold = true
  return result
end

return pd
