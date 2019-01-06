" File: ftplugin/supercollider/supercollider.vim
" Author: David Granström
" Description: Filetype plugin
" Last Modified: October 08, 2018

if exists("b:did_scnvim")
  finish
endif

let b:did_scnvim = 1

augroup scnvim
  au!
augroup END

" setup sctags like scvim
if exists($SCVIM_TAGFILE)
  let s:sclangTagsFile = $SCVIM_TAGFILE
else
  let s:sclangTagsFile = "~/.sctags"
endif

execute "setlocal tags+=" . s:sclangTagsFile

" matchit
let b:match_skip = 's:scComment\|scString\|scSymbol'
let b:match_words = '(:),[:],{:}'

" help
setlocal keywordprg=:SCNvimHelp

" indentation
setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4

" completion
if exists('g:scnvim_echo_args')
  setlocal shortmess+=c
  " .ar/.kr command line hint
  autocmd scnvim InsertCharPre * call scnvim#util#echo_ar_kr_args()
endif
