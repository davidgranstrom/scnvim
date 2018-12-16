" File: ftplugin/supercollider/mappings.vim
" Author: David Granström
" Description: scnvim mappings

if exists("b:did_scnvim_mappings")
  finish
endif

let b:did_scnvim_mappings = 1

if !exists("g:scnvim_no_mappings") || !g:scnvim_no_mappings
  if !hasmapto('<Plug>(scnvim-send-line)', 'ni')
    nmap <buffer> <M-e> <Plug>(scnvim-send-line)
    imap <buffer> <M-e> <c-o><Plug>(scnvim-send-line)
  endif

  if !hasmapto('<Plug>(scnvim-send-region)', 'x')
    xmap <buffer> <C-e> <Plug>(scnvim-send-selection)
  endif

  if !hasmapto('<Plug>(scnvim-send-block)', 'n')
    nmap <buffer> <C-e> <Plug>(scnvim-send-block)
    imap <buffer> <C-e> <c-o><Plug>(scnvim-send-block)
  endif

  if !hasmapto('<Plug>(scnvim-hard-stop)', 'ni')
    nmap <buffer> <F12> <Plug>(scnvim-hard-stop)
    imap <buffer> <F12> <c-o><Plug>(scnvim-hard-stop)
  endif

  if !hasmapto('<Plug>(scnvim-open-postwindow)', 'ni')
    nmap <buffer> <CR> <Plug>(scnvim-open-postwindow)
    imap <buffer> <M-CR> <c-o><Plug>(scnvim-open-postwindow)
  endif
endif
