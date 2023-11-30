local co, api = coroutine, vim.api
local Simple_Status = {}

local function stl_format(name, val)
  return '%#Simple_Status' .. name .. '#' .. val .. '%*'
end

local function stl_hl(name, attr)
  api.nvim_set_hl(0, 'Simple_Status' .. name, attr)
end

local function default()
  local p = require('statusline.provider')
  return {
    --
    p.sep,
    p.mode,
    --
    p.sep,
    p.fileicon,
    p.fileinfo,
    --
    p.sep,
    p.branch,
    p.sep,
    p.gitadd,
    p.gitchange,
    p.gitdelete,
    --
    p.pad,
    p.diagError,
    p.diagWarn,
    p.diagInfo,
    p.diagHint,
    --
    p.sep,
    p.readonly,
    --
    p.encoding,
    p.sep,
    --
    p.lnumcol,
    p.sep,
    --
  }
end

local function whk_init(event, pieces)
  Simple_Status.cache = {}
  for i, e in ipairs(Simple_Status.elements) do
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

    Simple_Status.cache[i] = {
      event = res.event,
      name = res.name,
      stl = res.stl,
    }
  end
  require('statusline.provider').initialized = true
  return table.concat(pieces, '')
end

local stl_render = co.create(function(event)
  local pieces = {}
  while true do
    if not Simple_Status.cache then
      whk_init(event, pieces)
    else
      for i, item in ipairs(Simple_Status.cache) do
        if item.event and vim.tbl_contains(item.event, event) and type(item.stl) == 'function' then
          local comp = Simple_Status.elements[i]
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

function Simple_Status.setup()
  Simple_Status.elements = default()

  api.nvim_create_autocmd({ 'User' }, {
    pattern = { 'LspProgressUpdate', 'GitSignsUpdate' },
    callback = function(arg)
      vim.schedule(function()
        co.resume(stl_render, arg.match)
      end)
    end,
  })

  local events =
  { 'DiagnosticChanged', 'ModeChanged', 'BufEnter', 'BufWritePost', 'LspAttach', 'LspDetach', 'TermClose' }
  api.nvim_create_autocmd(events, {
    callback = function(arg)
      vim.schedule(function()
        co.resume(stl_render, arg.event)
      end)
    end,
  })
end

return Simple_Status
