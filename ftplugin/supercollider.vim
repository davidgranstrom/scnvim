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

execute "set tags+=".s:sclangTagsFile

" matchit
let b:match_skip = 's:scComment\|scString\|scSymbol'
let b:match_words = '(:),[:],{:}'

command! -buffer -range SCnvimLineSend call scnvim#supercollider#line_send()
" command! -buffer SCnvimParagraphSend call supercollider#paragraph_send()
command! -buffer SCnvimStart call scnvim#sclang#open()
command! -buffer SCnvimStop call scnvim#sclang#close()

" mappings
if !exists("g:scnvim_no_mappings") || !g:scnvim_no_mappings
  if !hasmapto('<Plug>(scnvim-config)', 'n')
    nmap <buffer> <localleader>c <Plug>(scnvim-config)
  endif

  if !hasmapto('<Plug>(scnvim-send-region)', 'x')
    xmap <buffer> <C-e> <Plug>(scnvim-send-region)
  endif

  if !hasmapto('<Plug>(scnvim-line-send)', 'n')
    nmap <buffer> <C-e> <Plug>(scnvim-line-send)
    imap <buffer> <C-e> <Esc><Plug>(scnvim-line-send)<Esc>a
  endif

  if !hasmapto('<Plug>(scnvim-paragraph-send)', 'n')
    nmap <buffer> <C-e> <Plug>(scnvim-paragraph-send)
    imap <buffer> <C-e> <Esc><Plug>(scnvim-paragraph-send)<Esc>i<Right>
  endif
endif
