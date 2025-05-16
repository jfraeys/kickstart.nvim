local function shorter_name(filename)
  return filename:gsub(os.getenv('HOME'), '~'):gsub('/bin/python', '')
end

return {
  {
    'linux-cultist/venv-selector.nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
      { 'nvim-telescope/telescope.nvim', branch = '0.1.x', dependencies = { 'nvim-lua/plenary.nvim' } },
      'mfussenegger/nvim-dap',
      'mfussenegger/nvim-dap-python',
    },
    ft = 'python', -- Load only for Python files
    branch = 'regexp', -- This is the regexp branch, use this for the new version
    opts = {
      options = {
        -- If you put the callback here as a global option.
        -- Its used for all searches (including the default ones by the plugin).
        on_telescope_result_callback = shorter_name,
      },
      search = {
        my_venvs = {
          command = 'fd -H -I python$ ~/Documents/Projects/',
          on_telescope_result_callback = shorter_name,
        },
        my_conda_envs = {
          command = 'fd -t l python$ /usr/local/Caskroom/miniforge/base/envs/',
          on_telescope_result_callback = shorter_name,
        },
      },
    },
    keys = {
      { ',v', '<cmd>VenvSelect<cr>' },
    },
  },
}
