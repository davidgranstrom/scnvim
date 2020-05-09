# scnvim

[![Build Status](https://travis-ci.com/davidgranstrom/scnvim.svg?branch=master)](https://travis-ci.com/davidgranstrom/scnvim)

[SuperCollider][supercollider] integration for [Neovim][neovim]

## Note

Please note that this plugin is still in active development. It should be
stable enough by now for everyday use. If you encounter any bugs, or have ideas
for new features, please report them on the [issue
tracker](https://github.com/davidgranstrom/scnvim/issues), thanks!

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
* Partial `Document` support (e.g. `thisProcess.nowExecutingPath`)

## Showcase

### Post window displayed in a regular vim buffer

* Toggle the post window buffer by pressing `<Enter>` in normal mode or `<M-Enter>` in insert mode.

![post window](https://user-images.githubusercontent.com/672917/51938975-b5380400-240e-11e9-8e28-428c7b811501.gif)

### Interactive argument hints in the command-line area

* Arguments are automatically displayed after typing the opening brace.

![argument hints](https://user-images.githubusercontent.com/672917/51938974-b5380400-240e-11e9-832a-829b48992bf0.gif)

### Status line

* Displays server status in the status line

![server status](https://user-images.githubusercontent.com/672917/51938976-b5380400-240e-11e9-9799-58c1cde5c47c.gif)

### Snippet generator

* The snippet engine used here is [UltiSnips][UltiSnips] together with [deoplete](https://github.com/Shougo/deoplete.nvim) for auto completion.

![snippets](https://user-images.githubusercontent.com/672917/51938977-b5d09a80-240e-11e9-82fb-758471e45fa1.gif)

## Installation

### Requirements

* [Neovim][neovim] >= 0.4.3
* [SuperCollider][supercollider]

### Procedure

#### 1. Install the vim plugin

* Using [vim-plug](https://github.com/junegunn/vim-plug)

  * Add this line to your init.vim

    ```vim
    Plug 'davidgranstrom/scnvim'
    ```

  * Open nvim and run `:PlugInstall`

* Using the internal package manager

  * Manually clone to your plugin directory. If you used a different directory for other plugins, use that instead.

    ```shell
    mkdir -p ~/.local/share/nvim/site/pack/git-plugins/start && cd "$_"
    git clone https://github.com/davidgranstrom/scnvim
    ```

#### 2. Install the SCNvim SuperCollider classes

The SuperCollider classes are located in the `sc/` directory of this repo.

This directory needs to be linked to your SuperCollider `Extensions` directory (run `Platform.userExtensionDir` in SuperCollider to see where it is located on your platform).

1. Create a directory named `scide_scvim` in the Extensions directory. It is **important** that the directory is named `scide_scvim` (note the omitted 'n') to avoid conflicts with ScIDE.

2. Create a `symlink` (symbolic link) to the `sc` directory of the plugin like in the example below.

#### Examples

* **macOS**

    ```shell
    # create scide_scvim directory
    mkdir -p ~/Library/Application\ Support/SuperCollider/Extensions/scide_scvim

    # create a symbolic link to 'sc' in the 'scide_scvim' directory named 'scnvim'
    ln -s ~/.config/nvim/plugged/scnvim/sc ~/Library/Application\ Support/SuperCollider/Extensions/scide_scvim/scnvim
    ```

* **Linux**

    It is **important** to use absolute paths. If `~` or `$HOME` or other aliases for `/home/<user>` is used the symbolic link will be "dangling" which renders a situation where sclang crashes immediately when started.

    ```shell
    # create scide_scvim directory
    mkdir -p $HOME/.local/share/SuperCollider/Extensions/scide_scvim
    
    # create a symbolic link to 'sc' in the 'scide_scvim' directory named 'scnvim'
    ln -s /home/<USER>/.config/nvim/plugged/scnvim/sc /home/<USER>/.local/share/SuperCollider/Extensions/scide_scvim/scnvim
    ```

    If the above symlink does not work (you can tell this by opening up a
    SuperCollider file and running `:SCNvimStart` - if something's wrong the
    post window will contain errors about SC not being able to find the SCNvim
    class files), make sure the path to the vim plugin is correct. Depending on
    how you have configured nvim, it might be `/home/<USER>/.vim/plugged/scnvim/sc`.

#### 3. Starting SCNvim

Open a new file in `nvim` with a `.scd` or `.sc` extension and type `:SCNvimStart` to start SuperCollider.

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

To disable all default mappings specify `let g:scnvim_no_mappings = 1` in your vimrc/init.vim

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
```

## Example configuration

This is not a recommended configuration but rather a way to show how a minimal `init.vim` could look to configure the plugin.

```vim
" vim-plug
call plug#begin('path/to/plugin/directory')
  Plug 'davidgranstrom/scnvim'
  " (optional) for snippets
  Plug 'SirVer/ultisnips'
call plug#end()

" scnvim
"
" post window at the bottom
let g:scnvim_postwin_orientation = 'h'

" remap send block
nmap <F5> <Plug>(scnvim-send-block)

" remap post window toggle
nmap <Space>o <Plug>(scnvim-postwindow-toggle)

" eval flash colors
highlight SCNvimEval guifg=black guibg=cyan ctermfg=black ctermbg=cyan
" this autocmd keeps the custom highlight when changing colorschemes
augroup scnvim_vimrc
  autocmd!
  autocmd ColorScheme *
        \ highlight SCNvimEval guifg=black guibg=cyan ctermfg=black ctermbg=cyan
augroup END

" hard coded path to sclang executable
let g:scnvim_sclang_executable = '~/bin/sclang'

" enable snippets support
let g:UltiSnipsSnippetDirectories = ['UltiSnips', 'scnvim-data']

" create a custom status line for supercollider buffers
function! s:set_sclang_statusline()
  setlocal stl=
  setlocal stl+=%f
  setlocal stl+=%=
  setlocal stl+=%(%l,%c%)
  setlocal stl+=\ \|
  setlocal stl+=%24.24{scnvim#statusline#server_status()}
endfunction

augroup scnvim_stl
  autocmd!
  autocmd FileType supercollider call <SID>set_sclang_statusline()
augroup END

" lightline.vim example
" let g:lightline = {}
" let g:lightline.component_function = {
"   \ 'server_status': 'scnvim#statusline#server_status',
"   \ }
"
" function! s:set_sclang_lightline_stl()
"   let g:lightline.active = {
"   \ 'left':  [ [ 'mode', 'paste' ],
"   \          [ 'readonly', 'filename', 'modified' ] ],
"   \ 'right': [ [ 'lineinfo' ],
"   \            [ 'percent' ],
"   \            [ 'server_status'] ]
"   \ }
" endfunction
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
