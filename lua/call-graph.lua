local M = {}

local function lsp_request(client, bufnr, method, params)
  local co = coroutine.running()
  client:request(method, params, function(err, result)
    vim.schedule(function()
      coroutine.resume(co, err, result)
    end)
  end, bufnr)
  return coroutine.yield()
end

local function walk_up(client, bufnr, item, depth, max_depth, visited, tree)
  local key = item.uri .. ':' .. item.name .. ':' .. item.range.start.line .. ':' .. item.range.start.character
  if visited[key] or depth > max_depth then
    return
  end
  visited[key] = true

  local err, callers = lsp_request(client, bufnr, 'callHierarchy/incomingCalls', { item = item })
  if err or not callers then
    return
  end

  for _, caller in ipairs(callers) do
    local child = {
      name = caller.from.name,
      detail = caller.from.detail or '',
      uri = caller.from.uri,
      range = caller.fromRanges[1] or caller.from.range,
      children = {},
    }
    table.insert(tree.children, child)

    local prepare_params = {
      textDocument = { uri = caller.from.uri },
      position = caller.from.selectionRange.start,
    }
    local perr, pitems = lsp_request(client, bufnr, 'textDocument/prepareCallHierarchy', prepare_params)
    if not perr and pitems and #pitems > 0 then
      walk_up(client, bufnr, pitems[1], depth + 1, max_depth, visited, child)
    end
  end
end

local function walk_down(client, bufnr, item, depth, max_depth, visited, tree)
  local key = item.uri .. ':' .. item.name .. ':' .. item.range.start.line .. ':' .. item.range.start.character
  if visited[key] or depth > max_depth then
    return
  end
  visited[key] = true

  local err, callees = lsp_request(client, bufnr, 'callHierarchy/outgoingCalls', { item = item })
  if err or not callees then
    return
  end

  for _, callee in ipairs(callees) do
    if not callee.to.uri:find 'node_modules' then
      local child = {
        name = callee.to.name,
        detail = callee.to.detail or '',
        uri = callee.to.uri,
        range = callee.fromRanges[1] or callee.to.range,
        children = {},
      }
      table.insert(tree.children, child)

      local prepare_params = {
        textDocument = { uri = callee.to.uri },
        position = callee.to.selectionRange.start,
      }
      local perr, pitems = lsp_request(client, bufnr, 'textDocument/prepareCallHierarchy', prepare_params)
      if not perr and pitems and #pitems > 0 then
        walk_down(client, bufnr, pitems[1], depth + 1, max_depth, visited, child)
      end
    end
  end
end

local function render(root)
  local lines = {}
  local function emit(node, indent)
    local prefix = string.rep('  ', indent)
    local short_path = vim.fn.fnamemodify(vim.uri_to_fname(node.uri), ':~:.')
    local loc = short_path .. ':' .. (node.range.start.line + 1)

    if #node.children > 0 then
      table.insert(lines, prefix .. node.name .. ' (' .. loc .. ') {{{')
      for _, child in ipairs(node.children) do
        emit(child, indent + 1)
      end
      table.insert(lines, prefix .. '}}}')
    else
      table.insert(lines, prefix .. node.name .. ' (' .. loc .. ')')
    end
  end

  emit(root, 0)

  vim.cmd 'enew'
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modified = false
  vim.api.nvim_set_option_value('foldmethod', 'marker', { win = 0 })
  vim.api.nvim_set_option_value('foldenable', true, { win = 0 })
end

function M.show_incoming_calls(opts)
  opts = opts or {}
  local max_depth = opts.max_depth or 5
  local bufnr = vim.api.nvim_get_current_buf()

  local clients = vim.lsp.get_clients { bufnr = bufnr }
  if #clients == 0 then
    vim.notify('No LSP client attached', vim.log.levels.WARN)
    return
  end

  local client
  for _, c in ipairs(clients) do
    if c.server_capabilities.callHierarchyProvider then
      client = c
      break
    end
  end
  if not client then
    vim.notify('LSP server does not support callHierarchy', vim.log.levels.WARN)
    return
  end

  coroutine.wrap(function()
    local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
    local err, items = lsp_request(client, bufnr, 'textDocument/prepareCallHierarchy', params)
    if err or not items or #items == 0 then
      vim.notify('No call hierarchy item at cursor', vim.log.levels.WARN)
      return
    end

    local root = { name = items[1].name, uri = items[1].uri, range = items[1].range, children = {} }
    walk_up(client, bufnr, items[1], 0, max_depth, {}, root)

    vim.schedule(function()
      render(root)
    end)
  end)()
end

function M.show_outgoing_calls(opts)
  opts = opts or {}
  local max_depth = opts.max_depth or 5
  local bufnr = vim.api.nvim_get_current_buf()

  local clients = vim.lsp.get_clients { bufnr = bufnr }
  if #clients == 0 then
    vim.notify('No LSP client attached', vim.log.levels.WARN)
    return
  end

  local client
  for _, c in ipairs(clients) do
    if c.server_capabilities.callHierarchyProvider then
      client = c
      break
    end
  end
  if not client then
    vim.notify('LSP server does not support callHierarchy', vim.log.levels.WARN)
    return
  end

  coroutine.wrap(function()
    local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
    local err, items = lsp_request(client, bufnr, 'textDocument/prepareCallHierarchy', params)
    if err or not items or #items == 0 then
      vim.notify('No call hierarchy item at cursor', vim.log.levels.WARN)
      return
    end

    local root = { name = items[1].name, uri = items[1].uri, range = items[1].range, children = {} }
    walk_down(client, bufnr, items[1], 0, max_depth, {}, root)

    vim.schedule(function()
      render(root)
    end)
  end)()
end

vim.api.nvim_create_user_command('CallGraphUp', function(cmd)
  local depth = tonumber(cmd.args) or 5
  M.show_incoming_calls { max_depth = depth }
end, { nargs = '?' })

vim.api.nvim_create_user_command('CallGraphDown', function(cmd)
  local depth = tonumber(cmd.args) or 5
  M.show_outgoing_calls { max_depth = depth }
end, { nargs = '?' })

vim.keymap.set('n', '<leader>ci', ':CallGraphUp 20<CR>', { desc = 'Incoming call graph' })
vim.keymap.set('n', '<leader>co', ':CallGraphDown 20<CR>', { desc = 'Outgoing call graph' })

return M
