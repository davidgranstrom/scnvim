# scnvim

[![Build Status](https://travis-ci.com/davidgranstrom/scnvim.svg?branch=master)](https://travis-ci.com/davidgranstrom/scnvim)

[Neovim][neovim] frontend for [SuperCollider][supercollider]

## Breaking change for version 1.0.0

If you're reading this because SuperCollider cannot find `SCNvim` on startup,
all you have to do is `:call scnvim#install()` to fix the linkage.

Head over to the [new installation instructions](https://github.com/davidgranstrom/scnvim#installation) and update your config!

You may also now safely delete the old symlink in `Extensions/scide_scvim/scnvim`.

## Features

* Post window is displayed in a regular vim buffer
  * Use vim key bindings to navigate/move/copy etc.
  * Toggles back if hidden on a SuperCollider error
* Interactive argument hints in the command-line area
* Status line widgets
  * Display SuperCollider server status in vim status line.
* Snippet generator
  * Generates snippets for all creation methods in SCClassLibrary.
* Can be used with Neovim [GUI frontends](https://github.com/neovim/neovim/wiki/Related-projects#gui)
* Supports lazy loading
* Context aware evaluation (like `Cmd-Enter` in scIDE)
* Flashy eval flash (configurable)
* Partial `Document` support (e.g. `thisProcess.nowExecutingPath` etc.)

## Installation

### Requirements

* [Neovim][neovim] >= 0.4.3
* [SuperCollider][supercollider]

### Procedure

* Using [vim-plug](https://github.com/junegunn/vim-plug)

  1. Add this line to your init.vim

    ```vim
    Plug 'davidgranstrom/scnvim', { 'do': {-> scnvim#install() } }
    ```

  2. Open nvim and run `:PlugInstall`

* Using the internal package manager

  1. Manually clone to your plugin directory. If you used a different directory for other plugins, use that instead.

    ```shell
    mkdir -p ~/.local/share/nvim/site/pack/git-plugins/start && cd "$_"
    git clone https://github.com/davidgranstrom/scnvim
    ```

  2. Open nvim and run `:call scnvim#install()`

#### Starting SCNvim

Open a new file in `nvim` with a `.scd` or `.sc` extension and type `:SCNvimStart` to start SuperCollider.

### Uninstall

1. Run `:call scnvim#uninstall()`
    - You should get a message that the `SCNvim.sc` classes have been unlinked.

2. Remove the plugin according to how you've installed it (see Procedure above.)

### Troubleshooting

If something doesn't work with the installation method above, the first thing
to try is `:checkhealth` in nvim. This will give you an indication on what's
not working, and information on how to resolve the issue.

If you want to do a manual installation instead take a look in the [wiki](https://github.com/davidgranstrom/scnvim/wiki/Manual-installation-of-SuperCollider-classes).

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

See the [example configuration](#example-configuration) on how they can be used.

This command calls `SCNvim.statusLineUpdate(<interval>, <port>)` in
SuperCollider, where `<port>` is the UDP port of the remote plugin. Currently
there is no way to support multiple (SuperCollider) sessions without guessing
the port number for the remote plugin. The `:SCNvimStatusLine` command ensures
that SuperCollider always connects to the correct port.

But if you mostly use single sessions, and know that the port is likely to be
available, you could probably add this to your `startup.scd` to automatically
call the function on server boot.

```supercollider
// scnvim
if (\SCNvim.asClass.notNil) {
    Server.default.doWhenBooted {
        \SCNvim.asClass.updateStatusLine(1, \SCNvim.asClass.port);
    }
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
| `K` | Open documentation | Uses vim `keywordprg` | Normal |

To remap any of the default mappings use the `nmap` command together with the name of the mapping.

E.g. `nmap <F5> <Plug>(scnvim-send-block)`

To disable all default mappings add `let g:scnvim_no_mappings = 1` to your init.vim

## Commands

| Command | Description |
| --- | --- |
| `SCNvimStart` | Start SuperCollider |
| `SCNvimStop` | Stop SuperCollider |
| `SCNvimRecompile` | Recompile SCClassLibrary |
| `SCNvimTags` | Create auto-generated utility files |
| `SCNvimHelp <subject>` | Open HelpBrowser for \<subject\> |
| `SCNvimStatusLine` | Display server status in status line |

## Configuration

The following variables are used to configure scnvim. This plugin should work
out-of-the-box so it is not necessary to set them if you are happy with the
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

```vim
" path to the sclang executable
" scnvim will look in some known locations for sclang, but if it can't find it use this variable instead
" (also improves startup time slightly)
let g:scnvim_sclang_executable = ''

" update rate for server info in status line (seconds)
" (don't set this to low or vim will get slow)
let g:scnvim_statusline_interval = 1

" set this variable if you don't want the "echo args" feature
let g:scnvim_echo_args = 0

" set this variable if you don't want any default mappings
let g:scnvim_no_mappings = 1

" set this variable to browse SuperCollider documentation in nvim (requires `pandoc`)
let g:scnvim_scdoc = 1

" pass flags directly to sclang - see help file for more details, caveats, and further examples
let g:scnvim_sclang_options = ['-u', 9999]

```

## Thanks to

[scvim](https://github.com/supercollider/scvim)

[vim-tidal](https://github.com/tidalcycles/vim-tidal)

## License

```plain
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
[UltiSnips]: https://github.com/SirVer/ultisnips
