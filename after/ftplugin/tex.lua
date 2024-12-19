-- Define the output directory path
local output_dir = vim.fn.expand('%:p:h') .. '/output/'

-- Helper function to manage Zathura instances
local function manage_zathura(pdf_path)
  -- Check if Zathura is already running for the given PDF
  local zathura_running = vim.fn.systemlist('pgrep -f "zathura ' .. pdf_path .. '"')

  if #zathura_running == 0 then
    -- Start Zathura if it's not running
    vim.fn.jobstart({ 'zathura', pdf_path }, { detach = true, stdout = '/dev/null', stderr = '/dev/null' })
    return true
  else
    -- Inform the user that Zathura is already running
    print('Zathura is already running for this file.')
    return false
  end
end

local function get_pdf_path()
  return output_dir .. vim.fn.expand('%:t:r') .. '.pdf'
end

local function open_zathura()
  local pdf_path = get_pdf_path()
  if vim.fn.filereadable(pdf_path) == 1 then
    manage_zathura(pdf_path)
  else
    print('PDF not found, please compile the LaTeX file first.')
  end
end

-- Function to close the Zathura instance for the current PDF
local function close_zathura()
  local pdf_path = get_pdf_path()
  vim.fn.system({ 'pkill', '-f', 'zathura ' .. pdf_path })
end

-- Keybinding to compile LaTeX to PDF using xelatex with latexmk and output to the "output" directory
vim.keymap.set(
  'n',
  '<leader>ll',
  ':!mkdir -p ' .. output_dir .. ' && latexmk -f -pdf -xelatex -output-directory=' .. output_dir .. ' -synctex=1 %<CR>',
  {
    desc = 'Compile LaTeX to PDF using xelatex with SyncTeX in the output directory',
    noremap = true,
    silent = true,
  }
)

-- Keybinding to view the compiled PDF in Zathura from the output directory
vim.keymap.set('n', '<leader>lv', function()
  open_zathura()
end, {
  desc = 'View PDF in Zathura from the output directory',
  noremap = true,
  silent = true,
})

-- Keybinding to close Zathura for the current PDF
vim.keymap.set('n', '<leader>lc', close_zathura, {
  desc = 'Close Zathura instance for the current PDF',
  noremap = true,
  silent = true,
})

-- Cooldown period for launching Zathura
local last_open_time = 0
local cooldown_period = 5 -- Cooldown period in seconds

-- Autocmd to automatically open the PDF in Zathura when a .tex file is opened
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = '*.tex',
  callback = function()
    local current_time = vim.fn.reltimefloat(vim.fn.reltime())
    if current_time - last_open_time < cooldown_period then
      print('Cooldown active, skipping Zathura launch.')
      return
    end

    last_open_time = current_time

    open_zathura()
  end,
})

-- Autocmd to close all Zathura instances related to the current file when exiting Neovim
vim.api.nvim_create_autocmd('VimLeavePre', {
  callback = function()
    close_zathura()
  end,
})
