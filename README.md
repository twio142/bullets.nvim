# Bullets.nvim

A lua port of [bullets.vim](https://github.com/bullets-vim/bullets.vim)

## Setup

- Include the plugin using your plugin manager of choice.
- `config` is a table containing your chosen options (see the code for available options; no help file provided at this time).
- Include in your `init.lua` `require('Bullets').setup({ config })` **or** for Lazy:

```lua
{
  'kaymmm/bullets.nvim',
  opts = {
    colon_indent = true,
    delete_last_bullet = true,
    empty_buffers = true,
    file_types = { 'markdown', 'text', 'gitcommit' },
    line_spacing = 1,
    set_mappings = true,
    outline_levels = { 'ROM', 'ABC', 'num', 'abc', 'rom', 'std*', 'std-', 'std+' },
    renumber = true,
    alpha = {
      len = 2,
    },
    checkbox = {
      nest = true,
      markers = ' .oOx',
      toggle_partials = true,
    },
    custom_mappings = { -- only works if set_mappings is false
      { 'inoremap', '<S-cr>', '<cr>' },
      { 'nmap', 'o', '<Plug>(bullets-newline-o)' },
    }
  }
}
```
