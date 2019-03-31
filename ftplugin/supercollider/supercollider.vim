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

" remote plugin
if has('python3')
  let port = get(g:, 'scnvim_udp_port', 9670)
  let g:scnvim_python_port = __scnvim_server_start(port)
  if !exists('g:scnvim_echo_args') || g:scnvim_echo_args == 1
    augroup scnvim_echo_args
      autocmd! * <buffer>
      autocmd InsertCharPre <buffer> call scnvim#util#echo_args()
    augroup END
    " for argument hints
    setlocal noshowmode
    setlocal shortmess+=c
  endif
endif

" auto commands
function! s:apply_quickfix_conceal()
  echom &ft
  syntax match SCNvimConcealResults /^.*Help\/\|.txt\||.*|\|/ conceal
  setlocal conceallevel=2
  setlocal concealcursor=nvic
endfunction

augroup scnvim_qf_conceal
  autocmd!
  autocmd BufWinEnter quickfix call s:apply_quickfix_conceal()
augroup END

function! s:try_close_float_win()
  let winid = get(g:, 'scnvim_arghints_float_id')
  if winid > 0
    call nvim_win_close(winid, v:true)
    let g:scnvim_arghints_float_id = 0
  endif
endfunction

augroup scnvim_arghints_float
  autocmd!
  autocmd InsertLeave * call s:try_close_float_win()
augroup END
