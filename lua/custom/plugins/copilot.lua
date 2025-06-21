local node_path = vim.fn.executable('node') == 1 and vim.fn.exepath('node') or 'node'

return {
  'CopilotC-Nvim/CopilotChat.nvim',
  dependencies = {
    {
      'zbirenbaum/copilot.lua',
      node_cmd = node_path,
      opts = {
        suggestion = {
          auto_trigger = true,
          keymap = {
            accept_word = '<M-u>',
            accept_line = '<M-i>',
            next = '<M-[>',
            previous = '<M-]>',
          },
        },
      },
    },
    { 'nvim-lua/plenary.nvim', branch = 'master' },
  },
  cmd = 'CopilotChat',
  event = 'VeryLazy',
  build = 'make tiktoken',
  opts = {
    debug = false,
    show_help = 'yes',
    prompts = {
      Explain = 'Please explain how the following code works.',
      Review = 'Please review the following code and provide suggestions for improvement.',
      Tests = 'Please explain how the selected code works, then generate unit tests for it.',
      Refactor = 'Please refactor the following code to improve its clarity and readability.',
    },
  },
  keys = {
    { '<leader>zq', '<cmd>CopilotChatClose<cr>', desc = 'Close CopilotChat' },
    { '<leader>zz', '<cmd>CopilotChat<cr>', desc = 'Open CopilotChat' },
    { '<leader>ze', '<cmd>CopilotChatExplain<cr>', desc = 'Explain code', mode = { 'n', 'v' } },
    { '<leader>zr', '<cmd>CopilotChatReview<cr>', desc = 'Review code', mode = { 'n', 'v' } },
    { '<leader>zt', '<cmd>CopilotChatTests<cr>', desc = 'Generate tests', mode = { 'n', 'v' } },
    { '<leader>zf', '<cmd>CopilotChatRefactor<cr>', desc = 'Refactor code', mode = { 'n', 'v' } },
    { '<leader>zo', '<cmd>CopilotChatOptimize<cr>', desc = 'Optimize code', mode = { 'n', 'v' } },
    { '<leader>zd', '<cmd>CopilotChatDocs<cr>', desc = 'Generate docs', mode = { 'n', 'v' } },
    { '<leader>zp', '<cmd>CopilotChatToggle<cr>', desc = 'Toggle CopilotChat' },
  },
}
