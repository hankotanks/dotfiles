local function make_params(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1

  return {
    textDocument = { uri = vim.uri_from_bufnr(bufnr) },
    position = { line = row, character = col },
  }
end

local function jump_to_location(loc)
  if not loc then return false end

  local target_buf, target_line, target_col
  if loc.targetUri and loc.targetRange then
    target_buf = vim.uri_to_bufnr(loc.targetUri)
    target_line = loc.targetRange.start.line
    target_col  = loc.targetRange.start.character
  elseif loc.uri and loc.range then
    target_buf = vim.uri_to_bufnr(loc.uri)
    target_line = loc.range.start.line
    target_col  = loc.range.start.character
  else
    return false
  end

  vim.fn.bufload(target_buf)
  vim.api.nvim_set_current_buf(target_buf)
  vim.api.nvim_buf_set_option(target_buf, "buflisted", true)

  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_cursor(win, { (target_line or 0)+1, target_col or 0 })
  return true
end

function jump_to_def_or_decl()
  local bufnr = vim.api.nvim_get_current_buf()
  if not bufnr then return end

  local clients = vim.lsp.get_clients({bufnr = bufnr})
  if #clients == 0 then return end

  local params = make_params(bufnr)
  local cur_file = vim.api.nvim_buf_get_name(bufnr)
  local cur_line = params.position.line

  local function pick_target(result)
    if not result then return nil end

    for _, loc in ipairs(result) do
      local target_file, target_line
      if loc.targetUri and loc.targetRange then
        target_file = vim.uri_to_fname(loc.targetUri)
        target_line = loc.targetRange.start.line
      elseif loc.uri and loc.range then
        target_file = vim.uri_to_fname(loc.uri)
        target_line = loc.range.start.line
      else
        goto continue
      end

      if target_file ~= cur_file or target_line ~= cur_line then return loc end
      ::continue::
    end
    return nil
  end

  -- try definition
  local result = vim.lsp.buf_request_sync(bufnr, "textDocument/definition", params, 1000)
  local loc = nil
  if result then
    for _, res in pairs(result) do
      loc = pick_target(res.result)
      if loc then break end
    end
  end

  -- else, declaration
  if not loc then
    result = vim.lsp.buf_request_sync(bufnr, "textDocument/declaration", params, 1000)
    if result then
      for _, res in pairs(result) do
        loc = pick_target(res.result)
        if loc then break end
      end
    end
  end

  -- perform jump
  if loc then jump_to_location(loc) end
end

return jump_to_def_or_decl
