" File: ftplugin/supercollider.vim
" Author: David Granström
" Description: Filetype plugin
" Last Modified: October 08, 2018

if exists("b:did_scnvim")
  finish
endif

let b:did_scnvim = 1

if exists($SCVIM_TAGFILE)
  let s:sclangTagsFile = $SCVIM_TAGFILE
else
  let s:sclangTagsFile = "~/.sctags"
endif

execute "setlocal tags+=" . s:sclangTagsFile

" matchit
let b:match_skip = 's:scComment\|scString\|scSymbol'
let b:match_words = '(:),[:],{:}'

command! -buffer SCnvimStart call scnvim#sclang#open()
command! -buffer SCnvimStop call scnvim#sclang#close()

command! -buffer -range=% SCnvimSendFile call scnvim#send_line(<line1>, <line2>)
command! -buffer -range SCnvimSendLine call scnvim#send_line(<line1>, <line2>)
command! -buffer -range SCnvimSendSelection call scnvim#send_selection()
command! -buffer -range SCnvimSendBlock call scnvim#send_block()

noremap <unique><script><silent> <Plug>(scnvim-send-line) :<c-u>call scnvim#send_line()<cr>
noremap <unique><script><silent> <Plug>(scnvim-send-block) :<c-u>call scnvim#send_block()<cr>
noremap <unique><script><silent> <Plug>(scnvim-send-selection) :<c-u>call scnvim#send_selection()<cr>

if !exists("g:scnvim_no_mappings") || !g:scnvim_no_mappings
  if !hasmapto('<Plug>(scnvim-send-line)', 'ni')
    nmap <buffer> <C-e> <Plug>(scnvim-send-line)
    imap <buffer> <C-e> <c-o><Plug>(scnvim-send-line)
  endif

  if !hasmapto('<Plug>(scnvim-send-region)', 'x')
    xmap <buffer> <C-e> <Plug>(scnvim-send-selection)
  endif

  if !hasmapto('<Plug>(scnvim-send-block)', 'n')
    nmap <buffer> <M-e> <Plug>(scnvim-send-block)
    imap <buffer> <M-e> <c-o><Plug>(scnvim-send-block)
  endif
endif
