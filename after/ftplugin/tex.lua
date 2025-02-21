local output_dir = 'output' -- Relative to the current file's directory

-- Get the PDF path based on the current file
local function get_pdf_path()
  local file_dir = vim.fn.expand('%:p:h')
  local file_name = vim.fn.expand('%:t:r')
  return file_dir .. '/' .. output_dir .. '/' .. file_name .. '.pdf'
end

-- Manage the Zathura viewer
local function manage_zathura(pdf_path)
  if not pdf_path or pdf_path == '' then
    print('Invalid PDF path.')
    return
  end

  local zathura_running = vim.fn.systemlist('pgrep -f "zathura ' .. pdf_path .. '"')

  if #zathura_running == 0 then
    local ok, err = pcall(function()
      return vim.fn.jobstart({ 'zathura', pdf_path }, { detach = true })
    end)

    if not ok then
      print('Failed to start Zathura:', err)
    end
  else
    print('Zathura is already running for this file.')
  end
end

-- Open Zathura
local function open_zathura()
  local pdf_path = get_pdf_path()
  if pdf_path == '' then
    print('Error: Could not determine PDF path.')
    return
  end

  print('Opening Zathura for ' .. pdf_path)
  if vim.fn.filereadable(pdf_path) == 1 then
    manage_zathura(pdf_path)
  else
    print('PDF not found, please compile the LaTeX file first.')
  end
end

-- Close Zathura
local function close_zathura()
  local pdf_path = get_pdf_path()
  if pdf_path == '' then
    print('Error: Could not determine PDF path.')
    return
  end

  vim.fn.system({ 'pkill', '-f', 'zathura ' .. pdf_path })
end

-- Key mappings
vim.keymap.set('n', '<leader>ll', '<cmd>VimtexCompile<CR>', {
  desc = 'Compile LaTeX using VimTeX',
  noremap = true,
  silent = true,
})

vim.keymap.set('n', '<leader>lv', open_zathura, {
  desc = 'View PDF in Zathura',
  noremap = true,
  silent = true,
})

vim.keymap.set('n', '<leader>lc', close_zathura, {
  desc = 'Close Zathura',
  noremap = true,
  silent = true,
})

-- Auto-close Zathura when the buffer is closed
vim.api.nvim_create_autocmd('BufDelete', {
  pattern = '*.tex', -- Trigger for TeX files
  callback = function()
    close_zathura()
  end,
})
