-- Autocommands -----------------------------------------------------------------

vim.api.nvim_create_autocmd("User", {
	pattern = "OilActionsPost",
	callback = function(event)
		if event.data.actions[1].type == "move" then
			require("snacks").rename.on_rename_file(event.data.actions[1].src_url, event.data.actions[1].dest_url)
		end
	end,
})

-- Restore cursor to previous position
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function(args)
		local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
		local line_count = vim.api.nvim_buf_line_count(args.buf)
		if mark[1] > 0 and mark[1] <= line_count then
			vim.api.nvim_win_set_cursor(0, mark)
			vim.schedule(function()
				vim.cmd("normal! zz")
			end)
		end
	end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.hl_op()
	end,
})

-- Highlight on hover
vim.api.nvim_create_autocmd("CursorMoved", {
	group = vim.api.nvim_create_augroup("LspReferenceHighlight", { clear = true }),
	callback = function()
		if vim.fn.mode() ~= "i" then
			local clients = vim.lsp.get_clients({ bufnr = 0 })
			local supports_highlight = false
			for _, client in ipairs(clients) do
				if client.server_capabilities.documentHighlightProvider then
					supports_highlight = true -- Found a supporting client no need to check others
					break
				end
			end

			if supports_highlight then
				vim.lsp.buf.clear_references()
				vim.lsp.buf.document_highlight()
			end
		end
	end,
})

vim.api.nvim_create_autocmd("CursorMovedI", {
	group = "LspReferenceHighlight",
	callback = function()
		vim.lsp.buf.clear_references()
	end,
})

-- Don't auto-comment new lines
vim.api.nvim_create_autocmd("BufEnter", { command = [[set formatoptions-=cro]] })

-- Curosr line (active)
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
	group = vim.api.nvim_create_augroup("active_cursorline", { clear = true }),
	callback = function()
		vim.opt_local.cursorline = true
	end,
})

-- Curosr line (inactive)
vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
	group = "active_cursorline",
	callback = function()
		vim.opt_local.cursorline = false
	end,
})

-- LSP Attach

local function client_supports_method(client, method, bufnr)
	if vim.fn.has("nvim-0.11") == 1 then
		return client:supports_method(method, bufnr)
	end
	return client.supports_method(method, { bufnr = bufnr })
end

local function buf_map_if_free(bufnr, mode, lhs, rhs, opts)
	opts = opts or {}
	opts.buffer = bufnr
	opts.silent = opts.silent ~= false

	-- maparg() returns info about the effective map; `buffer == 1` means buffer-local
	local existing = vim.fn.maparg(lhs, mode, false, true)
	if existing and existing.buffer == 1 then
		return
	end

	vim.keymap.set(mode, lhs, rhs, opts)
end

local lsp_attach_group = vim.api.nvim_create_augroup("lsp-attach", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
	group = lsp_attach_group,
	callback = function(event)
		local bufnr = event.buf
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if not client then
			return
		end

		-- mappings: do not clobber ftplugin buffer-local maps
		buf_map_if_free(bufnr, "n", "gl", vim.diagnostic.open_float)
		buf_map_if_free(bufnr, "n", "K", vim.lsp.buf.hover)
		buf_map_if_free(bufnr, "n", "gs", vim.lsp.buf.signature_help)
		buf_map_if_free(bufnr, "n", "gD", vim.lsp.buf.declaration)

		buf_map_if_free(bufnr, "n", "<leader>la", vim.lsp.buf.code_action)
		buf_map_if_free(bufnr, "n", "<leader>ff", vim.lsp.buf.format)

		buf_map_if_free(bufnr, "n", "<leader>v", function()
			vim.cmd.vsplit()
			vim.lsp.buf.definition()
		end)

		-- highlights (optional): only if supported
		if client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, bufnr) then
			local hl_group = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })

			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = bufnr,
				group = hl_group,
				callback = vim.lsp.buf.document_highlight,
			})

			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = bufnr,
				group = hl_group,
				callback = vim.lsp.buf.clear_references,
			})

			vim.api.nvim_create_autocmd("LspDetach", {
				group = vim.api.nvim_create_augroup("lsp-detach", { clear = false }),
				callback = function(detach_event)
					vim.lsp.buf.clear_references()
					vim.api.nvim_clear_autocmds({ group = hl_group, buffer = detach_event.buf })
				end,
			})
		end
	end,
})
