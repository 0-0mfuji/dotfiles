vim.o.encoding = 'utf-8' -- Set the encoding to UTF-8 / エンコーディングをUTF-8に設定
vim.o.tabstop = 8 -- Set tab width to 8 spaces / タブ幅を8スペースに設定
vim.o.softtabstop = 4 -- Set the number of spaces a <Tab> counts for in insert mode / 挿入モードで<Tab>がカウントされるスペース数を設定
vim.o.shiftwidth = 4 -- Set the number of spaces for each indentation level / インデントの幅を設定
vim.o.expandtab = true -- Use spaces instead of tabs / タブの代わりにスペースを使用
vim.o.autoindent = true -- Enable automatic indentation / 自動インデントを有効にする
vim.o.smartindent = true -- Enable smart indentation / スマートインデントを有効にする
vim.o.ambiwidth = 'double' -- Set ambiguous character width to double / 曖昧な文字幅をダブルに設定
vim.o.number = true -- Show line numbers / 行番号を表示
vim.o.showmatch = true -- Highlight matching parentheses and brackets / 対応する括弧をハイライト表示
vim.o.incsearch = true -- Enable incremental search / インクリメンタル検索を有効にする
vim.o.ignorecase = true -- Ignore case when searching / 検索時に大文字小文字を区別しない
vim.o.smartcase = true -- Override ignorecase if search pattern contains uppercase letters / 検索パターンに大文字が含まれる場合、ignorecaseを無効にする
vim.o.hlsearch = true -- Highlight search results / 検索結果をハイライト表示
vim.o.matchtime = 1 -- Set the time to highlight matching parentheses and brackets / 対応する括弧のハイライト時間を設定
vim.o.backup = true -- Enable backup files / バックアップファイルを有効にする
vim.o.undofile = true -- Enable persistent undo / 永続的なアンドゥを有効にする
vim.opt.shortmess:append({ I = true }) -- Avoid showing startup message / 起動メッセージを表示しない
vim.opt.undodir = vim.fn.expand('~/.config/nvim/undo/') -- Set the directory for undo files / アンドゥファイルのディレクトリを設定
vim.opt.backupdir = vim.fn.expand('~/.config/nvim/backup/') -- Set the directory for backup files / バックアップファイルのディレクトリを設定
vim.opt.directory = vim.fn.expand('~/.config/nvim/swp/') -- Set the directory for swap files / スワップファイルのディレクトリを設定

vim.g.loaded_netrw = 1 -- Disable netrw as nvim-tree encourages it / nvim-tree推奨のためnetrwを無効にする
vim.g.loaded_netrwPlugin = 1 -- Disable netrw as nvim-tree encourages it / nvim-tree推奨のためnetrwを無効にする

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim" -- Define the path for lazy.nvim / lazy.nvimのパスを定義
if not vim.loop.fs_stat(lazypath) then -- Clone lazy.nvim if it does not exist / lazy.nvimが存在しない場合クローンする
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release / 最新安定版
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath) -- Prepend the lazy.nvim path to runtime path / lazy.nvimのパスをランタイムパスに追加

require('lazy').setup({ -- Setup plugins using lazy.nvim / lazy.nvimを使用してプラグインを設定
  "rebelot/kanagawa.nvim", -- Color scheme / カラースキーム

  "editorconfig/editorconfig-vim", -- Essentials / 基本プラグイン
  'nvim-treesitter/nvim-treesitter', -- Essentials / 基本プラグイン

  "williamboman/mason.nvim", -- LSP plugins / LSPプラグイン
  "williamboman/mason-lspconfig.nvim", -- LSP plugins / LSPプラグイン
  "neovim/nvim-lspconfig", -- LSP plugins / LSPプラグイン

  "github/copilot.vim", -- GitHub Copilot / GitHub Copilot

  "hrsh7th/cmp-nvim-lsp", -- Completion plugins / 補完プラグイン
  "hrsh7th/cmp-buffer", -- Completion plugins / 補完プラグイン
  "hrsh7th/cmp-path", -- Completion plugins / 補完プラグイン
  "hrsh7th/cmp-cmdline", -- Completion plugins / 補完プラグイン
  "hrsh7th/nvim-cmp", -- Completion plugins / 補完プラグイン

  "nvim-tree/nvim-tree.lua", -- File Tree / ファイルツリー

  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.2',
    dependencies = { 'nvim-lua/plenary.nvim' }, -- Fuzzy finder / ファジーファインダー
  },
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }, -- Fuzzy finder / ファジーファインダー

  "nvim-lualine/lualine.nvim", -- Status line / ステータスライン

  {
    'mvllow/modes.nvim',
    tag = 'v0.2.0', -- Change cursor colors based on mode / モードに応じてカーソルの色を変更
  },

  "lewis6991/gitsigns.nvim", -- Git line statuses / Git行ステータス

  {
    "j-hui/fidget.nvim",
    tag = "legacy",
    event = "LspAttach", -- LSP progress UI / LSP進捗UI
  },

  'numToStr/Comment.nvim', -- Comment plugin / コメントプラグイン
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
        require("nvim-surround").setup() -- Surround plugin / 囲みプラグイン
    end
  }
})

require('lualine').setup({ -- Configure lualine status line / lualineステータスラインを設定
  options = {
    icons_enabled = false,
    component_separators = { left = ' ', right = ' ' },
    section_separators = { left = ' ', right = ' ' },
  }
})

require('modes').setup() -- Configure modes plugin / modesプラグインを設定
require('gitsigns').setup() -- Configure gitsigns plugin / gitsignsプラグインを設定
require("fidget").setup() -- Configure fidget plugin / fidgetプラグインを設定

require("nvim-tree").setup({ -- Configure nvim-tree plugin / nvim-treeプラグインを設定
  sort_by = "case_sensitive",
})

local cmp = require('cmp')
cmp.setup({ -- Configure nvim-cmp completion / nvim-cmp補完を設定
  sources = cmp.config.sources({
    {name = 'nvim_lsp'},
    {name = 'nvim_lsp_signature_help'},
    {name = 'path'},
    {name = 'buffer'},
    {name = 'nvim_lua'},
    {name = 'luasnip'},
    {name = 'cmdline'},
    {name = 'git'},
  }),
})

local telescope = require("telescope")
local telescope_actions = require("telescope.actions")
telescope.setup({ -- Configure Telescope fuzzy finder / Telescopeファジーファインダーを設定
  disable_devicons = true,
  defaults = {
      mappings = {
          i = {
              ["<esc>"] = telescope_actions.close,
          },
      },
  },
  fzf = {
    fuzzy = true,
    override_generic_sorter = true,
    override_file_sorter = true,
    case_mode = "smart_case",
  }
})
telescope.load_extension('fzf') -- Load fzf extension for Telescope / Telescope用のfzf拡張をロード

require("mason").setup() -- Setup Mason plugin / Masonプラグインを設定
require("mason-lspconfig").setup({ -- Configure Mason LSP configurations / MasonのLSP設定を構成
  ensure_installed = { "lua_ls", "rust_analyzer", "clangd", "gopls", "tsserver" },
  automatic_installation = true,
})

require('kanagawa').setup({ -- Configure Kanagawa color scheme / Kanagawaカラースキームを設定
  compile = true,
  undercurl = true,
  keywordStyle = { italic = true},
  statementStyle = { bold = true },
  transparent = true,
  terminalColors = true,
  theme = "wave",
  background = {
      dark = "dragon",
      light = "lotus"
  },
})
vim.cmd("colorscheme kanagawa") -- Apply Kanagawa color scheme / Kanagawaカラースキームを適用

local telescope_builtin = require('telescope.builtin')

function file_picker() -- Define file picker function using Telescope / Telescopeを使用してファイルピッカー関数を定義
  telescope_builtin.find_files {
    previewer = false,
    shorten_path = true,
    layout_strategy = "horizontal",
  }
end

vim.g.mapleader = ' ' -- Set leader key to space / リーダーキーをスペースに設定
vim.keymap.set('n', '<leader><Space>', file_picker, {}) -- Define key mappings / キーマッピングを定義
vim.keymap.set('n', '<leader>g', telescope_builtin.live_grep, {})
vim.keymap.set('n', '<leader>b', telescope_builtin.buffers, {})
vim.keymap.set('n', '<leader>t', "<cmd>NvimTreeToggle<CR>", {})
vim.keymap.set('n', '<leader>w', '<C-w>k', {})
vim.keymap.set('n', '<leader>s', '<C-w>j', {})
vim.keymap.set('n', '<leader>a', '<C-w>h', {})
vim.keymap.set('n', '<leader>d', '<C-w>l', {})
vim.keymap.set('n', '<leader>|', '<C-w>v', {})
vim.keymap.set('n', '<leader>-', '<C-w>s', {})
vim.keymap.set('n', '<leader>=', '<C-w>=', {})
vim.keymap.set('n', '<leader>c', '<C-w>c', {})
vim.keymap.set('n', '<leader>q', '<cmd>q<CR>', {})
vim.keymap.set('n', '<C-s>', '<cmd>w<CR>', {})
vim.keymap.set('i', '<C-s>', '<cmd>w<CR>', {})
vim.keymap.set('i', '<M-BS>', '<C-w>', {})

vim.api.nvim_create_autocmd("VimEnter", { -- Open file picker on Vim startup if no file is opened / Vim起動時にファイルが開かれていない場合にファイルピッカーを開く
  callback = function()
    if vim.fn.argv(0) == '' then
      file_picker()
    end
  end
})
