# scnvim

[Neovim][neovim] frontend for [SuperCollider][supercollider].

[![unit tests](https://github.com/davidgranstrom/scnvim/actions/workflows/ci.yml/badge.svg)](https://github.com/davidgranstrom/scnvim/actions/workflows/ci.yml)
[![lint and style check](https://github.com/davidgranstrom/scnvim/actions/workflows/lint.yml/badge.svg)](https://github.com/davidgranstrom/scnvim/actions/workflows/lint.yml) 
[![docs](https://github.com/davidgranstrom/scnvim/actions/workflows/docs.yml/badge.svg)](https://github.com/davidgranstrom/scnvim/actions/workflows/docs.yml)

## Table of content

* [Features](#features)
* [Installation](#installation)
* [Usage](#usage)
* [Documentation](#documentation)
* [Extensions](#extensions)
* [Supported platforms](#supported-platforms)

## Features

* Post window output is displayed in a scratch buffer
  - Uses a split or a floating window for display
  - Navigate/move/copy etc. as with any other window
  - Toggle back if hidden automatically on errors
* Automatic display of function signatures
* Status line widgets
  - Display SuperCollider server status in the status line
* Snippet generator
  - Generates snippets for creation methods in SCClassLibrary.
* Can be used with Neovim [GUI frontends](https://github.com/neovim/neovim/wiki/Related-projects#gui)
* Supports [on-demand loading](https://github.com/junegunn/vim-plug#on-demand-loading-of-plugins)
* Context aware (block or line) evaluation (like `Cmd-Enter` in ScIDE)
* Flashy eval flash (configurable)
* Partial `Document` support (e.g. `thisProcess.nowExecutingPath`, `.load` etc.)
* Plain text help system for SuperCollider documentation
  - Evaluate code examples inside the help buffer

## Installation

### Requirements

* [Neovim][neovim] >= 0.7
* [SuperCollider][supercollider]

### Install

* Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
  'davidgranstrom/scnvim',
  ft = 'supercollider',
  config = function()
    local scnvim = require 'scnvim'
    local map = scnvim.map
    local map_expr = scnvim.map_expr
    scnvim.setup {
      -- your config here
    }
  end
}
```

* Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use { 'davidgranstrom/scnvim' }
```

* Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'davidgranstrom/scnvim'
```

### Verify

Run `:checkhealth scnvim` to verify that the installation was successful.

## Usage

### Configuration

`scnvim` uses `lua` for configuration. Below is an example that you can copy
and paste to your `init.lua`.

If you are using `init.vim` for configuration you will need to surround the
call to `scnvim.setup` in a `lua-heredoc`:

```vim
" file: init.vim
lua << EOF
require('scnvim').setup({})
EOF
```

### Example

```lua
local scnvim = require 'scnvim'
local map = scnvim.map
local map_expr = scnvim.map_expr

scnvim.setup({
  keymaps = {
    ['<M-e>'] = map('editor.send_line', {'i', 'n'}),
    ['<C-e>'] = {
      map('editor.send_block', {'i', 'n'}),
      map('editor.send_selection', 'x'),
    },
    ['<CR>'] = map('postwin.toggle'),
    ['<M-CR>'] = map('postwin.toggle', 'i'),
    ['<M-L>'] = map('postwin.clear', {'n', 'i'}),
    ['<C-k>'] = map('signature.show', {'n', 'i'}),
    ['<F12>'] = map('sclang.hard_stop', {'n', 'x', 'i'}),
    ['<leader>st'] = map('sclang.start'),
    ['<leader>sk'] = map('sclang.recompile'),
    ['<F1>'] = map_expr('s.boot'),
    ['<F2>'] = map_expr('s.meter'),
  },
  editor = {
    highlight = {
      color = 'IncSearch',
    },
  },
  postwin = {
    float = {
      enabled = true,
    },
  },
})
```

### Start

Open a new file in `nvim` with a `.scd` or `.sc` extension and type `:SCNvimStart` to start SuperCollider.

### Commands

| Command                | Description                                                    |
|:-----------------------|:---------------------------------------------------------------|
| `SCNvimStart`          | Start SuperCollider                                            |
| `SCNvimStop`           | Stop SuperCollider                                             |
| `SCNvimRecompile`      | Recompile SCClassLibrary                                       |
| `SCNvimGenerateAssets` | Generate tags, syntax, snippets etc.                           |
| `SCNvimHelp <subject>` | Open help for \<subject\> (By default mapped to `K`)           |
| `SCNvimStatusLine`     | Start to poll server status to be displayed in the status line |

### Additional setup

Run `:SCNvimGenerateAssets` after starting SuperCollider to generate syntax highlighting and tags.

The plugin should work "out of the box", but if you want even more fine-grained
control please have a look at the [configuration
section](https://github.com/davidgranstrom/scnvim/wiki/Configuration) in the
wiki.

## Documentation

* `:help scnvim` for detailed documentation.
* [API documentation](https://davidgranstrom.github.io/scnvim/)

## Extensions

The extension system provides additional functionalities and integrations. If
you have made a scnvim extension, please open a PR and add it to this list!

* [fzf-sc](https://github.com/madskjeldgaard/fzf-sc)
  - Combine the magic of fuzzy searching with the magic of SuperCollider in Neovim
* [nvim-supercollider-piano](https://github.com/madskjeldgaard/nvim-supercollider-piano)
  - Play SuperCollider synths using your (computer) keyboard in neovim!
* [scnvim-tmux](https://github.com/davidgranstrom/scnvim-tmux)
  - Redirect post window ouput to a tmux pane.
* [scnvim-logger](https://github.com/davidgranstrom/scnvim-logger)
  - Log post window output to a file (example scnvim extension)
* [telescope-scdoc](https://github.com/davidgranstrom/telescope-scdoc.nvim)
  - Use Telescope to fuzzy find documentation

## Supported platforms

* Linux
* macOS
* Windows (tested with `nvim-qt` and `nvim.exe` in Windows PowerShell)

### Note to Windows users

The path to `sclang.exe` needs to be specified in the config:

```lua
local scnvim = require('scnvim')
scnvim.setup({
  sclang = {
    cmd = 'C:/Program Files/SuperCollider-3.12.2/sclang.exe'
  },
})
```

Modify the `sclang.cmd` to point to where SuperCollider is installed on your system.

Additionally, to be able to boot the server you will need to add the following to `startup.scd`:

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
