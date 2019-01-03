" File: plugin/supercollider.vim
" Author: David Granström
" Description: scnvim setup

if exists('g:scnvim_loaded')
  finish
endif
let g:scnvim_loaded = 1

noremap <unique><script><silent> <Plug>(scnvim-send-line) :<c-u>call scnvim#send_line()<cr>
noremap <unique><script><silent> <Plug>(scnvim-send-block) :<c-u>call scnvim#send_block()<cr>
noremap <unique><script><silent> <Plug>(scnvim-send-selection) :<c-u>call scnvim#send_selection()<cr>
noremap <unique><script><silent> <Plug>(scnvim-postwindow-open) :<c-u>call scnvim#toggle_post_window()<cr>
noremap <unique><script><silent> <Plug>(scnvim-postwindow-clear) :<c-u>call scnvim#clear_post_window()<cr>
noremap <unique><script><silent> <Plug>(scnvim-hard-stop) :<c-u>call scnvim#hard_stop()<cr>
