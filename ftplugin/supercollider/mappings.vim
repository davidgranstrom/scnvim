" File: ftplugin/supercollider/mappings.vim
" Author: David Granström
" Description: scnvim mappings

scriptencoding utf-8

if exists('b:did_scnvim_mappings')
  finish
endif
let b:did_scnvim_mappings = 1

if !exists('g:scnvim_no_mappings') || !g:scnvim_no_mappings
  if !hasmapto('<Plug>(scnvim-send-line)', 'ni')
    nmap <buffer> <M-e> <Plug>(scnvim-send-line)
    imap <buffer> <M-e> <c-o><Plug>(scnvim-send-line)
  endif

  if !hasmapto('<Plug>(scnvim-send-selection)', 'x')
    xmap <buffer> <C-e> <Plug>(scnvim-send-selection)
  endif

  if !hasmapto('<Plug>(scnvim-send-block)', 'ni')
    nmap <buffer> <C-e> <Plug>(scnvim-send-block)
    imap <buffer> <C-e> <c-o><Plug>(scnvim-send-block)
  endif

  if !hasmapto('<Plug>(scnvim-hard-stop)', 'ni')
    nmap <buffer> <F12> <Plug>(scnvim-hard-stop)
    imap <buffer> <F12> <c-o><Plug>(scnvim-hard-stop)
  endif

  if !hasmapto('<Plug>(scnvim-postwindow-toggle)', 'ni')
    nmap <buffer> <CR> <Plug>(scnvim-postwindow-toggle)
    imap <buffer> <M-CR> <c-o><Plug>(scnvim-postwindow-toggle)
  endif

  if !hasmapto('<Plug>(scnvim-postwindow-clear)', 'ni')
    nmap <buffer> <M-L> <Plug>(scnvim-postwindow-clear)
    imap <buffer> <M-L> <c-o><Plug>(scnvim-postwindow-clear)
  endif

  if !hasmapto('<Plug>(scnvim-print-signature)', 'ni')
    nmap <buffer> <C-k> <Plug>(scnvim-print-signature)
    imap <buffer> <C-k> <c-o><Plug>(scnvim-print-signature)
  endif
endif
