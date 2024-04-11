local co, api = coroutine, vim.api
local SimpleLine = {}

local function stl_format(name, val)
  return '%#SimpleLine' .. name .. '#' .. val .. '%*'
end

local function stl_hl(name, attr)
  api.nvim_set_hl(0, 'SimpleLine' .. name, attr)
end

local function default()
  local p = require('SimpleLine.statusline')
  return {
    --
    p.sep,
    p.mode,
    --
    p.sepl,
    p.fileicon,
    p.fileinfo,
    p.modified,
    p.readonly,
    --
    p.sepl,
    p.branch,
    p.sep,
    p.gitadd,
    p.gitchange,
    p.gitdelete,
    --
    p.pad,
    p.recording,
    p.vnumber,
    --
    p.pad,
    p.diagError,
    p.diagWarn,
    p.diagInfo,
    p.diagHint,
    --
    p.sep,
    p.competitest,
    p.lsp,
    --
    p.sepr,
    p.encoding,
    --
    p.sepr,
    p.lnumcol,
    p.sep,
    --
  }
end

local function spl_init(event, pieces)
  SimpleLine.cache = {}
  for i, e in ipairs(SimpleLine.elements) do
    local res = e()

    if res.event and vim.tbl_contains(res.event, event) then
      local val = type(res.stl) == 'function' and res.stl() or res.stl
      pieces[#pieces + 1] = stl_format(res.name, val)
    elseif type(res.stl) == 'string' then
      pieces[#pieces + 1] = stl_format(res.name, res.stl)
    else
      pieces[#pieces + 1] = stl_format(res.name, '')
    end

    if res.attr then
      stl_hl(res.name, res.attr)
    end

    SimpleLine.cache[i] = {
      event = res.event,
      name = res.name,
      stl = res.stl,
    }
  end
  require('SimpleLine.statusline').initialized = true
  return table.concat(pieces, '')
end

local stl_render = co.create(function(event)
  local pieces = {}
  while true do
    if not SimpleLine.cache then
      spl_init(event, pieces)
    else
      for i, item in ipairs(SimpleLine.cache) do
        if item.event and vim.tbl_contains(item.event, event) and type(item.stl) == 'function' then
          local comp = SimpleLine.elements[i]
          local res = comp()
          if res.attr then
            stl_hl(item.name, res.attr)
          end
          pieces[i] = stl_format(item.name, res.stl(event))
        end
      end
    end
    vim.opt.stl = table.concat(pieces)
    event = co.yield()
  end
end)

function SimpleLine.setup()
  SimpleLine.elements = default()

  api.nvim_create_autocmd({ 'User' }, {
    pattern = { 'LspProgressUpdate', 'GitSignsUpdate' },
    callback = function(arg)
      vim.schedule(function()
        co.resume(stl_render, arg.match)
      end)
    end,
  })

  local events =
  { 'DiagnosticChanged', 'ModeChanged', 'BufEnter', 'BufWritePost', 'BufModifiedSet', 'LspAttach', 'LspDetach',
    'TermLeave', 'RecordingEnter', 'RecordingLeave', 'CmdlineLeave', 'CursorMoved' }
  api.nvim_create_autocmd(events, {
    callback = function(arg)
      vim.schedule(function()
        co.resume(stl_render, arg.event)
      end)
    end,
  })

  local events_tab = { 'BufEnter', 'BufWritePost', 'BufModifiedSet', 'TabNew', 'TabEnter', 'TabLeave', 'TermClose' }
  local update = require('SimpleLine.tabline').update
  vim.api.nvim_create_autocmd(events_tab, {
    callback = function()
      update()
    end
  })
  vim.keymap.set('n', 'tmp', function() update('-') end, {})
  vim.keymap.set('n', 'tmn', function() update('+') end, {})
end

return SimpleLine
