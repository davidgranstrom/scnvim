" File: ftplugin/supercollider/mappings.vim
" Author: David Granström
" Description: scnvim mappings
" Last Modified: October 14, 2018

if exists("b:did_scnvim_mappings")
  finish
endif

let b:did_scnvim_mappings = 1

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
