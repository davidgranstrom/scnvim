# scnvim

SuperCollider integration for Neovim.

## Features

* Post Window is displayed in a regular vim buffer
    - Use vim key bindings to navigate/copy etc.
* Interactive argument hints in the command-line
* Status line widgets
    - Display server status in vim statusline
    - Level Meter (in progress)
* Can be used with Neovim [GUI frontends](https://github.com/neovim/neovim/wiki/Related-projects#gui)
* Snippet generator
* Supports lazy loading
* Context aware evaluation (Cmd-Enter in ScIDE)

## Mappings

Here is an overview of the default mappings.

| Map | Description | Name | Mode |
| --- | --- | --- | --- |
| `<C-e>` | Send current block or line (depending on context) |`<Plug>(scnvim-send-block)` | Insert, Normal |
| `<C-e>` | Send current selection |`<Plug>(scnvim-send-selection)` | Visual |
| `<M-e>` | Send current line | `<Plug>(scnvim-send-line)` | Insert, Normal |
| `<F12>` | Hard stop | `<Plug>(scnvim-hard-stop)` | Insert, Normal |
| `<CR>`  | Toggle post window buffer | `<Plug>(scnvim-postwindow-toggle)` | Insert, Normal |
| `<M-L>` | Clear post window buffer | `<Plug>(scnvim-postwindow-clear)` | Insert, Normal |

To remap any of the default mappings use the `nmap` command together with the name of the mapping.

E.g. `nmap <F5> <Plug>(scnvim-send-block)`

To disable all default mappings specify `let g:scnvim_no_mappings = 1` in your vimrc/init.vim

## Commands

| Command | Description |
| --- | --- |
| `SCNvimStart` | Starts SuperCollider |
| `SCNvimStop` | Stops SuperCollider |
| `SCNvimRecompile` | Recompile SCClassLibrary |
| `SCNvimTags` | Create auto-generated utility files |
| `SCNvimHelp <subject>` | Open HelpBrowser for <subject> |
| `SCNvimStatusLine` | Display server status in status line |

## Configuration

The following variables are used to configure scnvim. This plugin should work
out-of-the-box so it is not neccessary to set them if you are happy with the
defaults.

Run `:checkhealth` to diagnose common problems with your config.

### Post window

```vim
" vertical 'v' or horizontal 'h' split
let g:scnvim_postwin_orientation = 'v'

" position of the post window 'right' or 'left'
let g:scnvim_postwin_direction = 'right'

" default is half the terminal size for vertical and a third for horizontal
let g:scnvim_postwin_size = 25

" automatically open post window on a SuperCollider error
let g:scnvim_postwin_auto_toggle = 1
```

### Eval flash

```vim
" duration of the highlight
let g:scnvim_eval_flash_duration = 100

" number of flashes. A value of 0 disables this feature.
let g:scnvim_eval_flash_repeats = 2

" configure the color
highlight SCNvimEval guifg=black guibg=white ctermfg=black ctermbg=white
```

### Extras

```
" path to the sclang executable
" scnvim will look in some known locations for sclang, but if it can't find it use this variable instead
" (also improves startup time slightly)
let g:scnvim_sclang_executable = ''

" update rate for server info in status line (seconds)
" (don't set this to low or vim will get slow)
let g:scnvim_statusline_interval = 1

" set this variable if you don't want any remote plugin features (argument hints, server status)
let g:scnvim_no_extras = 1

" UDP port for (remote) python plugin
let g:scnvim_udp_port = 9670

" set this variable if you don't want any default mappings
let g:scnvim_no_mappings = 1
```

## Thanks & Inspiration

[scvim](https://github.com/supercollider/scvim)

[vim-tidal](https://github.com/tidalcycles/vim-tidal)

## License

```
scnvim - SuperCollider integration for Neovim
Copyright © 2018-2019 David Granström

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
```
