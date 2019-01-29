# scnvim

SuperCollider integration for Neovim.

## Features

#### Post Window is displayed in a regular vim buffer

Use vim key bindings to navigate/move/copy etc.

![post window](./gif/postwindow-min.gif)

#### Interactive argument hints in the command-line area

![argument hints](./gif/arghints-min.gif)

#### Status line widgets

Display SuperCollider server status in vim statusline.

![server status](./gif/serverstatus-min.gif)

#### Snippet generator

Generates snippets for all creation methods in SCClassLibrary.

The snippet engine used here is [UltiSnips][UltiSnips] together with [deoplete](https://github.com/Shougo/deoplete.nvim) for auto completion.

![snippets](./gif/snippets-min.gif)

### more..

* Can be used with Neovim [GUI frontends](https://github.com/neovim/neovim/wiki/Related-projects#gui)
* Supports lazy loading
* Context aware evaluation (like `Cmd-Enter` in ScIDE)

## Installation

### Requirements 

* [Neovim][neovim] (tested with >= 0.3.1)
* [SuperCollider][supercollider]
* [pynvim][pynvim] (optional)

### Installation

Here is an example using [vim-plug](https://github.com/junegunn/vim-plug)

1. Add this line to your init.vim
```vim
Plug 'davidgranstrom/scnvim'
```
2. `:PlugInstall`
3. `:UpdateRemotePlugins`
4. Exit nvim and re-open

> Steps 3-4 can be omitted if you don't want to use the remote plugin features (see explanation below).

Open a new file with a `.scd` or `.sc` extension and type `:SCNvimStart` to start SuperCollider.

### Remote plugin

Some features of scnvim are implemented as a [remote plugin](https://neovim.io/doc/user/remote_plugin.html) which can communicate to SuperCollider via UDP.
If you want to use the *argument hints* or *statusline update* features you will need to install the python3 client [pynvim][pynvim].

```shell
pip3 install pynvim --user
```

Please visit the [pynvim repo][pynvim] to read the official installation instructions and how to upgrade to newer versions.

## Syntax highlighting

Run `:SCNvimTags` after starting SuperCollider to generate a file used for syntax highlighting.

The command will also generate a file with snippet definitions for all
object creation methods and also a `tags` file which can be used to navigate to
references using the built-in vim command `C-]` (jump to definition).

If you write or install new classes you will need to run this command again to update the syntax/tags/snippets files.

## Snippets

Run `:SCNvimTags` to generate the snippet definitions.

You will also need a snippet engine like [UltiSnips][UltiSnips] in order to use the snippets. To let [UltiSnips][UltiSnips] know about the snippets put the following line in your init.vim:

```vim
let g:UltiSnipsSnippetDirectories = ['UltiSnips', 'scnvim-data']
```

## Status line widgets

scnvim provides some functions suitable to use in your vim statusline.

* `scnvim#statusline#server_status`

Run `:SCNvimStatusLine` to get feedback in the status line.

See the [example init.vim](#) on how they can be used.

This command calls `SCNvim.statusLineUpdate(<interval>, <port>)` in
SuperCollider, where <port> is the UDP port of the remote plugin. Currently
there is no way to support multiple (SuperCollider) sessions without guessing
the port number for the remote plugin. But if you use single sessions you could
probably add this to your `startup.scd` to automatically call the function on
server boot.

```supercollider
Server.default.doWhenBooted {
    SCNvim.updateStatusLine(1, 9670); // default port for scnvim
}
```

## Mappings

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
| `SCNvimStart` | Start SuperCollider |
| `SCNvimStop` | Stop SuperCollider |
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

## Thanks to

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

[neovim]: https://github.com/neovim/neovim
[supercollider]: https://github.com/supercollider/supercollider
[pynvim]: https://github.com/neovim/pynvim
[UltiSnips]: https://github.com/SirVer/ultisnips
