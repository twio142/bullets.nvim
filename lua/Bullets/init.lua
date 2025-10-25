---@diagnostic disable: undefined-global
-- bullets.nvim
-- Author: Keith Miyake
-- Rewritten from https://github.com/dkarter/bullets.vim
-- License: GPLv3, MIT
-- Copyright (c) 2024 Keith Miyake
-- See LICENSE

-- --------------------------------------------
-- Setup
-- templated from <https://github.com/echasnovski/mini.nvim>
-- MIT License

-- Copyright (c) 2021 Evgeni Chasnovski

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
-- --------------------------------------------

local Bullets = {}
local H = {}

Bullets.setup = function(config)
	_G.Bullets = Bullets
	config = H.setup_config(config)
	H.apply_config(config)
end

Bullets.config = {
	colon_indent = true,
	delete_last_bullet = true,
	empty_buffers = true,
	file_types = { "markdown", "text", "gitcommit" },
	line_spacing = 1,
	set_mappings = true,
	outline_levels = { "ROM", "ABC", "num", "abc", "rom", "std*", "std-", "std+" },
	renumber = true,
	alpha = {
		len = 2,
	},
	checkbox = {
		nest = true,
		markers = " .oOx",
		toggle_partials = true,
	},
}
H.default_config = Bullets.config

H.setup_config = function(config)
	-- General idea: if some table elements are not present in user-supplied
	-- `config`, take them from default config

	config = vim.tbl_deep_extend("force", H.default_config, config or {})
	vim.validate("colon_indent", config.colon_indent, "boolean", true)
	vim.validate("delete_last_bullet", config.delete_last_bullet, "boolean", true)
	vim.validate("empty_buffers", config.empty_buffers, "boolean", true)
	vim.validate("file_types", config.file_types, "table", true)
	vim.validate("line_spacing", config.line_spacing, "number", true)
	vim.validate("set_mappings", config.set_mappings, "boolean", true)
	vim.validate("custom_mappings", config.custom_mappings, "table", true)
	vim.validate("outline_levels", config.outline_levels, "table", true)
	vim.validate("renumber", config.renumber, "boolean", true)
	vim.validate("alpha", config.alpha, "table", true)
	vim.validate("checkbox", config.checkbox, "table", true)
	vim.validate("alpha.len", config.alpha.len, "number", true)
	vim.validate("checkbox.nest", config.checkbox.nest, "boolean", true)
	vim.validate("checkbox.markers", config.checkbox.markers, "string", true)
	vim.validate("checkbox.toggle_partials", config.checkbox.toggle_partials, "boolean", true)
	return config
end

H.apply_config = function(config)
	local power = config.alpha.len
	config.abc_max = -1
	while power >= 0 do
		config.abc_max = config.abc_max + 26 ^ power
		power = power - 1
	end
	Bullets.config = config

	vim.api.nvim_create_user_command("BulletDemote", function()
		Bullets.change_bullet_level(-1, 0)
	end, {})
	vim.api.nvim_create_user_command("BulletDemoteVisual", function()
		Bullets.change_bullet_level(-1, 1)
	end, { range = true })
	vim.api.nvim_create_user_command("BulletPromote", function()
		Bullets.change_bullet_level(1, 0)
	end, {})
	vim.api.nvim_create_user_command("BulletPromoteVisual", function()
		Bullets.change_bullet_level(1, 1)
	end, { range = true })
	vim.api.nvim_create_user_command("InsertNewBullet", function()
		Bullets.insert_new_bullet("o")
	end, {})
	vim.api.nvim_create_user_command("SelectList", function()
		Bullets.select_list()
	end, {})
	vim.api.nvim_create_user_command("SelectListText", function()
		Bullets.select_list_text()
	end, {})
	vim.api.nvim_create_user_command("FindPrevListSibling", function()
		Bullets.find_list_sibling(true)
	end, {})
	vim.api.nvim_create_user_command("FindNextListSibling", function()
		Bullets.find_list_sibling()
	end, {})
	vim.api.nvim_create_user_command("FindListParent", function()
		Bullets.find_list_parent()
	end, {})
	vim.api.nvim_create_user_command("RenumberList", function()
		Bullets.renumber_whole_list()
	end, {})
	vim.api.nvim_create_user_command("RenumberSelection", function()
		Bullets.renumber_selection()
	end, { range = true })
	vim.api.nvim_create_user_command("SelectCheckbox", function()
		Bullets.select_checkbox(false)
	end, {})
	vim.api.nvim_create_user_command("SelectCheckboxInside", function()
		Bullets.select_checkbox(true)
	end, {})
	vim.api.nvim_create_user_command("ToggleCheckbox", function()
		Bullets.toggle_checkbox()
	end, {})
	vim.api.nvim_create_user_command("ToggleList", function()
		Bullets.toggle_list()
	end, { range = true })
	vim.api.nvim_create_user_command("ToggleNumberedList", function()
		Bullets.toggle_numbered_list()
	end, { range = true })
	vim.api.nvim_create_user_command("SetCheckboxMarker", function()
		Bullets.set_checkbox_marker()
	end, { range = true })
	vim.api.nvim_create_user_command("CheckMove", function()
		Bullets.check_move()
	end, {})

	vim.api.nvim_set_keymap("i", "<Plug>(bullets-newline-cr)", "", {
		noremap = true,
		silent = true,
		callback = function()
			Bullets.insert_new_bullet("cr")
		end,
	})
	vim.api.nvim_set_keymap(
		"n",
		"<Plug>(bullets-newline-o)",
		"<cmd>InsertNewBullet<cr>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_set_keymap("n", "<Plug>(bullets-renumber)", "<cmd>RenumberList<cr>", { noremap = true, silent = true })
	vim.api.nvim_set_keymap(
		"x",
		"<Plug>(bullets-renumber)",
		"<cmd>RenumberSelection<cr>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_set_keymap(
		"n",
		"<Plug>(bullets-select-list)",
		"<cmd>SelectList<cr>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_set_keymap(
		"x",
		"<Plug>(bullets-select-list)",
		"<cmd>SelectList<cr>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_set_keymap(
		"o",
		"<Plug>(bullets-select-list)",
		"<cmd>SelectList<cr>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_set_keymap(
		"n",
		"<Plug>(bullets-select-list-text)",
		"<cmd>SelectListText<cr>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_set_keymap(
		"v",
		"<Plug>(bullets-select-list-text)",
		"<cmd>SelectListText<cr>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_set_keymap(
		"o",
		"<Plug>(bullets-select-list-text)",
		"<cmd>SelectListText<cr>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_set_keymap(
		"n",
		"<Plug>(bullets-prev-list-sibling)",
		"<cmd>FindPrevListSibling<cr>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_set_keymap(
		"x",
		"<Plug>(bullets-prev-list-sibling)",
		"<cmd>FindPrevListSibling<cr>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_set_keymap(
		"n",
		"<Plug>(bullets-next-list-sibling)",
		"<cmd>FindNextListSibling<cr>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_set_keymap(
		"x",
		"<Plug>(bullets-next-list-sibling)",
		"<cmd>FindNextListSibling<cr>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_set_keymap(
		"n",
		"<Plug>(bullets-list-parent)",
		"<cmd>FindListParent<cr>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_set_keymap(
		"x",
		"<Plug>(bullets-list-parent)",
		"<cmd>FindListParent<cr>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_set_keymap(
		"n",
		"<Plug>(bullets-toggle-checkbox)",
		"<cmd>ToggleCheckbox<cr>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_set_keymap(
		"x",
		"<Plug>(bullets-toggle-checkbox)",
		"<cmd>ToggleCheckbox<cr>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_set_keymap(
		"n",
		"<Plug>(bullets-toggle-list)",
		"<cmd>ToggleList<cr>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_set_keymap(
		"x",
		"<Plug>(bullets-toggle-list)",
		"<cmd>ToggleList<cr>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_set_keymap(
		"n",
		"<Plug>(bullets-toggle-numbered-list)",
		"<cmd>ToggleNumberedList<cr>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_set_keymap(
		"x",
		"<Plug>(bullets-toggle-numbered-list)",
		"<cmd>ToggleNumberedList<cr>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_set_keymap(
		"n",
		"<Plug>(bullets-set-checkbox-marker)",
		"<cmd>SetCheckboxMarker<cr>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_set_keymap(
		"x",
		"<Plug>(bullets-set-checkbox-marker)",
		"<cmd>SetCheckboxMarker<cr>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_set_keymap("n", "<Plug>(bullets-check-move)", "<cmd>CheckMove<cr>", { noremap = true, silent = true })
	vim.api.nvim_set_keymap("i", "<Plug>(bullets-demote)", "<C-O>:BulletDemote<cr>", { noremap = true, silent = true })
	vim.api.nvim_set_keymap("n", "<Plug>(bullets-demote)", "<cmd>BulletDemote<cr>", { noremap = true, silent = true })
	vim.api.nvim_set_keymap(
		"v",
		"<Plug>(bullets-demote)",
		"<cmd>BulletDemoteVisual<cr>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_set_keymap(
		"i",
		"<Plug>(bullets-promote)",
		"<C-O>:BulletPromote<cr>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_set_keymap("n", "<Plug>(bullets-promote)", "<cmd>BulletPromote<cr>", { noremap = true, silent = true })
	vim.api.nvim_set_keymap(
		"v",
		"<Plug>(bullets-promote)",
		"<cmd>BulletPromoteVisual<cr>",
		{ noremap = true, silent = true }
	)

	local mappings = {
		{ "i", "<cr>", "<Plug>(bullets-newline-cr)" },
		{ "n", "o", "<Plug>(bullets-newline-o)" },
		{ { "n", "v" }, "gN", "<Plug>(bullets-renumber)" },
		{ "n", "<leader>x", "<Plug>(bullets-toggle-checkbox)" },
		{ "i", "<C-t>", "<Plug>(bullets-demote)" },
		{ "n", ">>", "<Plug>(bullets-demote)" },
		{ "v", ">", "<Plug>(bullets-demote)" },
		{ "i", "<C-d>", "<Plug>(bullets-promote)" },
		{ "n", "<<", "<Plug>(bullets-promote)" },
		{ "v", "<", "<Plug>(bullets-promote)" },
	}

	if not config.set_mappings then
		mappings = config.custom_mappings
	end

	if mappings ~= nil and #mappings > 0 then
		H.buf_map(mappings)
	end
end

H.buf_map = function(mappings)
	vim.api.nvim_create_augroup("BulletMaps", { clear = true })

	local set_mappings = function(ctx)
		for _, mapping in ipairs(mappings) do
			local modes = mapping[1]
			if type(modes) == "string" then
				modes = { modes }
			end
			local lhs = mapping[2]
			local rhs = mapping[3]
			local desc = mapping.desc or ""
			for _, mode in ipairs(modes) do
				vim.api.nvim_buf_set_keymap(ctx.buf, mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
			end
		end
	end

	vim.api.nvim_create_autocmd("Filetype", {
		pattern = Bullets.config.file_types,
		group = "BulletMaps",
		callback = set_mappings,
	})

	if Bullets.config.empty_buffers then
		vim.api.nvim_create_autocmd("BufEnter", {
			group = "BulletMaps",
			callback = function(ctx)
				if ctx.match == "" then
					set_mappings(ctx)
				end
			end,
		})
	end
end

H.define_bullet = function(match, btype, line_num)
	local bullet = {}
	if next(match) ~= nil then
		bullet.type = btype
		bullet.bullet_length = vim.str_utfindex(match[3], "utf-8")
		bullet.leading_space = match[4]
		bullet.bullet = match[5]
		bullet.checkbox_marker = type(match[6]) ~= "number" and match[6] or ""
		bullet.closure = type(match[7]) ~= "number" and match[7] or ""
		bullet.trailing_space = match[8]
		bullet.text_after_bullet = match[9]
		bullet.starting_at_line_num = line_num
	end
	return bullet
end

H.parse_bullet = function(line_num, input_text)
	local std_bullet_regex = "^((%s*)([%+%-%*%.])()()(%s+))(.*)"
	local checkbox_bullet_regex = "^((%s*)([%-%*%+]) %[([" .. Bullets.config.checkbox.markers .. " xX])%]()(%s+))(.*)"
	local num_bullet_regex = "^((%s*)(%d+)()([%.%)])(%s+))(.*)"
	local rom_bullet_regex =
		"\\v\\C^((\\s*)(M{0,4}%(CM|CD|D?C{0,3})%(XC|XL|L?X{0,3})%(IX|IV|V?I{0,3})|m{0,4}%(cm|cd|d?c{0,3})%(xc|xl|l?x{0,3})%(ix|iv|v?i{0,3}))()(\\.|\\))(\\s+))(.*)"
	local max = tostring(Bullets.config.alpha.len)
	local az = "[%a]"
	local abc = ""
	for _ = 1, max do
		abc = abc .. az .. "?"
	end
	local abc_bullet_regex = "^((%s*)(" .. abc .. ")()([%.%)])(%s+))(.*)"

	local matches = { string.find(input_text, checkbox_bullet_regex) }

	if next(matches) ~= nil then
		return H.define_bullet(matches, "chk", line_num)
	end
	matches = { string.find(input_text, std_bullet_regex) }
	if next(matches) ~= nil then
		return H.define_bullet(matches, "std", line_num)
	end
	matches = { string.find(input_text, num_bullet_regex) }
	if next(matches) ~= nil then
		return H.define_bullet(matches, "num", line_num)
	end
	matches = vim.fn.matchlist(input_text, rom_bullet_regex)
	if next(matches) ~= nil then
		table.insert(matches, 1, 0)
		return H.define_bullet(matches, "rom", line_num)
	end
	matches = { string.find(input_text, abc_bullet_regex) }
	if next(matches) ~= nil then
		return H.define_bullet(matches, "abc", line_num)
	end

	return {}
end

H.closest_bullet_types = function(from_line_num, max_indent)
	local lnum = from_line_num
	local ltxt = vim.fn.getline(lnum)
	local curr_indent = vim.fn.indent(lnum)
	local bullet_kinds = H.parse_bullet(lnum, ltxt)

	if max_indent < 0 then
		return {}
	end

	-- Support for wrapped text bullets, even if the wrapped line is not indented
	-- It considers a blank line as the end of a bullet
	-- DEMO: http//raw.githubusercontent.com/dkarter/bullets.vim/master/img/wrapped-bullets.gif
	while
		lnum > 1
		and (max_indent < curr_indent or next(bullet_kinds) == nil)
		and (curr_indent ~= 0 or next(bullet_kinds) ~= nil)
		and not string.match(ltxt, "^%s*$")
	do
		if next(bullet_kinds) ~= nil then
			lnum = lnum - Bullets.config.line_spacing
		else
			lnum = lnum - 1
		end
		ltxt = vim.fn.getline(lnum)
		bullet_kinds = H.parse_bullet(lnum, ltxt)
		curr_indent = vim.fn.indent(lnum)
	end
	return bullet_kinds
end

H.contains_type = function(bullet_types, type)
	for _, types in ipairs(bullet_types) do
		if type == types.type then
			return true
		end
	end

	return false
end

H.find_by_type = function(bullet_types, type)
	for _, bullet in ipairs(bullet_types) do
		if type == bullet.type then
			return bullet
		end
	end
	return {}
end

H.has_rom_or_abc = function(bullet_types)
	local has_rom = H.contains_type(bullet_types, "rom")
	local has_abc = H.contains_type(bullet_types, "abc")
	return has_rom or has_abc
end

H.has_chk_or_std = function(bullet_types)
	local has_chk = H.contains_type(bullet_types, "chk")
	local has_std = H.contains_type(bullet_types, "std")
	return has_chk or has_std
end

H.dec2abc = function(dec, islower)
	local a = "A"
	if islower then
		a = "a"
	end

	local rem = (dec - 1) % 26
	local abc = string.char(rem + a:byte())
	if dec <= 26 then
		return abc
	else
		return H.dec2abc((dec - 1) / 26, islower) .. abc
	end
end

H.abc2dec = function(abc)
	local cba = string.lower(abc)
	local a = "a"
	local abc1 = string.sub(cba, 1, 1)
	local dec = abc1:byte() - a:byte() + 1
	if vim.str_utfindex(cba) == 1 then
		return dec
	else
		return math.floor(26 ^ vim.str_utfindex(abc) - 1) * dec
			+ H.abc2dec(string.sub(abc, 1, vim.str_utfindex(abc) - 1))
	end
end

H.resolve_rom_or_abc = function(bullet_types)
	local first_type = bullet_types
	local prev_search_starting_line = first_type.starting_at_line_num - Bullets.config.line_spacing
	local bullet_indent = vim.fn.indent(first_type.starting_at_line_num)
	local prev_bullet_types = H.closest_bullet_types(prev_search_starting_line, bullet_indent)

	while next(prev_bullet_types) ~= nil and bullet_indent <= vim.fn.indent(prev_search_starting_line) do
		prev_search_starting_line = prev_search_starting_line - Bullets.config.line_spacing
		prev_bullet_types = H.closest_bullet_types(prev_search_starting_line, bullet_indent)
	end

	if next(prev_bullet_types) == nil or bullet_indent > vim.fn.indent(prev_search_starting_line) then
		-- can't find previous bullet - so we probably have a rom i. bullet
		return H.find_by_type(bullet_types, "rom")
	elseif #prev_bullet_types == 1 and H.has_rom_or_abc(prev_bullet_types) then
		-- previous bullet is conclusive, use it's type to continue
		if H.abc2dec(prev_bullet_types.bullet) - H.abc2dec(first_type.bullet) == 0 then
			return H.find_by_type(bullet_types, prev_bullet_types[1].type)
		end
	end
	if H.has_rom_or_abc(prev_bullet_types) then
		-- inconclusive - keep searching up recursively
		local prev_bullet = H.resolve_rom_or_abc(prev_bullet_types)
		return H.find_by_type(bullet_types, prev_bullet.type)
	else
		-- parent has unrelated bullet type, we'll go with rom
		return H.find_by_type(bullet_types, "rom")
	end
end

H.resolve_chk_or_std = function(bullet_types)
	-- if it matches both regular and checkbox it is most likely a checkbox
	return H.find_by_type(bullet_types, "chk")
end

H.resolve_bullet_type = function(bullet_types)
	if next(bullet_types) == nil then
		return {}
	elseif H.has_rom_or_abc(bullet_types) then
		return H.resolve_rom_or_abc(bullet_types)
	elseif H.has_chk_or_std(bullet_types) then
		return H.resolve_chk_or_std(bullet_types)
	else
		return bullet_types -- assume the first bullet type
	end
end

-- Roman numeral conversion {{{
-- <http//gist.github.com/efrederickson/4080372>
H.num_to_rom = function(s, islower) --s = tostring(s)
	local numbers = { 1, 5, 10, 50, 100, 500, 1000 }
	local chars = { "i", "v", "x", "l", "c", "d", "m" }
	if not s or s ~= s then
		error("Unable to convert to number")
	end
	if s == math.huge then
		error("Unable to convert infinity")
	end
	s = math.floor(s)
	if s <= 0 then
		return s
	end
	local ret = ""
	for i = #numbers, 1, -1 do
		local num = numbers[i]
		while s - num >= 0 and s > 0 do
			ret = ret .. chars[i]
			s = s - num
		end
		for j = 1, i - 1 do
			local n2 = numbers[j]
			if s - (num - n2) >= 0 and s < num and s > 0 and num - n2 ~= n2 then
				ret = ret .. chars[j] .. chars[i]
				s = s - (num - n2)
				break
			end
		end
	end
	if islower then
		return ret
	else
		return string.upper(ret)
	end
end

H.rom_to_num = function(s)
	local map = {
		i = 1,
		v = 5,
		x = 10,
		l = 50,
		c = 100,
		d = 500,
		m = 1000,
	}
	s = string.lower(s)
	local ret = 0
	local i = 1
	while i <= vim.str_utfindex(s) do
		--for i = 1, len() do
		local c = string.sub(s, i, i)
		if c ~= " " then -- allow spaces
			local m = map[c] or error("Unknown Roman Numeral '" .. c .. "'")

			local next = string.sub(s, i + 1, i + 1)
			local nextm = map[next]

			if next and nextm then
				if nextm > m then
					-- if string[i] < string[i + 1] then result += string[i + 1] - string[i]
					-- This is used instead of programming in IV = 4, IX = 9, etc, because it is
					-- more flexible and possibly more efficient
					ret = ret + (nextm - m)
					i = i + 1
				else
					ret = ret + m
				end
			else
				ret = ret + m
			end
		end
		i = i + 1
	end
	return ret
end
-- }}}

H.next_rom_bullet = function(bullet)
	local islower = bullet.bullet == string.lower(bullet.bullet)
	return H.num_to_rom(H.rom_to_num(bullet.bullet) + 1, islower)
end

H.next_abc_bullet = function(bullet)
	local islower = bullet.bullet == string.lower(bullet.bullet)
	return H.dec2abc(H.abc2dec(bullet.bullet) + 1, islower)
end

H.next_num_bullet = function(bullet)
	return bullet.bullet + 1
end

H.next_chk_bullet = function(bullet)
	return string.sub(bullet.bullet, 1, 1) .. " [" .. string.sub(Bullets.config.checkbox.markers, 1, 1) .. "]"
end

H.next_bullet_str = function(bullet)
	local bullet_type = bullet.type
	local next_bullet_marker = ""

	if bullet_type == "rom" then
		next_bullet_marker = H.next_rom_bullet(bullet)
	elseif bullet_type == "abc" then
		next_bullet_marker = H.next_abc_bullet(bullet)
	elseif bullet_type == "num" then
		next_bullet_marker = H.next_num_bullet(bullet)
	elseif bullet_type == "chk" then
		next_bullet_marker = H.next_chk_bullet(bullet)
	else
		next_bullet_marker = bullet.bullet
	end
	return bullet.leading_space .. next_bullet_marker .. bullet.closure .. bullet.trailing_space
end

H.line_ends_in_colon = function(lnum)
	local line = vim.fn.getline(lnum)
	return string.sub(line, vim.str_utfindex(line, "utf-8")) == ":"
end

H.change_line_bullet_level = function(direction, lnum)
	local curr_line = H.parse_bullet(lnum, vim.fn.getline(lnum))

	if direction == 1 then
		if next(curr_line) ~= nil and vim.fn.indent(lnum) == 0 then
			-- Promoting a bullet at the highest level will delete the bullet
			vim.fn.setline(lnum, curr_line[0].text_after_bullet)
			return
		else
			vim.cmd(lnum .. "normal! <<")
		end
	else
		vim.cmd(lnum .. "normal! >>")
	end

	if next(curr_line) == nil then
		-- If the current line is not a bullet then don't do anything else.
		-- TODO: feedkeys
		local insert_mode = vim.fn.mode() == "i"

		if insert_mode then
			vim.cmd("startinsert!")
		end

		local keys = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
		vim.api.nvim_feedkeys(keys, "n", true)

		return
	end

	local curr_indent = vim.fn.indent(lnum)
	local curr_bullet = H.closest_bullet_types(lnum, curr_indent)
	curr_bullet = H.resolve_bullet_type(curr_bullet)

	curr_line = curr_bullet.starting_at_line_num
	local closest_bullet = H.closest_bullet_types(curr_line - Bullets.config.line_spacing, curr_indent)
	closest_bullet = H.resolve_bullet_type(closest_bullet)

	if next(closest_bullet) == nil then
		-- If there is no parent/sibling bullet then this bullet shouldn't change.
		return
	end

	local islower = closest_bullet.bullet == string.lower(closest_bullet.bullet)
	local closest_indent = vim.fn.indent(closest_bullet.starting_at_line_num)
	local closest_type = islower and closest_bullet.type or string.upper(closest_bullet.type)
	if closest_bullet.type == "std" then
		-- Append the bullet marker to the type, e.g., 'std*'
		closest_type = closest_type .. closest_bullet.bullet
	end

	local bullets_outline_levels = Bullets.config.outline_levels
	local closest_index = -1
	for i, j in ipairs(bullets_outline_levels) do
		if closest_type == j then
			closest_index = i
			break
		end
	end
	if closest_index == -1 then
		-- We are in a list using markers that aren't specified in
		-- bullets_outline_levels so we shouldn't try to change the current
		-- bullet.
		return
	end

	local bullet_str = ""
	if curr_indent == closest_indent then
		-- The closest bullet is a sibling so the current bullet should
		-- increment to the next bullet marker.

		-- local next_bullet = H.next_bullet_str(closest_bullet)
		-- bullet_str = pad_to_length(next_bullet, closest_bullet.bullet_length) .. curr_bullet.text_after_bullet
		bullet_str = H.next_bullet_str(closest_bullet) .. curr_bullet.text_after_bullet
	elseif closest_index + 1 > #bullets_outline_levels and curr_indent > closest_indent then
		-- The closest bullet is a parent and its type is the last one defined in
		-- g:bullets_outline_levels so keep the existing bullet.
		-- TODO: Might make an option for whether the bullet should stay or be
		-- deleted when demoting past the end of the defined bullet types.
		return
	elseif closest_index + 1 <= #bullets_outline_levels or curr_indent < closest_indent then
		-- The current bullet is a child of the closest bullet so figure out
		-- what bullet type it should have and set its marker to the first
		-- character of that type.

		local next_type = bullets_outline_levels[closest_index + 1]
		local next_islower = next_type == string.lower(next_type)
		-- local trailing_space = ' '
		curr_bullet.closure = closest_bullet.closure

		-- set the bullet marker to the first character of the new type
		local next_num
		if next_type == "rom" or next_type == "ROM" then
			next_num = H.num_to_rom(1, next_islower)
		elseif next_type == "abc" or next_type == "ABC" then
			next_num = H.dec2abc(1, next_islower)
		elseif next_type == "num" then
			next_num = "1"
		else
			-- standard bullet; the last character of next_type contains the bullet
			-- symbol to use
			next_num = string.sub(next_type, -1)
			curr_bullet.closure = ""
		end

		bullet_str = curr_bullet.leading_space
			.. next_num
			.. curr_bullet.closure
			.. curr_bullet.trailing_space
			.. curr_bullet.text_after_bullet
	else
		-- We're outside of the defined outline levels
		bullet_str = curr_bullet.leading_space .. curr_bullet.text_after_bullet
	end

	-- Apply the new bullet
	vim.fn.setline(lnum, bullet_str)
end

Bullets.change_bullet_level = function(direction, is_visual)
	-- Changes the bullet level for each of the selected lines
	local sel = H.get_selection(is_visual)
	for lnum = sel.start_line, sel.end_line do
		H.change_line_bullet_level(direction, lnum)
	end
	if Bullets.config.renumber then
		-- Pass the current visual selection so that it gets reset after
		-- renumbering the list.
		Bullets.renumber_whole_list()
	end
	H.set_selection(sel)
end

H.first_bullet_line = function(line_num, min_indent)
	-- returns the line number of the first bullet in the list containing the
	-- given line number, up to the first blank line
	-- returns -1 if lnum is not in a list
	-- Optional argument: only consider bullets at or above this indentation
	local indent = min_indent or 0
	if indent < 0 then
		-- sanity check
		return -1
	end
	local first_line = line_num
	local lnum = line_num - Bullets.config.line_spacing
	local curr_indent = vim.fn.indent(lnum)
	local bullet_kinds = H.closest_bullet_types(lnum, curr_indent)

	while lnum >= 1 and curr_indent >= indent and next(bullet_kinds) ~= nil do
		first_line = lnum
		lnum = lnum - Bullets.config.line_spacing
		curr_indent = vim.fn.indent(lnum)
		bullet_kinds = H.closest_bullet_types(lnum, curr_indent)
	end
	return first_line
end

H.last_bullet_line = function(line_num, min_indent)
	-- returns the line number of the last bullet in the list containing the
	-- given line number, down to the end of the list
	-- returns -1 if lnum is not in a list
	-- Optional argument: only consider bullets at or above this indentation
	local indent = min_indent or 0
	local lnum = line_num
	local buf_end = vim.fn.line("$")
	local last_line = -1
	local curr_indent = vim.fn.indent(lnum)
	local bullet_kinds = H.closest_bullet_types(lnum, curr_indent)
	local blank_lines = 0
	local list_end = false

	if indent < 0 then
		-- sanity check
		return -1
	end

	while lnum <= buf_end and not list_end and curr_indent >= indent do
		if next(bullet_kinds) ~= nil then
			last_line = lnum
			blank_lines = 0
		else
			blank_lines = blank_lines + 1
			list_end = blank_lines >= Bullets.config.line_spacing
		end
		lnum = lnum + 1
		curr_indent = vim.fn.indent(lnum)
		bullet_kinds = H.closest_bullet_types(lnum, curr_indent)
	end
	return last_line
end

H.get_selection = function(is_visual)
	local sel = {}
	local mode = ""
	if is_visual ~= 0 then
		mode = vim.fn.visualmode()
	end
	if mode == "v" or mode == "V" or mode == "\\<C-v>" then
		-- local start_line, start_col = vim.fn.getpos("'<")[2], vim.fn.getpos("'>")[3]
		local start_line = { unpack(vim.fn.getpos("'<"), 2, 3) }
		sel.start_line = start_line[1]
		sel.start_offset = vim.str_utfindex(vim.fn.getline(sel.start_line)) - start_line[2]
		-- local end_line, end_col = vim.fn.getpos("'>")[2], vim.fn.getpos("'>")[3]
		local end_line = { unpack(vim.fn.getpos("'>"), 2, 3) }
		sel.end_line = end_line[1]
		sel.end_offset = vim.str_utfindex(vim.fn.getline(sel.end_line)) - end_line[2]
		sel.visual_mode = mode
	else
		sel.start_line = vim.fn.line(".")
		sel.start_offset = vim.str_utfindex(vim.fn.getline(sel.start_line)) - vim.fn.col(".")
		sel.end_line = sel.start_line
		sel.end_offset = sel.start_offset
		sel.visual_mode = ""
	end
	return sel
end

H.set_selection = function(sel)
	local start_col = vim.str_utfindex(vim.fn.getline(sel.start_line)) - sel.start_offset
	local end_col = vim.str_utfindex(vim.fn.getline(sel.end_line)) - sel.end_offset
	vim.fn.cursor(sel.start_line, start_col)
	if sel.start_line ~= sel.end_line or start_col ~= end_col then
		-- if sel.visual_mode == "<C-v>" then
		-- broken, need to figure out how to escape \<C-v>
		--   vim.cmd("normal! <C-v>")
		-- else
		if sel.visual_mode == "V" or sel.visual_mode == "v" then
			vim.cmd("normal! v")
		end
		-- end
		vim.fn.cursor(sel.end_line, end_col)
	end
end

-- Checkboxes --------------------------------------------- {{{
H.find_checkbox_position = function(lnum)
	local line_text = vim.fn.getline(lnum)
	return vim.fn.matchend(line_text, "\\v\\s*(\\*|-) \\[") + 1
end

Bullets.select_checkbox = function(inner)
	local lnum = vim.fn.line(".")
	local checkbox_col = H.find_checkbox_position(lnum)

	if checkbox_col then
		vim.fn.setpos(".", { 0, lnum, checkbox_col })

		-- decide if we need to select the whole checkbox with brackets or just the
		-- inside of it
		if inner then
			vim.cmd("normal! vi[")
		else
			vim.cmd("normal! va[")
		end
	end
end

H.set_checkbox = function(lnum, marker)
	local curline = vim.fn.getline(lnum)
	local initpos = vim.fn.getpos(".")
	local pos = H.find_checkbox_position(lnum)
	if pos >= 0 then
		local front = string.sub(curline, 1, pos - 1)
		local back = string.sub(curline, pos + 1)
		vim.fn.setline(lnum, front .. marker .. back)
		vim.fn.setpos(".", initpos)
	end
end

Bullets.cycle_checkbox_marker = function()
	-- toggle checkbox on the current line, cycle through the pre-defined markers
	local pattern = "^(%s*[-*] )%[(.)%] "
	local row = vim.api.nvim_win_get_cursor(0)[1]
	local line = vim.fn.getline(row)
	local _, marker = line:match(pattern)
	if not marker then
		return
	end
	local idx = Bullets.config.checkbox.markers:find(marker, 1, true)
	if not idx then
		marker = " "
	else
		idx = idx + 1
		if idx > #Bullets.config.checkbox.markers then
			idx = 1
		end
		marker = Bullets.config.checkbox.markers:sub(idx, idx)
	end
	line = line:gsub(pattern, "%1[" .. marker .. "] ")
	vim.fn.setline(row, line)
end

Bullets.toggle_checkbox = function()
	local mode = vim.fn.mode()
	local pattern1 = "^(%s*)[-*] %[[^x]%] " -- not checked
	local pattern2 = "^(%s*)[-*] %[.%] " -- has checkbox
	local pattern3 = "^(%s*)[-*] +" -- list
	local exclude_pattern = "^%s*%d+%. " -- numbered list

	if mode == "n" then
		local row, col = unpack(vim.api.nvim_win_get_cursor(0))
		local line = vim.fn.getline(row)
		local len = #line - 1
		if line:match(exclude_pattern) then
			return
		elseif line:match(pattern2) then
			Bullets.cycle_checkbox_marker()
			return
		elseif line:match(pattern3) then
			line = line:gsub(pattern3, "%1- [ ] ")
		else
			line = line:gsub("^(%s*)", "%1- [ ] ")
		end
		col = col - len + #line
		local marker = line:match("^%s*- %[.%] ")
		if marker and col < #marker + 1 then
			col = #marker + 1
		end
		vim.fn.setline(row, line)
		vim.fn.setpos(".", { 0, row, col, 0 })
	else
		local anchor = vim.fn.getpos("v")
		local head = vim.fn.getpos(".")
		if anchor[2] > head[2] then
			anchor, head = head, anchor
		elseif anchor[2] == head[2] and anchor[3] > head[3] then
			anchor, head = head, anchor
		end
		local case = 3
		for i = anchor[2], head[2] do
			local line = vim.fn.getline(i)
			if vim.trim(line) ~= "" then
				if line:match(pattern1) then -- not checked
					if case == 3 then
						case = 2
					end
				elseif line:match(pattern2) then -- checked
				elseif line:match(pattern3) then -- not a checkbox
					line = line:gsub(pattern3, "%1- [ ] ")
					vim.fn.setline(i, line)
					case = 1
				elseif not line:match(exclude_pattern) then -- not a list item, but also not a numbered list
					line = line:gsub("^(%s*)", "%1- [ ] ")
					vim.fn.setline(i, line)
					case = 1
				end
			end
		end
		if case == 1 then
			return
		end
		for i = anchor[2], head[2] do
			local line = vim.fn.getline(i)
			if vim.trim(line) ~= "" then
				if case == 2 then
					-- check all checkboxes
					if line:match(pattern1) then -- not checked
						line = line:gsub(pattern1, "%1- [x] ")
						vim.fn.setline(i, line)
					end
				else
					-- uncheck all checkboxes
					if line:match(pattern2) then -- checked
						line = line:gsub(pattern2, "%1- [ ] ")
						vim.fn.setline(i, line)
					end
				end
			end
		end
	end
end

-- Checkboxes --------------------------------------------- }}}

-- List Items --------------------------------------------- {{{

local function node_at_cursor(type)
	local bufnr = vim.api.nvim_get_current_buf()
	local parser = vim.treesitter.get_parser(bufnr, "markdown", { error = false })
	if not parser then
		return nil
	end
	local tree = parser:parse()[1]
	local root = tree:root()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	row = row - 1
	local node = root:descendant_for_range(row, col, row, col)
	while node and node:type() ~= type do
		node = node:parent()
	end
	if not node then
		node = vim.treesitter.get_node()
		while node and node:type() ~= type do
			node = node:parent()
		end
	end
	return node
end

Bullets.select_list_text = function()
	local mode = vim.fn.mode()
	local bufnr = vim.api.nvim_get_current_buf()
	local list_item_node = node_at_cursor("list_item")
	if not list_item_node then
		return
	end
	local query = vim.treesitter.query.parse("markdown", "(list_item (paragraph (inline) @content))")
	for _, node in query:iter_captures(list_item_node, bufnr) do
		local r1, c1, r2, c2 = node:range()
		vim.api.nvim_win_set_cursor(0, { r1 + 1, c1 })
		vim.cmd("normal! " .. (mode == "n" and "v" or "o"))
		vim.api.nvim_win_set_cursor(0, { r2 + 1, c2 - 1 })
		return
	end
end

Bullets.select_list = function()
	local node = node_at_cursor("list_item")
	if node then
		local top, _, bottom, _ = node:range()
		vim.cmd(string.format("normal! V%dGo%dG", bottom, top + 1))
	end
end

Bullets.find_list_sibling = function(prev)
	local count = vim.v.count1
	local node = node_at_cursor("list_item")
	if not node then
		return
	end
	local target
	for _ = 1, count do
		if prev then
			target = node:prev_named_sibling()
		else
			target = node:next_named_sibling()
		end
		if not target or target:type() ~= "list_item" then
			return
		end
		node = target
	end
	local row, col
	if node:child(1) then
		row, col = node:child(1):range()
	else
		row = node:child(0):range()
		col = #vim.fn.getline(row + 1)
	end
	vim.api.nvim_win_set_cursor(0, { row + 1, col })
end

Bullets.find_list_parent = function()
	local node = node_at_cursor("list_item")
	if not node then
		return
	end
	local parent = node:parent():parent()
	if parent and parent:type() == "list_item" then
		local row, col
		if parent:child(1) then
			row, col = parent:child(1):range()
		else
			row = parent:child(0):range()
			col = #vim.fn.getline(row + 1)
		end
		vim.api.nvim_win_set_cursor(0, { row + 1, col })
	end
end

-- List Items --------------------------------------------- }}}

-- Renumbering --------------------------------------------- {{{
H.get_level = function(bullet)
	if next(bullet) == nil or bullet.type ~= "std" then
		return 0
	else
		return vim.str_utfindex(bullet.bullet)
	end
end

Bullets.renumber_selection = function()
	local sel = H.get_selection(1)
	Bullets.renumber_lines(sel.start_line, sel.end_line)
	H.set_selection(sel)
end

Bullets.renumber_lines = function(start_ln, end_ln)
	local prev_indent = -1
	local list = {} -- stores all the info about the current outline/list

	for nr = start_ln, end_ln do
		local indent = vim.fn.indent(nr)
		local bullet = H.closest_bullet_types(nr, indent)
		bullet = H.resolve_bullet_type(bullet)
		local curr_level = H.get_level(bullet)
		if curr_level > 1 then
			-- then it's an AsciiDoc list and shouldn't be renumbered
			break
		end

		if next(bullet) ~= nil and bullet.starting_at_line_num == nr then
			-- skip wrapped lines and lines that aren't bullets
			if (indent > prev_indent or list[indent] == nil) and bullet.type ~= "chk" and bullet.type ~= "std" then
				if list[indent] == nil then
					if bullet.type == "num" then
						list[indent] = { index = bullet.bullet }
					elseif bullet.type == "rom" then
						list[indent] = { index = H.rom_to_num(bullet.bullet) }
					elseif bullet.type == "abc" then
						list[indent] = { index = H.abc2dec(bullet.bullet) }
					end
				end

				-- use the first bullet at this level to define the bullet type for
				-- subsequent bullets at the same level. Needed to normalize bullet
				-- types when there are multiple types of bullets at the same level.
				list[indent].islower = bullet.bullet == string.lower(bullet.bullet)
				list[indent].type = bullet.type
				list[indent].bullet = bullet.bullet -- for standard bullets
				list[indent].closure = bullet.closure -- normalize closures
				list[indent].trailing_space = bullet.trailing_space
			else
				if bullet.type ~= "chk" and bullet.type ~= "std" then
					if list[indent] == nil then
						-- list[indent] = {index = 1}
						if bullet.type == "num" then
							list[indent] = { index = bullet.bullet }
						elseif bullet.type == "rom" then
							list[indent] = { index = H.rom_to_num(bullet.bullet) }
						elseif bullet.type == "abc" then
							list[indent] = { index = H.abc2dec(bullet.bullet) }
						end
					end
					list[indent].index = list[indent].index + 1
				end

				if indent < prev_indent then
					-- Reset the numbering on all all child items. Needed to avoid continuing
					-- the numbering from earlier portions of the list with the same bullet
					-- type in some edge cases.
					for key, _ in pairs(list) do
						if key > indent then
							list[key] = nil
						end
					end
				end
			end

			prev_indent = indent

			if list[indent] ~= nil then
				local bullet_num = list[indent].index
				local new_bullet = ""
				if bullet.type ~= "chk" and bullet.type ~= "std" then
					if list[indent].type == "rom" then
						bullet_num = H.num_to_rom(list[indent].index, list[indent].islower)
					elseif list[indent].type == "abc" then
						bullet_num = H.dec2abc(list[indent].index, list[indent].islower)
					end

					new_bullet = bullet_num .. list[indent].closure .. list[indent].trailing_space
					-- if list[indent].index > 1 then
					--   new_bullet = pad_to_length(new_bullet, list[indent].pad_len)
					-- end
					-- list[indent].pad_len = vim.str_utfindex(new_bullet)
					local renumbered_line = bullet.leading_space .. new_bullet .. bullet.text_after_bullet
					vim.fn.setline(nr, renumbered_line)
				elseif bullet.type == "chk" then
					-- Reset the checkbox marker if it already exists, or blank otherwise
					local marker = " "
					if bullet.checkbox_marker ~= nil then
						marker = bullet.checkbox_marker
					end
					H.set_checkbox(nr, marker)
				end
			end
		end
	end
end

Bullets.renumber_whole_list = function()
	-- Renumbers the whole list containing the cursor.
	-- Does not renumber across blank lines.
	local first_line = H.first_bullet_line(vim.fn.line("."))
	local last_line = H.last_bullet_line(vim.fn.line("."))
	if first_line > 0 and last_line > 0 then
		Bullets.renumber_lines(first_line, last_line)
	end
end

Bullets.insert_new_bullet = function(trigger)
	local curr_line_col = vim.fn.getcursorcharpos()[3]
	local curr_line_num = vim.fn.line(".")
	local line_text = vim.fn.getline(".")
	local next_line_num = curr_line_num + Bullets.config.line_spacing
	local curr_indent = vim.fn.indent(curr_line_num)
	local bullet_types = H.closest_bullet_types(curr_line_num, curr_indent)
	-- Need to find which line starts the previous bullet started at and start
	-- searching up from there
	local send_return = true
	local indent_next = H.line_ends_in_colon(curr_line_num) and Bullets.config.colon_indent
	local next_bullet_list = {}
	local cr_key = vim.api.nvim_replace_termcodes("<CR>", true, false, true)

	-- Check if current line is a bullet and we are at the end of the line (for
	-- insert mode only)
	if next(bullet_types) ~= nil then
		local bullet = H.resolve_bullet_type(bullet_types)
		if (bullet ~= nil) and (next(bullet) ~= nil) then
			-- Was any text entered after the bullet?
			if bullet.text_after_bullet == "" then
				-- We don't want to create a new bullet if the previous one was not used,
				-- instead we want to delete the empty bullet - like word processors do
				if Bullets.config.delete_last_bullet then
					vim.fn.setline(curr_line_num, "")
					send_return = false
				end
			elseif not (bullet.type == "abc" and H.abc2dec(bullet.bullet) + 1 > Bullets.config.abc_max) then
				-- get text after cursor
				local text_after_cursor = ""
				if trigger == "cr" and (vim.fn.strcharlen(line_text) >= curr_line_col) then
					text_after_cursor = vim.fn.strcharpart(line_text, curr_line_col - 1, vim.fn.strcharlen(line_text))
					vim.fn.setline(".", vim.fn.strcharpart(line_text, 0, curr_line_col - 1))
				end

				local next_bullet = H.next_bullet_str(bullet) .. text_after_cursor
				next_bullet_list = { next_bullet }

				-- prepend blank lines if desired
				if trigger ~= "cr" and Bullets.config.line_spacing > 1 then
					for i = 1, Bullets.config.line_spacing do
						table.insert(next_bullet_list, i, "")
					end
				end

				-- insert next bullet
				vim.fn.append(curr_line_num, next_bullet_list)

				-- Go to next line after the new bullet
				local col = vim.str_utfindex(vim.fn.getline(next_line_num), "utf-8") + 1
				vim.fn.setpos(".", { 0, next_line_num, col })

				-- Indent if previous line ended in a colon
				if indent_next then
					-- demote the new bullet
					H.change_line_bullet_level(-1, next_line_num)
					-- reset cursor position after indenting
					col = vim.str_utfindex(vim.fn.getline(next_line_num), "utf-8") + 1
					vim.fn.setpos(".", { 0, next_line_num, col })
				elseif Bullets.config.renumber then
					Bullets.renumber_whole_list()
				end
			end
			send_return = false
		end
	end

	if send_return then
		if trigger == "cr" then
			vim.cmd("startinsert")
		elseif trigger == "o" then
			vim.cmd("startinsert!")
		end
		vim.api.nvim_feedkeys(cr_key, "n", true)
	elseif trigger == "o" then
		vim.cmd("startinsert!")
	end

	-- need to return a string since we are in insert mode calling with <C-R>=
	return ""
end

Bullets.toggle_list = function()
	local mode = vim.fn.mode()
	local pattern1 = "^(%s*)[-*] %[.%] "
	local pattern2 = "^(%s*)[-*] +"
	local pattern3 = "^(%s*)%d+%. "

	if mode == "n" then
		local row, col = unpack(vim.api.nvim_win_get_cursor(0))
		local line = vim.fn.getline(row)
		local len = #line - 1
		if line:match(pattern1) then
			line = line:gsub(pattern1, "%1")
		elseif line:match(pattern2) then
			line = line:gsub(pattern2, "%1")
		elseif line:match(pattern3) then
			line = line:gsub(pattern3, "%1- ")
		else
			line = line:gsub("^(%s*)", "%1- ")
		end
		col = col - len + #line
		local marker = line:match("^%s*[-*] ")
		if marker and col < #marker + 1 then
			col = #marker + 1
		end
		vim.fn.setline(row, line)
		vim.fn.setpos(".", { 0, row, col, 0 })
	else
		local anchor = vim.fn.getpos("v")
		local head = vim.fn.getpos(".")
		if anchor[2] > head[2] then
			anchor, head = head, anchor
		elseif anchor[2] == head[2] and anchor[3] > head[3] then
			anchor, head = head, anchor
		end
		local is_list = true
		for i = anchor[2], head[2] do
			local line = vim.fn.getline(i)
			if vim.trim(line) ~= "" and not line:match(pattern2) then
				is_list = false
				break
			end
		end
		for i = anchor[2], head[2] do
			local line = vim.fn.getline(i)
			if vim.trim(line) ~= "" then
				if is_list then
					if line:match(pattern1) then
						line = line:gsub(pattern1, "%1")
					elseif line:match(pattern2) then
						line = line:gsub(pattern2, "%1")
					end
				else
					if line:match(pattern3) then
						line = line:gsub(pattern3, "%1- ")
					elseif not line:match(pattern2) then
						line = line:gsub("^(%s*)", "%1- ")
					end
				end
				vim.fn.setline(i, line)
			end
		end
	end
end

Bullets.toggle_numbered_list = function()
	local mode = vim.fn.mode()
	local pattern1 = "^(%s*)%d+%. "
	local pattern2 = "^(%s*)[-*] +"

	if mode == "n" then
		local row, col = unpack(vim.api.nvim_win_get_cursor(0))
		local line = vim.fn.getline(row)
		local len = #line
		if line:match(pattern1) then
			line = line:gsub(pattern1, "%1")
		elseif line:match(pattern2) then
			line = line:gsub(pattern2, "%11. ")
		else
			line = line:gsub("^(%s*)", "%11. ")
		end
		col = col - len + #line
		local marker = line:match("^%s*1%. ")
		if marker and col < #marker + 1 then
			col = #marker + 1
		end
		vim.fn.setline(row, line)
		vim.fn.setpos(".", { 0, row, col, 0 })
	else
		local anchor = vim.fn.getpos("v")
		local head = vim.fn.getpos(".")
		if anchor[2] > head[2] then
			anchor, head = head, anchor
		elseif anchor[2] == head[2] and anchor[3] > head[3] then
			anchor, head = head, anchor
		end
		local is_list = true
		local indent = -1
		for i = anchor[2], head[2] do
			local line = vim.fn.getline(i)
			if vim.trim(line) ~= "" then
				is_list = line:match(pattern1) ~= nil
				indent = vim.fn.indent(i)
				break
			end
		end
		local idx = 1
		for i = anchor[2], head[2] do
			local line = vim.fn.getline(i)
			if vim.trim(line) ~= "" then
				if vim.fn.indent(i) == indent then
					if is_list then
						if line:match(pattern1) then
							line = line:gsub(pattern1, "%1")
						end
					else
						if line:match(pattern2) then
							line = line:gsub(pattern2, "%1" .. idx .. ". ")
						elseif line:match(pattern1) then
							line = line:gsub(pattern1, "%1" .. idx .. ". ")
						else
							line = line:gsub("^(%s*)", "%1" .. idx .. ". ")
						end
						idx = idx + 1
					end
				elseif vim.fn.indent(i) < indent then
					return
				end
			end
			vim.fn.setline(i, line)
		end
	end
end

Bullets.set_checkbox_marker = function()
	local mode = vim.fn.mode()
	local range
	if mode == "n" then
		local row = unpack(vim.api.nvim_win_get_cursor(0))
		range = { row, row }
	else
		local anchor = vim.fn.getpos("v")
		local head = vim.fn.getpos(".")
		if anchor[2] > head[2] then
			anchor, head = head, anchor
		end
		range = { anchor[2], head[2] }
	end
	print("Enter checkbox marker")
	local ok, code = pcall(vim.fn.getchar)
	if ok and type(code) == "number" then
		local char = vim.fn.nr2char(code)
		for row = range[1], range[2] do
			local line = vim.fn.getline(row)
			local prefix = string.rep(" ", vim.fn.indent(row)) .. "- [" .. char .. "] "
			line = line:gsub("^%s*[-*] %[.%] *", "")
			line = line:gsub("^%s*[-*] *", "")
			line = prefix .. line
			vim.fn.setline(row, line)
		end
	end
end

Bullets.check_move = function()
	local node = node_at_cursor("list_item")
	if node then
		for child in node:iter_children() do
			if child:type() == "task_list_marker_unchecked" then
				local list_node = node:parent()
				if list_node and list_node:type() == "list" then
					local start_row, _, end_row, _ = node:range()
					local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row, false)
					lines[1] = lines[1]:gsub(" %[ %]", " [x]")
					local first_row, _, last_row, _ = list_node:range()
					local last_line = vim.fn.getline(last_row)
					while last_row > first_row and vim.fn.trim(last_line) == "" do
						last_row = last_row - 1
						last_line = vim.fn.getline(last_row)
					end
					vim.api.nvim_buf_set_lines(0, last_row, last_row, true, lines)
					vim.api.nvim_buf_set_lines(0, start_row, end_row, false, {})
				end
				return
			end
		end
	end
end

return Bullets
