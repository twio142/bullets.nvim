local Bullets = require("Bullets")

-- Simplified outline levels make expected output deterministic:
--   num -> std- -> std*
Bullets.setup({ outline_levels = { "num", "std-" } })

local eq = assert.are.same

local function set_buf(lines)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

local function get_buf()
    return vim.api.nvim_buf_get_lines(0, 0, -1, false)
end

local function run_visual(cmd, start_line, end_line)
    vim.fn.cursor(start_line, 1)
    local steps = end_line - start_line
    local keys = "V" .. (steps > 0 and steps .. "j" or "") .. "<cmd>" .. cmd .. "<CR>"
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "x", true)
end

describe("BulletPromoteVisual / BulletDemoteVisual", function()
    before_each(function()
        vim.cmd("enew!")
        vim.bo.shiftwidth = 4
        vim.bo.expandtab = true
    end)

    after_each(function()
        vim.cmd("bwipeout!")
    end)

    -- DEVELOPMENT.md Example 1
    it("promote preserves relative hierarchy across selected lines", function()
        set_buf({
            "1. Item 1",
            "    - Subitem 1",
            "        - Sub-subitem 1",
            "2. Item 2",
        })
        -- Select lines 2-3 and promote
        run_visual("BulletPromoteVisual", 2, 3)
        eq({
            "1. Item 1",
            "2. Subitem 1",
            "    - Sub-subitem 1",
            "3. Item 2",
        }, get_buf())
    end)

    -- DEVELOPMENT.md Example 2
    it("demote deepens each selected line by exactly one level", function()
        set_buf({
            "1. Item 1",
            "2. Item 2",
            "    - Subitem 1",
            "3. Item 3",
        })
        -- Select lines 2-3 and demote
        run_visual("BulletDemoteVisual", 2, 3)
        eq({
            "1. Item 1",
            "    - Item 2",
            "        - Subitem 1",
            "2. Item 3",
        }, get_buf())
    end)

    -- Backwards selection should give the same result
    it("promote works correctly with a backwards visual selection", function()
        set_buf({
            "1. Item 1",
            "    - Subitem 1",
            "        - Sub-subitem 1",
            "2. Item 2",
        })
        -- Select bottom-to-top: start at line 3, go up to line 2
        vim.fn.cursor(3, 1)
        local keys = "Vk<cmd>BulletPromoteVisual<CR>"
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "x", true)
        eq({
            "1. Item 1",
            "2. Subitem 1",
            "    - Sub-subitem 1",
            "3. Item 2",
        }, get_buf())
    end)

    describe("Respect vim.v.count", function()
        it("demote works with count in normal mode", function()
            vim.bo.filetype = "markdown"
            set_buf({
                "1. Item 1",
                "2. Item 2",
                "3. Item 3",
                "4. Item 4",
            })
            vim.fn.cursor(2, 1)
            local keys = "2>>"
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "x", true)
            eq({
                "1. Item 1",
                "    - Item 2",
                "    - Item 3",
                "2. Item 4",
            }, get_buf())
        end)

        it("promote works with count in normal mode", function()
            vim.bo.filetype = "markdown"
            set_buf({
                "1. Item 1",
                "    - Item 2",
                "    - Item 3",
                "2. Item 4",
            })
            vim.fn.cursor(2, 1)
            local keys = "2<<"
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "x", true)
            eq({
                "1. Item 1",
                "2. Item 2",
                "3. Item 3",
                "4. Item 4",
            }, get_buf())
        end)

        it("demote works with count in visual mode", function()
            vim.bo.filetype = "markdown"
            Bullets.config.outline_levels = { "num", "std-", "std*" }
            set_buf({
                "1. Item 1",
                "2. Item 2",
                "3. Item 3",
            })
            vim.fn.cursor(2, 1)
            local keys = "V2>"
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "x", true)
            eq({
                "1. Item 1",
                "        - Item 2",
                "2. Item 3",
            }, get_buf())
        end)

        it("promote works with count in visual mode", function()
            vim.bo.filetype = "markdown"
            Bullets.config.outline_levels = { "num", "std-", "std*" }
            set_buf({
                "1. Item 1",
                "        * Item 2",
                "2. Item 3",
            })
            vim.fn.cursor(2, 1)
            local keys = "V2<"
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "x", true)
            eq({
                "1. Item 1",
                "2. Item 2",
                "3. Item 3",
            }, get_buf())
        end)
    end)

    describe("Non-list lines", function()
        it("BulletDemote indents a non-list line like >>", function()
            vim.bo.filetype = "markdown"
            set_buf({
                "1. Item 1",
                "Not a list item",
                "2. Item 2",
            })
            vim.fn.cursor(2, 1)
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<cmd>BulletDemote<CR>", true, false, true), "x", true)
            eq({
                "1. Item 1",
                "    Not a list item",
                "2. Item 2",
            }, get_buf())
        end)

        it("BulletPromote outdents a non-list line like <<", function()
            vim.bo.filetype = "markdown"
            set_buf({
                "1. Item 1",
                "    Not a list item",
                "2. Item 2",
            })
            vim.fn.cursor(2, 1)
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<cmd>BulletPromote<CR>", true, false, true), "x", true)
            eq({
                "1. Item 1",
                "Not a list item",
                "2. Item 2",
            }, get_buf())
        end)
    end)
end)
