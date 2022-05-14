# scnvim

[Neovim][neovim] frontend for [SuperCollider][supercollider].

[![lint and style check](https://github.com/davidgranstrom/scnvim/actions/workflows/lint.yml/badge.svg)](https://github.com/davidgranstrom/scnvim/actions/workflows/lint.yml) | [Documentation](https://github.com/davidgranstrom/scnvim/wiki) | [Showcase](https://github.com/davidgranstrom/scnvim/wiki/Showcase)

---

## News

This plugin has recently undergone a big rewrite, take a look at the [installation](#installation) and [usage](#usage) and update your config.

Have questions? Start a [discussion](https://github.com/davidgranstrom/scnvim/discussions) or join the [IRC channel](https://kiwiirc.com/client/irc.libera.chat/?&theme=mini#scnvim).

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

## Installation

### Requirements

* [Neovim][neovim] >= 0.7
* [SuperCollider][supercollider]

### Install

1. [Install SuperCollider](https://supercollider.github.io/download).
2. Use your favourite package manager to install the plugin

* Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'davidgranstrom/scnvim',
  config = function()
    require'scnvim'.setup{}
  end
}
```

* Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'davidgranstrom/scnvim'

" Add this your init.vim

lua << EOF
require'scnvim.setup{}
EOF
```

### Verify

Run `:checkhealth scnvim` to verify that the installation was successful.

## Usage

### Configuration

The only configuration needed to start using scnvim is for the mappings.

Here are the suggested defaults:

```lua
require('scnvim').setup {
  mapping = {
    ['<M-e>'] = scnvim.map.send_line({'i', 'n'}),
    ['<C-e>'] = {
      scnvim.map.send_block({'i', 'n'}),
      scnvim.map.send_selection('x'),
    },
    ['<F12>'] = scnvim.map.hard_stop({'n', 'x', 'i'}),
    ['<CR>'] = scnvim.map.postwin_toggle('n'),
    ['<M-CR>'] = scnvim.map.postwin_toggle('i'),
    ['<M-L>'] = scnvim.map.postwin_clear({'n', 'i'}),
    ['<C-k>'] = scnvim.map.show_signature({'n', 'i'}),
  },
}
```

Read about more advanced configuration [here](). (TODO)

### Start

Open a new file in `nvim` with a `.scd` or `.sc` extension and type `:SCNvimStart` to start SuperCollider.

### Commands

| Command                | Description                                                    |
|:-----------------------|:---------------------------------------------------------------|
| `SCNvimStart`          | Start SuperCollider                                            |
| `SCNvimStop`           | Stop SuperCollider                                             |
| `SCNvimRecompile`      | Recompile SCClassLibrary                                       |
| `SCNvimGenerateAssets` | Generate tags, syntax, snippets etc.                           |
| `SCNvimHelp <subject>` | Open HelpBrowser for \<subject\>                               |
| `SCNvimStatusLine`     | Start to poll server status to be displayed in the status line |

### Additional setup

Run `:SCNvimGenerateAssets` after starting SuperCollider to generate syntax highlighting and tags.

The plugin should work "out of the box", but if you want even more fine-grained
control please have a look at this [section](https://github.com/davidgranstrom/scnvim/wiki/Additional-configuration) in the wiki.

## Supported platforms

* Linux
* macOS
* Windows (tested with `nvim-qt`)

### Note to Windows users

To be able to boot the server you will need to add the following to your `startup.scd`:

```supercollider
if (\SCNvim.asClass.notNil) {
  Server.program = (Platform.resourceDir +/+ "scsynth.exe").quote;
}
```

## License

```plain
scnvim - Neovim frontend for SuperCollider
Copyright © 2018 David Granström

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
