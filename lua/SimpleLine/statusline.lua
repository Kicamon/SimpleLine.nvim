local api = vim.api
local pd = {}

pd.initialized = false

local function stl_attr(group)
  local color = api.nvim_get_hl(0, { name = group, link = true })
  return {
    bg = 'NONE',
    fg = color.fg,
  }
end

local function alias_mode()
  return {
    ['n']   = '󰋜',
    ['no']  = '󰋜',
    ['niI'] = '󰋜',
    ['niR'] = '󰋜',
    ['no'] = '󰋜',
    ['niV'] = '󰋜',
    ['nov'] = '󰋜',
    ['noV'] = '󰋜',
    ['i']   = '',
    ['ic']  = '',
    ['ix']  = '',
    ['s']   = '',
    ['S']   = '',
    ['v']   = '',
    ['V']   = '',
    ['']   = '',
    ['r']   = ' ',
    ['r?']  = '',
    ['R']   = '',
    ['c']   = '',
    ['t']   = '',
    ['!']   = '',
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
    event = { 'ModeChanged', 'BufEnter', 'TermLeave' },
  }

  result.attr = stl_attr("StatusLineMode")
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

  local buf_type = vim.bo.buftype == 'terminal' and 'zsh' or ''
  local file_type = vim.bo.filetype ~= '' and vim.bo.filetype or buf_type
  local icon, color = resolve.get_icon_color_by_filetype(file_type, { default = true })
  return {
    stl = function()
      return icon .. ' '
    end,
    name = 'fileicon',
    event = { 'BufEnter', 'TermClose' },
    attr = {
      fg = color,
    },
  }
end

function pd.fileinfo()
  local function stl_file()
    local fname = api.nvim_buf_get_name(0)
    fname = vim.fn.pathshorten(vim.fn.fnamemodify(fname, ':p:~:t'))
    fname = fname ~= '' and fname or vim.bo.filetype
    return fname
  end
  local result = {
    stl = stl_file,
    name = 'fileinfo',
    event = { 'BufEnter', 'TermClose' },
  }

  result.attr = stl_attr('StatusLineFileInfo')
  result.attr.bold = true

  return result
end

function pd.modified()
  local function stl_modified()
    local modicon = vim.api.nvim_get_option_value('modified', { buf = 0 }) and ' ●' or ''
    return modicon
  end
  local result = {
    stl = stl_modified,
    name = 'modified',
    event = { 'BufEnter', 'BufWritePost', 'BufModifiedSet' },
    attr = {
      fg = '#ff461f',
    }
  }

  return result
end

function pd.readonly()
  local result = {
    stl = function()
      if vim.bo.readonly then
        return ' '
      else
        return ''
      end
    end,
    name = 'readonly',
    event = { 'BufEnter' },
    attr = {
      fg = "#ff461f"
    }
  }
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
    result.attr = stl_attr('DiffAdd')
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
    result.attr = stl_attr('DiffChange')
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
    result.attr = stl_attr('DiffDelete')
  end
  return result
end

function pd.branch()
  local result = {
    stl = function()
      local icon = ' '
      local res = gitsigns_data('head')
      return #res > 0 and icon .. res or ''
    end,
    name = 'gitbranch',
    event = { 'GitSignsUpdate' },
  }
  result.attr = stl_attr('StatlsLineBranch')
  result.attr.bold = true
  return result
end

function pd.pad()
  return {
    stl = '%=',
    name = 'pad',
    attr = {
      background = 'NONE',
      foreground = 'NONE',
    },
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

function pd.sepl()
  return {
    stl = ' ╲ ',
    name = 'sepl',
    attr = {
      foreground = '#3c3836'
    }
  }
end

function pd.sepr()
  return {
    stl = ' ╱ ',
    name = 'sepr',
    attr = {
      foreground = '#3c3836'
    }
  }
end

function pd.recording()
  local function stl_recording()
    local stl = vim.fn.reg_recording()
    if stl ~= '' then
      stl = '@' .. stl
    end
    return stl
  end
  local result = {
    stl   = stl_recording,
    name  = 'recording',
    attr  = {
      foreground = '#fabd2f',
    },
    event = { 'RecordingEnter', 'RecordingLeave' },
  }

  result.attr.bold = true

  return result
end

function pd.vnumber()
  local function stl_vnumber()
    local sl, sr = vim.fn.getpos('v')[2], vim.fn.getpos('v')[3]
    local el, er = vim.fn.getpos('.')[2], vim.fn.getpos('.')[3]
    local str = ''
    if sl == el then
      str = tostring(math.abs(sr - er) + 1)
    else
      str = tostring(math.abs(sl - el) + 1)
    end
    if vim.api.nvim_get_mode().mode ~= 'v' and vim.api.nvim_get_mode().mode ~= 'V' then
      str = ''
    end
    return str
  end
  local result = {
    stl = stl_vnumber,
    name = 'vnumber',
    attr = {
      foreground = '#afd787',
    },
    event = { 'CursorMoved', 'ModeChanged' },
  }

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
  if vim.diagnostic.is_enabled() then
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
    result.attr = stl_attr('DiagnosticError')
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
    result.attr = stl_attr('DiagnosticWarn')
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
    result.attr = stl_attr('DiagnosticInfo')
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
    result.attr = stl_attr('DiagnosticHint')
  end
  return result
end

function pd.lsp()
  local function lsp_stl(event)
    local msg = ''

    if #msg == 0 and event ~= 'LspDetach' then
      local client = vim.lsp.get_clients({ bufnr = 0 })
      if #client ~= 0 then
        msg = client[1].name
      end
    end
    return '%.40{"' .. msg .. '"}'
  end

  local result = {
    stl = lsp_stl,
    name = 'Lsp',
    event = { 'LspProgressUpdate', 'LspAttach', 'LspDetach' },
  }

  if not pd.initialized then
    result.attr = stl_attr("StatusLineLsp")
    result.attr.bold = true
  end
  return result
end

function pd.competitest()
  local function cp_stl()
    return vim.g.cp and '󰈼 ' or ''
  end
  local result = {
    stl = cp_stl,
    name = 'competitest',
    event = { 'CmdlineLeave' },
    attr = {
      foreground = '#a9a1e1',
    }
  }
  return result
end

function pd.encoding()
  local map = {
    ['unix'] = ' ',
    ['linux'] = ' ',
    ['dos'] = ' ',
  }
  local result = {
    stl = map[vim.o.ff] .. vim.o.fileencoding,
    name = 'fileformat',
    event = { 'BufEnter' },
  }
  result.attr = stl_attr("StatusLineEncoding")
  result.attr.bold = true
  return result
end

function pd.lnumcol()
  local result = {
    stl   = '%-2.(%l:%c%)  %P',
    name  = 'linecol',
    event = { 'BufEnter' },
  }

  result.attr = stl_attr('StatlsLineLnum')
  result.attr.bold = true
  return result
end

return pd
