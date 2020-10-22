# scnvim

[Neovim][neovim] frontend for [SuperCollider][supercollider].

[![Build Status](https://travis-ci.com/davidgranstrom/scnvim.svg?branch=master)](https://travis-ci.com/davidgranstrom/scnvim) | [Documentation](https://github.com/davidgranstrom/scnvim/wiki) | [Showcase](https://github.com/davidgranstrom/scnvim/wiki/Showcase)

## Features

* Post window is displayed in a regular vim buffer
  - Use vim key bindings to navigate/move/copy etc.
  - Toggles back if hidden on a SuperCollider error
* Automatic display of method arguments
* Status line widgets
  - Display SuperCollider server status in the status line.
* Snippet generator
  - Generates snippets for creation methods in SCClassLibrary.
* Can be used with Neovim [GUI frontends](https://github.com/neovim/neovim/wiki/Related-projects#gui)
* Supports [on-demand loading](https://github.com/junegunn/vim-plug#on-demand-loading-of-plugins)
* Context aware evaluation (like `Cmd-Enter` in ScIDE)
* Flashy eval flash (configurable)
* Partial `Document` support (e.g. `thisProcess.nowExecutingPath`, `.load` etc.)
* Display SuperCollider documentation inside nvim
  - Be able to evaluate examples

## Supported platforms

* Linux
* macOS
* Windows (tested with `nvim-qt`)
  - Also see this [important note](#note-to-windows-users).

## Installation

### Requirements

* [Neovim][neovim] >= 0.4.3
* [SuperCollider][supercollider]

### Install

1. [Install SuperCollider](https://supercollider.github.io/download).
2. Add this line to your `init.vim` if you are using [vim-plug](https://github.com/junegunn/vim-plug).

```vim
Plug 'davidgranstrom/scnvim', { 'do': {-> scnvim#install() } }
```

Source `init.vim` (or restart `nvim`) and then run `:PlugInstall`.

Modify the above to match your package manager of choice, or do a manual install using [vim packages](https://github.com/davidgranstrom/scnvim/wiki/Manual-installation).

### Uninstall

1. Run `:call scnvim#uninstall()`
    - You could always delete the symbolic link (`scide_scnvim`) from your `Extensions` directory manually if you forget this step.

2. Remove the plugin according to how you've installed it (see `Install` above.)

### Troubleshooting

If something doesn't work with the installation method above, the first thing
to try is `:checkhealth scnvim`. This will give you an indication on what's not
working, and information on how to resolve the issue.

If you want to do complete a manual installation look [here](https://github.com/davidgranstrom/scnvim/wiki/Manual-installation) and [here](https://github.com/davidgranstrom/scnvim/wiki/Manual-installation-of-SuperCollider-classes).

## Starting SCNvim

Open a new file in `nvim` with a `.scd` or `.sc` extension and type `:SCNvimStart` to start SuperCollider.

## Configuration

The following sections can be accessed in `:help scnvim` as well.

### Mappings

| Map     | Description                                                    | Name                               | Mode           |
|:--------|:---------------------------------------------------------------|:-----------------------------------|:---------------|
| `<C-e>` | Send current block or line (depending on context)              |`<Plug>(scnvim-send-block)`         | Insert, Normal |
| `<C-e>` | Send current selection                                         |`<Plug>(scnvim-send-selection)`     | Visual         |
| `<M-e>` | Send current line                                              | `<Plug>(scnvim-send-line)`         | Insert, Normal |
| `<F12>` | Hard stop                                                      | `<Plug>(scnvim-hard-stop)`         | Insert, Normal |
| `<CR>`  | Toggle post window buffer                                      | `<Plug>(scnvim-postwindow-toggle)` | Insert, Normal |
| `<M-L>` | Clear post window buffer                                       | `<Plug>(scnvim-postwindow-clear)`  | Insert, Normal |
| `C-k`   | Show function signature for object under cursor                | `<Plug>(scnvim-show-signature)`    | Insert, Normal |
| `K`     | Open documentation                                             | Uses vim `keywordprg`              | Normal         |

To remap any of the default mappings use the `nmap` command together with the name of the mapping.

**Examples**

```vim
nmap <F5> <Plug>(scnvim-send-block)
```

To disable a specific mapping use `<nop>`.
```vim
nnoremap <nop> <Plug>(scnvim-show-signature)
```

To disable all default mappings use `let g:scnvim_no_mappings = 1`

### Commands

| Command                | Description                          | 
|:-----------------------|:-------------------------------------|
| `SCNvimStart`          | Start SuperCollider                  |
| `SCNvimStop`           | Stop SuperCollider                   |
| `SCNvimRecompile`      | Recompile SCClassLibrary             |
| `SCNvimTags`           | Create auto-generated utility files  |
| `SCNvimHelp <subject>` | Open HelpBrowser for \<subject\>     |
| `SCNvimStatusLine`     | Display server status in status line |

### Additional setup

Run `:SCNvimTags` after starting SuperCollider to enable syntax highlighting
(note that the current buffer must be reloaded for this to take effect).

**Note** There is a known bug where `sclang` will crash immediately after running
`:SCNvimTags`. This will hopefully be resolved in the future.

The plugin should work "out of the box", but if you want even more fine-grained
control please have a look at this [section](https://github.com/davidgranstrom/scnvim/wiki/Additional-configuration) in the wiki.

## Note to Windows users

To be able to boot the server you will need to add the following to your `startup.scd`:

```supercollider
if (\SCNvim.asClass.notNil) {
  Server.program = (Platform.resourceDir +/+ "scsynth.exe").quote;
}
```

## License

```plain
scnvim - Neovim frontend for SuperCollider
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
