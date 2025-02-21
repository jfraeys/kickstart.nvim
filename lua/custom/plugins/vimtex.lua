return {
  'lervag/vimtex',
  lazy = true,
  ft = { 'tex', 'latex' },
  config = function()
    -- Use Zathura for PDF viewing
    vim.g.vimtex_view_method = 'zathura'
    vim.g.vimtex_view_zathura_options = '--synctex-forward @line:@col:@pdf @src'

    -- Use latexmk for compilation
    vim.g.vimtex_compiler_method = 'latexmk'
    vim.g.vimtex_compiler_latexmk_engines = {
      _ = '-pdf -xelatex -synctex=1 -interaction=nonstopmode',
    }

    -- Custom output directory
    vim.g.vimtex_compiler_latexmk = {
      out_dir = 'output', -- Replace with your preferred output directory
    }

    -- Disable default mappings if you're managing mappings separately
    vim.g.vimtex_mappings_enabled = 0
  end,
}
