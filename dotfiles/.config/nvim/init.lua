vim.g.mapleader = " "

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.tabstop = 4

-- helper command for opening this file
vim.api.nvim_create_user_command("RC", function()
  vim.cmd("edit " .. vim.env.MYVIMRC)
end, {})

-- create new buffer with terminal,
-- such that it's immediately ready for commands
vim.api.nvim_create_user_command("SH", function() 
  local function feedkeys(str)
    local bytes = vim.api.nvim_replace_termcodes(str, true, false, true)
    vim.api.nvim_feedkeys(bytes, "n", false)
  end
  vim.cmd("terminal $SHELL")
  vim.schedule(function() feedkeys("<C-\\><C-n>"); feedkeys("$"); feedkeys("i") end)
end, {})
-- allow easy exiting from terminal
vim.api.nvim_set_keymap("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })

-- ensure lazy can be found
vim.opt.rtp:prepend(vim.fn.stdpath("config") .. "/lazy/lazy.nvim")

-- configure plugins
require("lazy").setup({
  {
    "neovim/nvim-lspconfig",
    config = function()
        vim.lsp.config("clangd", {})
    end
  },
  {
      "hrsh7th/nvim-cmp",
      dependencies = { "hrsh7th/cmp-nvim-lsp" },
      config = function()
        local cmp = require("cmp")
        cmp.setup({
          mapping = {
            ["<Tab>"] = cmp.mapping.select_next_item({ 
                behavior = cmp.SelectBehavior.Insert
            }),
            ["<S-Tab>"] = cmp.mapping.select_prev_item({ 
                behavior = cmp.SelectBehavior.Insert
            }),
            ["<CR>"] = cmp.mapping.confirm({ 
                select = true
            }),
          },
          sources = {
            { name = "nvim_lsp" },
          },
        })
      end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ':TSUpdate',
    config = function()
      require'nvim-treesitter'.setup {
        install_dir = vim.fn.stdpath('data') .. '/site'
      }
      local parsers = { 'bash', 'c', 'lua', 'markdown' }
      require('nvim-treesitter').install(parsers)
    end
  },
  {
      "akinsho/bufferline.nvim",
      dependencies = "nvim-tree/nvim-web-devicons",
      config = function()
        require("bufferline").setup({})
      end
    }
})

-- completion behavior for clangd and other LSP
vim.o.completeopt = "menu,menuone"

-- bindings for clangd
local clangd_on_attach = function(_, bufnr)
  local bufmap = function(mode, lhs, rhs)
    vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, { noremap = true, silent = true })
  end

  -- jump to definitions or declarations
  bufmap("n", "<leader>.d", "<cmd>lua require('jump_to_def_or_decl')()<CR>")
  -- see info about current token
  bufmap("n", "<leader>.k", "<cmd>lua vim.lsp.buf.hover()<CR>")
  -- open a list of references
  bufmap("n", "<leader>.l", "<cmd>lua vim.lsp.buf.references()<CR>")
  -- refactor
  bufmap("n", "<leader>.r", "<cmd>lua vim.lsp.buf.rename()<CR>")
  -- code actions
  bufmap("n", "<leader>.a", "<cmd>lua vim.lsp.buf.code_action()<CR>")

  -- step through errors/warnings
  bufmap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>") 
  bufmap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>")
  -- see information about current error/warning
  bufmap("n", "<leader>.e", "<cmd>lua vim.diagnostic.open_float()<CR>")
  -- see a list of all errors/warnings in current file
  bufmap("n", "<leader>.E", "<cmd>lua vim.diagnostic.setloclist()<CR>")
end

-- configure and enable clangd
vim.lsp.config("clangd", {
  on_attach = clangd_on_attach,
  capabilities = require("cmp_nvim_lsp").default_capabilities()
})
vim.lsp.enable({ "clangd" })
