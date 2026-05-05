vim.g.mapleader = " "

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.tabstop = 4

vim.opt.rtp:prepend(vim.fn.stdpath("config") .. "/lazy/lazy.nvim")

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

vim.o.completeopt = "menu,menuone,noselect"

local on_attach = function(_, bufnr)
  local bufmap = function(mode, lhs, rhs)
    vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, { 
        noremap = true, 
        silent = true 
    })
  end

  bufmap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
  bufmap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")
  bufmap("n", "K",  "<cmd>lua vim.lsp.buf.hover()<CR>")
  bufmap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
  bufmap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>")
  bufmap("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>")

  bufmap("n", "<leader>e", "<cmd>lua vim.diagnostic.open_float()<CR>")
  bufmap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>") 
  bufmap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>")
  bufmap("n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>")
end

vim.lsp.config("clangd", {
  on_attach = on_attach,
  capabilities = require("cmp_nvim_lsp").default_capabilities()
})
vim.lsp.enable({ "clangd" })
