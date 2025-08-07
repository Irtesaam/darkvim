--[[

TODO: The very first thing you should do is to run the command `:Tutor` in Neovim.

  when you're stuck or confused -> :help
  If you experience any errors while trying to install kickstart, run `:checkhealth` for more info.

]]

-- Config starts from here

-- Set <space> as the leader key
-- set localleader key for buffer specific mappings
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
require 'options'

-- [[ Basic Keymaps ]]
require 'keymaps'

-- [[ Install `lazy.nvim` plugin manager ]]
require 'lazy-bootstrap'

-- [[ Configure and install plugins ]]
require 'lazy-plugins'
