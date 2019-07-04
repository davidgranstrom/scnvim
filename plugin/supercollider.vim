" File: plugin/supercollider.vim
" Author: David Granström
" Description: scnvim setup

if exists('g:scnvim_loaded')
  finish
endif
let g:scnvim_loaded = 1

let g:scnvim_root_dir = expand('<sfile>:h:h')
let g:scnvim_stl_widgets = {}

" augroup to be used w/ ftplugin
augroup scnvim
  autocmd!
augroup END

" eval flash default color
highlight default SCNvimEval guifg=black guibg=white ctermfg=black ctermbg=white
autocmd scnvim ColorScheme * highlight default SCNvimEval guifg=black guibg=white ctermfg=black ctermbg=white

noremap <unique><script><silent> <Plug>(scnvim-send-line) :<c-u>call scnvim#send_line(0, 0)<cr>
noremap <unique><script><silent> <Plug>(scnvim-send-block) :<c-u>call scnvim#send_block()<cr>
noremap <unique><script><silent> <Plug>(scnvim-send-selection) :<c-u>call scnvim#send_selection()<cr>
noremap <unique><script><silent> <Plug>(scnvim-postwindow-toggle) :<c-u>call scnvim#postwindow#toggle()<cr>
noremap <unique><script><silent> <Plug>(scnvim-postwindow-clear) :<c-u>call scnvim#postwindow#clear()<cr>
noremap <unique><script><silent> <Plug>(scnvim-hard-stop) :<c-u>call scnvim#hard_stop()<cr>
