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

command! -buffer SCnvimStart call scnvim#sclang#open()
command! -buffer SCnvimStop call scnvim#sclang#close()

command! -buffer -range=% SCnvimSendFile call scnvim#supercollider#send_line(<line1>, <line2>)
command! -buffer -range SCnvimSendLine call scnvim#supercollider#send_line(<line1>, <line2>)
command! -buffer -range SCnvimSendSelection call scnvim#supercollider#send_selection()

nnoremap <Enter> :SCnvimSendLine<cr>
xnoremap <Enter> :SCnvimSendLine<cr>

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
