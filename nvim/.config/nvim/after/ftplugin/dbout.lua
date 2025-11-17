-- Minimal, reliable SSMS-like formatter for Dadbod UI results (filetype=dbout).
-- Assumes sqlcmd wrapper emits TSV (-s <TAB>). This formatter:
--  • Computes max width per column across ALL rows incl. header
--  • Clamps widths to [MIN .. MAX]
--  • Truncates with ellipsis and pads with spaces (no tabs in output)
--  • Keeps trailer lines (e.g., "(N rows affected)") unchanged at the end

local SEP = "\t"

local function dwidth(s)
	return vim.fn.strdisplaywidth(s or "")
end

local function truncate_ellipsis(s, w, ell)
	s = s or ""
	if dwidth(s) <= w then
		return s
	end
	local need = math.max(w - dwidth(ell), 0)
	if need <= 0 then
		return ell
	end
	local acc, out, i = 0, {}, 1
	while i <= #s do
		local b = s:byte(i)
		local len = (b < 0x80) and 1 or (b < 0xE0) and 2 or (b < 0xF0) and 3 or 4
		local ch = s:sub(i, i + len - 1)
		local dw = dwidth(ch)
		if acc + dw > need then
			break
		end
		out[#out + 1] = ch
		acc = acc + dw
		i = i + len
	end
	return table.concat(out) .. ell
end

local function split_tsv(line)
	local out, start = {}, 1
	while true do
		local i = line:find(SEP, start, true)
		if not i then
			out[#out + 1] = line:sub(start)
			break
		end
		out[#out + 1] = line:sub(start, i - 1)
		start = i + 1
	end
	return out
end

local function is_dash_row(cells)
	for _, c in ipairs(cells) do
		c = (c or "")
		if c == "" or c:find("[^%-]") then
			return false
		end
	end
	return true
end

local function format_dbout_buffer()
	if vim.env.DBUI_NO_FORMAT == "1" then
		return
	end

	local MAXW = tonumber(vim.env.DBUI_COL_MAX) or 40
	local MINW = tonumber(vim.env.DBUI_COL_MIN) or 3
	local PAD = tonumber(vim.env.DBUI_COL_PAD) or 1
	local ELLIPS = vim.env.DBUI_ELLIPSIS or "…"
	local padstr = string.rep(" ", PAD)

	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	if #lines == 0 then
		return
	end

	-- Separate table lines (contain tabs) from trailers (no tabs)
	local tbl, trailers = {}, {}
	for _, l in ipairs(lines) do
		if l:find(SEP, 1, true) then
			tbl[#tbl + 1] = l
		elseif l ~= "" then
			trailers[#trailers + 1] = l
		end
	end
	if #tbl == 0 then
		return
	end

	-- Parse rows, trim cells
	local rows, max_cols = {}, 0
	for _, l in ipairs(tbl) do
		local cells = split_tsv(l)
		for i = 1, #cells do
			cells[i] = vim.trim(cells[i])
		end
		rows[#rows + 1] = cells
		if #cells > max_cols then
			max_cols = #cells
		end
	end

	-- Drop sqlcmd dashed separator row if present as row 2
	if #rows >= 2 and is_dash_row(rows[2]) then
		table.remove(rows, 2)
	end
	if max_cols == 0 then
		return
	end

	-- Compute widths across ALL rows (incl. header), then clamp to [MINW, MAXW]
	local widths = {}
	for c = 1, max_cols do
		local w = MINW
		for r = 1, #rows do
			local dw = dwidth(rows[r][c] or "")
			if dw > w then
				w = dw
			end
		end
		if w > MAXW then
			w = MAXW
		end
		widths[c] = w
	end

	-- Build formatted output (NO TABS)
	local out = {}

	local function fmt_row(cells)
		local parts = {}
		for c = 1, max_cols do
			local cell = truncate_ellipsis(cells[c] or "", widths[c], ELLIPS)
			local dw = dwidth(cell)
			if dw < widths[c] then
				cell = cell .. string.rep(" ", widths[c] - dw)
			end
			parts[#parts + 1] = cell
		end
		return table.concat(parts, padstr)
	end

	-- header
	out[#out + 1] = fmt_row(rows[1])
	-- separator
	local segs = {}
	for c = 1, max_cols do
		segs[c] = string.rep("-", widths[c])
	end
	out[#out + 1] = table.concat(segs, padstr)
	-- body
	for r = 2, #rows do
		out[#out + 1] = fmt_row(rows[r])
	end
	-- trailers (unchanged)
	for _, t in ipairs(trailers) do
		out[#out + 1] = t
	end

	-- Force write even if buffer is nomodifiable
	local was_mod = vim.bo[bufnr].modifiable
	local was_ro = vim.bo[bufnr].readonly
	if not was_mod then
		vim.bo[bufnr].modifiable = true
	end
	if was_ro then
		vim.bo[bufnr].readonly = false
	end

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, out)

	-- IMPORTANT: leave the buffer writable so DBUI can write the next result
	-- (Putting it back to nomodifiable/readonly blocks subsequent queries.)
	-- If you really want to mark it clean, you can clear the 'modified' flag:
	pcall(function()
		vim.bo[bufnr].modified = false
	end)
end

-- Buffer-local command; run it IN the dbout (results) window
vim.api.nvim_buf_create_user_command(0, "DBFormatSSMS", function()
	format_dbout_buffer()
end, {})

-- === Auto-run formatter using debounce after last change (no racing) ===

local function _dbout_has_tabs(bufnr)
	if not vim.api.nvim_buf_is_loaded(bufnr) then
		return false
	end
	local ln = vim.api.nvim_buf_line_count(bufnr)
	if ln == 0 then
		return false
	end
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, math.min(400, ln), false)
	for _, l in ipairs(lines) do
		if l:find("\t", 1, true) then
			return true
		end
	end
	return false
end

-- Debounce state per buffer (no libuv userdata in b:vars)
local DEBOUNCE = {} -- bufnr -> { scheduled = boolean, last_tick = integer }

local function _schedule_debounced_format(bufnr, delay_ms)
	local state = DEBOUNCE[bufnr] or { scheduled = false, last_tick = 0 }
	DEBOUNCE[bufnr] = state

	state.last_tick = vim.api.nvim_buf_get_changedtick(bufnr)
	if state.scheduled then
		-- already waiting; the new tick will be checked when it fires
		return
	end
	state.scheduled = true

	vim.defer_fn(function()
		-- Timer fired: only format if buffer didn't change again
		if not vim.api.nvim_buf_is_loaded(bufnr) then
			DEBOUNCE[bufnr] = nil
			return
		end
		local tick_now = vim.api.nvim_buf_get_changedtick(bufnr)
		if tick_now ~= state.last_tick then
			-- Something changed again; reschedule one more time
			state.scheduled = false
			_schedule_debounced_format(bufnr, delay_ms)
			return
		end

		-- We are idle: if raw TSV is present, format once
		if _dbout_has_tabs(bufnr) and vim.bo[bufnr].filetype == "dbout" then
			vim.api.nvim_buf_call(bufnr, function()
				pcall(format_dbout_buffer)
			end)
		end

		-- done
		DEBOUNCE[bufnr] = nil
	end, delay_ms or 150)
end

local aug = vim.api.nvim_create_augroup("DBUI_SSMS_AutoFormatDebounce", { clear = true })

-- Start the debounce when a dbout buffer appears
vim.api.nvim_create_autocmd("FileType", {
	group = aug,
	pattern = "dbout",
	callback = function(args)
		_schedule_debounced_format(args.buf, 150)
	end,
})

-- Each time DBUI writes more result lines, restart the debounce window
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
	group = aug,
	pattern = "*",
	callback = function(args)
		local b = args.buf
		if vim.bo[b].filetype == "dbout" then
			_schedule_debounced_format(b, 150)
		end
	end,
})

-- Optional: if results buffer window is (re)shown, ensure a format will happen soon
vim.api.nvim_create_autocmd({ "BufWinEnter", "BufEnter" }, {
	group = aug,
	pattern = "*",
	callback = function(args)
		local b = args.buf
		if vim.bo[b].filetype == "dbout" then
			_schedule_debounced_format(b, 150)
		end
	end,
})
