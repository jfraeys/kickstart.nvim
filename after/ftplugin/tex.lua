-- Set the output directory for PDFs (relative to the current file's directory)
local output_dir = 'output'

-- Escape spaces in file paths to prevent issues in commands that involve paths with spaces
---@param path string: The path to escape
---@return string: The escaped path (spaces replaced with '\ ')
---@usage escape_spaces('path/to/file') -> 'path/to/file'
local function escape_spaces(path)
  return path:gsub(' ', '\\ ')
end

-- Get the full path to the generated PDF file based on the current LaTeX file
---@return string: The full path to the PDF file
---@usage get_pdf_path() -> 'path/to/output/file.pdf'
local function get_pdf_path()
  local file_dir = vim.fn.expand('%:p:h') -- Get the directory of the current file
  local file_name = vim.fn.expand('%:t:r') -- Get the base name of the current file (without extension)
  return file_dir .. '/' .. output_dir .. '/' .. file_name .. '.pdf' -- Construct the full path to the PDF
end

-- Check if Zathura is running for the specific PDF file
---@param pdf_path string: The path to the PDF file
---@return boolean: true if Zathura is running for the given PDF, false otherwise
local function is_zathura_running(pdf_path)
  -- Use pgrep to check if any Zathura process is running with this PDF file
  local zathura_running = vim.fn.systemlist('pgrep -f "zathura ' .. escape_spaces(pdf_path) .. '"')
  return #zathura_running > 0 -- Return true if a matching process is found
end

-- Manage Zathura: start it if not running or refresh it if already open
---@param pdf_path string: The path to the PDF file
local function manage_zathura(pdf_path)
  -- Ensure the PDF path is valid
  if not pdf_path or pdf_path == '' then
    print('Invalid PDF path.')
    return
  end

  -- If Zathura is not running for the PDF, start it
  if not is_zathura_running(pdf_path) then
    local ok, err = pcall(function()
      -- Start Zathura in detached mode (runs independently of Vim)
      return vim.fn.jobstart({ 'zathura', pdf_path }, { detach = true })
    end)

    if not ok then
      -- Print an error message if starting Zathura fails
      print('Failed to start Zathura:', err)
    end
  end
end

-- Open Zathura for the PDF if it exists, or notify the user to compile the LaTeX file
---@param pdf_path string: The path to the PDF file
---@usage open_zathura('path/to/file.pdf')
local function open_zathura(pdf_path)
  if vim.fn.filereadable(pdf_path) == 1 then
    -- If the PDF exists, manage Zathura (open or refresh it)
    manage_zathura(pdf_path)
  else
    -- If the PDF doesn't exist, prompt the user to compile the LaTeX file
    print('PDF not found, please compile the LaTeX file first.')
  end
end

-- Close Zathura for the given PDF file
---@param pdf_path string: The path to the PDF file
---@usage close_zathura('path/to/file.pdf')
local function close_zathura(pdf_path)
  if vim.fn.filereadable(pdf_path) == 1 then
    -- Use pkill to close any running Zathura process for this PDF
    vim.fn.system({ 'pkill', '-f', 'zathura ' .. escape_spaces(pdf_path) })
  end
end

-- Compile the LaTeX document using VimTeX and then open the resulting PDF in Zathura
vim.keymap.set('n', '<leader>ll', function()
  vim.cmd('VimtexCompile') -- Compile the LaTeX document using VimTeX

  local pdf_path = get_pdf_path() -- Get the path to the generated PDF

  if vim.fn.filereadable(pdf_path) == 1 then
    -- If the PDF exists after compilation, open it in Zathura
    manage_zathura(pdf_path)
  else
    -- Notify the user if the PDF doesn't exist (compilation failed)
    print('Compilation failed or PDF not found.')
  end
end, {
  desc = 'Compile LaTeX using VimTeX and open PDF in Zathura', -- Description for the keymap
  noremap = true, -- Do not allow remapping
  silent = true, -- Do not show command in the command line
})

-- Keymap to open Zathura and view the PDF
vim.keymap.set('n', '<leader>lv', function()
  open_zathura(get_pdf_path()) -- Open the generated PDF in Zathura
end, {
  desc = 'View PDF in Zathura', -- Description for the keymap
  noremap = true, -- Do not allow remapping
  silent = true, -- Do not show command in the command line
})

-- Keymap to close Zathura for the current PDF
vim.keymap.set('n', '<leader>lc', function()
  close_zathura(get_pdf_path()) -- Close Zathura for the generated PDF
end, {
  desc = 'Close Zathura', -- Description for the keymap
  noremap = true, -- Do not allow remapping
  silent = true, -- Do not show command in the command line
})

vim.keymap.set('n', '<leader>lr', function()
  local pdf_path = get_pdf_path()
  if vim.fn.filereadable(pdf_path) == 1 then
    -- Force Zathura to reload the PDF
    vim.fn.system({ 'pkill', '-HUP', 'zathura' })
    manage_zathura(pdf_path) -- Reopen PDF in Zathura
  else
    print('PDF not found, please compile the LaTeX file first.')
  end
end, {
  desc = 'Reload PDF in Zathura',
  noremap = true,
  silent = true,
})

-- Open the compilation log in a vertical split window
vim.keymap.set('n', '<leader>lk', function()
  vim.cmd('VimtexLog') -- Show the compilation log
end, {
  desc = 'Show LaTeX compilation logs',
  noremap = true,
  silent = true,
})

-- Close Zathura when Vim exits
vim.api.nvim_create_autocmd('VimLeave', {
  pattern = '*.tex',
  callback = function()
    local pdf_path = get_pdf_path()
    if vim.fn.filereadable(pdf_path == 1) then
      -- If the PDF exists, close Zathura for the generated PDF
      close_zathura(pdf_path)
    end
  end,
})

-- Automatically open Zathura when the TeX file is saved and the PDF exists
vim.api.nvim_create_autocmd('User', {
  pattern = 'VimtexPostCompile',
  callback = function()
    local pdf_path = get_pdf_path() -- Get the generated PDF path
    if vim.fn.filereadable(pdf_path) == 1 then
      -- If PDF exists, open it in Zathura
      manage_zathura(pdf_path)
    else
      -- If PDF doesn't exist, notify the user
      print('Compilation failed or PDF not found.')
    end
  end,
})
