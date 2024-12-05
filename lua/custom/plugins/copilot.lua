return {
  'zbirenbaum/copilot.lua',
  cmd = 'Copilot',
  event = 'InsertEnter',
  opts = {
    suggestion = {
      auto_trigger = true,
      filetypes = {
        ['.'] = true,
      },
      keymap = {
        accept_word = '<M-u>',
        accept_line = '<M-i>',
        next = 'M-[',
        previous = 'M-]',
      },
    },
  },
}
