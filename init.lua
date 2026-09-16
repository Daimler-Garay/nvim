-- Pre-plugin Configs
require("plugins.rustaceanvim")
-- Plugins ---------------------------------------------------------------------

local plugins = {
	{ src = "https://github.com/chomosuke/typst-preview.nvim" },
	{ src = "https://github.com/folke/snacks.nvim" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	{ src = "https://github.com/L3MON4D3/LuaSnip" },
	{ src = "https://github.com/windwp/nvim-autopairs" },
	{ src = "https://github.com/j-hui/fidget.nvim" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
	{ src = "https://github.com/MunifTanjim/nui.nvim" },
	{ src = "https://github.com/mrcjkb/rustaceanvim" },
	{ src = "https://github.com/saecki/crates.nvim" },
	{ src = "https://github.com/saghen/blink.cmp", version = vim.version.range("*") },
	{ src = "https://github.com/GustavEikaas/easy-dotnet.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
	{ src = "https://github.com/alexghergh/nvim-tmux-navigation" },
	{ src = "https://github.com/mfussenegger/nvim-dap" },
	{ src = "https://github.com/igorlfs/nvim-dap-view" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
}

vim.pack.add(plugins)

require("core.options")
require("core.keymaps")
require("core.autocmd")

-- Snacks ------------------------------------------------------------------------

require("snacks").setup({
	bigfile = { enabled = true },
	bufdelete = { enabled = true },
	dashboard = { enabled = false },
	dim = { enabled = true },
	explorer = { enabled = false },
	image = { enabled = true },
	indent = { enabled = true },
	input = { enabled = false },
	picker = { enabled = true },
	notifier = { enabled = false },
	quickfile = { enabled = true },
	rename = { enabled = true },
	scope = { enabled = true },
	scroll = { enabled = true },
	statuscolumn = { enabled = true },
	words = { enabled = true },
})

-- Dotnet ------------------------------------------------------------------------

require("easy-dotnet").setup({
	picker = "snacks",
})

-- Lualine -----------------------------------------------------------------------

local job_indicator = { require("easy-dotnet.ui-modules.jobs").lualine }

require("lualine").setup({
	sections = {
		lualine_a = { "mode", job_indicator },
	},
})

-- LSP ---------------------------------------------------------------------------

vim.lsp.enable({
	"tinymist",
	"lua_ls",
	"ts_ls",
	"yamlls",
	"jsonls",
	"ty",
	"marksman",
	"html",
	"cssls",
	"bashls",
	"postgres_lsp",
})

require("fidget").setup()

-- Theme -------------------------------------------------------------------------

require("catppuccin").setup({
	term_colors = true,
	dim_inactive = {
		enabled = true,
	},
})
vim.cmd.colorscheme("catppuccin-mocha")

-- Snippets ----------------------------------------------------------------------

local function get_snippet_path()
	local sysname = vim.loop.os_uname().sysname
	if sysname == "Windows_NT" then
		return vim.fn.expand("~/AppData/Local/nvim/snippets/")
	end
	return vim.fn.expand("~/.config/nvim/snippets/")
end

require("luasnip").setup({ enable_autosnippets = true })
require("luasnip.loaders.from_lua").lazy_load({ paths = get_snippet_path() })

-- Mason

require("mason").setup({
	registries = {
		"github:mason-org/mason-registry",
		"github:Crashdummyy/mason-registry",
	},
})

-- Crates

require("crates").setup({
	lsp = {
		enabled = true,
		actions = true,
		completion = true,
		hover = true,
	},
	completion = {
		crates = {
			enabled = true,
			max_results = 8,
			min_chars = 3,
		},
	},
})

-- Autopairs ---------------------------------------------------------------------

require("nvim-autopairs").setup()

-- Conform -----------------------------------------------------------------------
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
		typescript = { "prettier" },
		json = { "prettier" },
		yaml = { "prettier" },
		html = { "prettier" },
		css = { "prettier" },
		javascript = { "prettier" },
		bash = { "beautysh" },
		zsh = { "beautysh" },
		markdown = { "prettier" },
		kdl = { "kdlfmt" },
		sql = { "pg_format" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
})
-- Oil ---------------------------------------------------------------------------

require("oil").setup({
	view_options = { show_hidden = true },
	lsp_file_methods = {
		enabled = true,
		timeout_ms = 1000,
	},
	columns = { "icon" },
})

-- Blink -------------------------------------------------------------------------
require("plugins.completions")

-- Markdown
require("render-markdown").setup({
	enabled = false,
	completions = { blink = { enabled = true } },
})

-- Dap

require("plugins.debug")
