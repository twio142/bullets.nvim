# Bullets.nvim

A lua port of [bullets.vim](https://github.com/bullets-vim/bullets.vim)

## Setup

- Include the plugin using your plugin manager of choice.
- `config` is a table containing your chosen options (see the code for available options; no help file provided at this time).
- Include in your `init.lua` `require('Bullets').setup({ config })` **or** for Lazy:

```lua
{
  'twio142/bullets.nvim',
  opts = {
    file_types = { 'markdown', 'text', 'gitcommit' },
    empty_buffers = true, -- if true, enables the plugin mappings in empty buffers
    line_spacing = 1, -- the number of lines between bullet items (e.g. 1 for single-spaced, 2 for double-spaced)
    colon_indent = true, -- if true, indents the next line if the current line ends in a colon
    delete_last_bullet = true, -- if true, deletes an empty bullet marker when pressing <CR> on a line with no text
    renumber = true, -- if true, automatically renumbers lists when changing levels or inserting bullets
    outline_levels = { 'ROM', 'ABC', 'num', 'abc', 'rom', 'std*', 'std-', 'std+' }, -- the sequence of bullet styles used for promotion/demotion
    alpha = { len = 2 }, -- maximum number of characters for alphabetic bullets (e.g. 'aa.')
    checkbox = {
      markers = ' .oOx', -- the sequence of markers used when cycling/toggling checkboxes
      toggle_partials = true, -- present in config but not currently used in the implementation
    },
    custom_mappings = { -- user-defined mappings, overrides defaults
    -- { mode, lhs, rhs }
      { 'i', '<S-cr>', '<cr>' },
      { 'n', 'o', '<Plug>(bullets-newline-o)' },
    }
  }
}
```

## Available Commands

| User Command           | `<Plug>` Expression                                        | Treesitter? |
| :--------------------- | :--------------------------------------------------------- | :---------- |
| `BulletDemote`         | `<Plug>(bullets-demote)`                                   | No          |
| `BulletDemoteVisual`   | `<Plug>(bullets-demote)`                                   | No          |
| `BulletPromote`        | `<Plug>(bullets-promote)`                                  | No          |
| `BulletPromoteVisual`  | `<Plug>(bullets-promote)`                                  | No          |
| `InsertNewBullet`      | `<Plug>(bullets-newline-o)` / `<Plug>(bullets-newline-cr)` | No          |
| `SelectList`           | `<Plug>(bullets-select-list)`                              | **Yes**     |
| `SelectListText`       | `<Plug>(bullets-select-list-text)`                         | **Yes**     |
| `FindPrevListSibling`  | `<Plug>(bullets-prev-list-sibling)`                        | **Yes**     |
| `FindNextListSibling`  | `<Plug>(bullets-next-list-sibling)`                        | **Yes**     |
| `FindListParent`       | `<Plug>(bullets-list-parent)`                              | **Yes**     |
| `RenumberList`         | `<Plug>(bullets-renumber)`                                 | No          |
| `RenumberSelection`    | `<Plug>(bullets-renumber)`                                 | No          |
| `SelectCheckbox`       | (None)                                                     | No          |
| `SelectCheckboxInside` | (None)                                                     | No          |
| `ToggleCheckbox`       | `<Plug>(bullets-toggle-checkbox)`                          | No          |
| `ToggleList`           | `<Plug>(bullets-toggle-list)`                              | No          |
| `ToggleNumberedList`   | `<Plug>(bullets-toggle-numbered-list)`                     | No          |
| `SetCheckboxMarker`    | `<Plug>(bullets-set-checkbox-marker)`                      | No          |
| `CheckMove`            | `<Plug>(bullets-check-move)`                               | **Yes**     |

## Default Keymappings

| Mode     | Key         | `<Plug>` Mapping                  |
| :------- | :---------- | :-------------------------------- |
| `i`      | `<CR>`      | `<Plug>(bullets-newline-cr)`      |
| `n`      | `o`         | `<Plug>(bullets-newline-o)`       |
| `n`, `v` | `gN`        | `<Plug>(bullets-renumber)`        |
| `n`      | `<leader>x` | `<Plug>(bullets-toggle-checkbox)` |
| `i`      | `<C-t>`     | `<Plug>(bullets-demote)`          |
| `n`      | `>>`        | `<Plug>(bullets-demote)`          |
| `v`      | `>`         | `<Plug>(bullets-demote)`          |
| `i`      | `<C-d>`     | `<Plug>(bullets-promote)`         |
| `n`      | `<<`        | `<Plug>(bullets-promote)`         |
| `v`      | `<`         | `<Plug>(bullets-promote)`         |

> [!INFO]
> Setting `custom_mappings` will override the default keymappings. Include any ones you like in `custom_mappings` to retain them.
>
> If you want no keymapping at all, set `custom_mappings` to `{}`.
