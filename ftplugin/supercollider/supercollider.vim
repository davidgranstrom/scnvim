" File: ftplugin/supercollider/supercollider.vim
" Author: David Granström
" Description: General settings

if exists("b:did_scnvim")
  finish
endif
let b:did_scnvim = 1

" tags
let s:tagsFile = expand(get(g:, 'scnvim_root_dir') . '/scnvim-data/tags')
if filereadable(s:tagsFile)
  execute "setlocal tags+=" . s:tagsFile
endif

" matchit
let b:match_skip = 's:scComment\|scString\|scSymbol'
let b:match_words = '(:),[:],{:}'

" help
setlocal keywordprg=:SCNvimHelp

" indentation
setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4

" comments
setlocal commentstring=\/\/%s

" extras
if !exists('g:scnvim_no_extras') && has('python3')
  let g:scnvim_python_port = __scnvim_server_start()
  augroup scnvim_echo_args
    autocmd! * <buffer>
    autocmd InsertCharPre <buffer> call scnvim#util#echo_args()
  augroup END
  " for argument hints
  setlocal noshowmode
  setlocal shortmess+=c
endif
