" File: ftplugin/supercollider/mappings.vim
" Author: David Granström
" Description: scnvim mappings
" Last Modified: October 14, 2018

if exists("b:did_scnvim_mappings")
  finish
endif

let b:did_scnvim_mappings = 1

noremap <unique><script><silent> <Plug>(scnvim-send-line) :<c-u>call scnvim#send_line()<cr>
noremap <unique><script><silent> <Plug>(scnvim-send-block) :<c-u>call scnvim#send_block()<cr>
noremap <unique><script><silent> <Plug>(scnvim-send-selection) :<c-u>call scnvim#send_selection()<cr>
noremap <unique><script><silent> <Plug>(scnvim-open-postwindow) :<c-u>call scnvim#open_post_window()<cr>

if !exists("g:scnvim_no_mappings") || !g:scnvim_no_mappings
  if !hasmapto('<Plug>(scnvim-send-line)', 'ni')
    nmap <buffer> <C-e> <Plug>(scnvim-send-line)
    imap <buffer> <C-e> <c-o><Plug>(scnvim-send-line)
  endif

  if !hasmapto('<Plug>(scnvim-open-postwindow)', 'n')
    nmap <buffer> <CR> <Plug>(scnvim-open-postwindow)
    " imap <buffer> <C-e> <c-o><Plug>(scnvim-open-postwindow)
  endif

  if !hasmapto('<Plug>(scnvim-send-region)', 'x')
    xmap <buffer> <C-e> <Plug>(scnvim-send-selection)
  endif

  if !hasmapto('<Plug>(scnvim-send-block)', 'n')
    nmap <buffer> <M-e> <Plug>(scnvim-send-block)
    imap <buffer> <M-e> <c-o><Plug>(scnvim-send-block)
  endif
endif
