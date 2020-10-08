" File: plugin/supercollider.vim
" Author: David Granström
" Description: scnvim setup

scriptencoding utf-8

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

autocmd scnvim ColorScheme * highlight default SCNvimEval guifg=black guibg=white ctermfg=black ctermbg=white
autocmd scnvim BufEnter,BufNewFile,BufRead *.scd,*.sc call scnvim#document#set_current_path()

" eval flash default color
highlight default SCNvimEval guifg=black guibg=white ctermfg=black ctermbg=white

noremap <unique><script><silent> <Plug>(scnvim-send-line) :<c-u>call scnvim#send_line(0, 0)<cr>
noremap <unique><script><silent> <Plug>(scnvim-send-block) :<c-u>call scnvim#send_block()<cr>
noremap <unique><script><silent> <Plug>(scnvim-send-selection) :<c-u>call scnvim#send_selection()<cr>
noremap <unique><script><silent> <Plug>(scnvim-recompile) :<c-u>call scnvim#sclang#recompile()<cr>
noremap <unique><script><silent> <Plug>(scnvim-postwindow-toggle) :<c-u>call scnvim#postwindow#toggle()<cr>
noremap <unique><script><silent> <Plug>(scnvim-postwindow-clear) :<c-u>call scnvim#postwindow#clear()<cr>
noremap <unique><script><silent> <Plug>(scnvim-hard-stop) :<c-u>call scnvim#hard_stop()<cr>
noremap <unique><script><silent> <Plug>(scnvim-print-signature) :<c-u>call scnvim#util#echo_args()<cr>

" deprecated
if exists('g:scnvim_udp_port')
  echohl WarningMsg
  echom '[scnvim] g:scnvim_udp_port is deprecated.
        \ Use SCNvim.port if you need the port number
        \ in SuperCollider.'
  echohl None
endif

if exists('g:scnvim_pandoc_executable')
  echohl WarningMsg
  echom '[scnvim] g:scnvim_pandoc_executable is deprecated.
        \ Use g:scnvim_scdoc_render_prg instead.
        \ See :h scnvim-help-system for more details.'
  echohl None
endif
