" File: ftplugin/supercollider/supercollider.vim
" Author: David Granström
" Description: General settings

scriptencoding utf-8

if exists('b:did_scnvim')
  finish
endif
let b:did_scnvim = 1

" tags
let s:tagsFile = expand(get(g:, 'scnvim_root_dir') . '/scnvim-data/tags')
if filereadable(s:tagsFile)
  execute 'setlocal tags+=' . s:tagsFile
endif

" matchit
let b:match_skip = 's:scComment\|scString\|scSymbol'
let b:match_words = '(:),[:],{:}'

" help
setlocal keywordprg=:SCNvimHelp

" comments
setlocal commentstring=\/\/%s

" auto commands
let enable_arghints = get(g:, 'scnvim_echo_args', 1)
if enable_arghints
  augroup scnvim_echo_args
    autocmd! * <buffer>
    autocmd InsertCharPre <buffer> call scnvim#util#echo_args_insert()
  augroup END
  " for argument hints
  let no_float = get(g:, 'scnvim_arghints_float', 1)
  if no_float == 0
    setlocal noshowmode
    setlocal shortmess+=c
  endif
endif

function! s:apply_quickfix_conceal()
  syntax match SCNvimConcealResults /^.*Help\/\|.txt\||.*|\|/ conceal
  setlocal conceallevel=2
  setlocal concealcursor=nvic
endfunction

augroup scnvim_qf_conceal
  autocmd!
  autocmd BufWinEnter quickfix call s:apply_quickfix_conceal()
augroup END
