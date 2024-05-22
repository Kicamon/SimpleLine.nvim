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

local function spl_init()
  local pieces = {}
  SimpleLine.cache = {}
  for key, item in ipairs(SimpleLine.elements) do
    if type(item().stl) == 'function' then
      pieces[#pieces + 1] = stl_format(item().name, item().stl())
    elseif type(item().stl) == 'string' then
      pieces[#pieces + 1] = stl_format(item().name, item().stl)
    else
      pieces[#pieces + 1] = stl_format(item().name, '')
    end

    if item().attr then
      stl_hl(item().name, item().attr)
    end

    SimpleLine.cache[key] = {
      event = item().event,
      name = item().name,
      stl = item().stl,
    }
  end
  return pieces
end

local stl_render = co.create(function(event)
  local pieces = spl_init()
  while true do
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
