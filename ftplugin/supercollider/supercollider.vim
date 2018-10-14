" File: ftplugin/supercollider/supercollider.vim
" Author: David Granström
" Description: Filetype plugin
" Last Modified: October 08, 2018

if exists("b:did_scnvim")
  finish
endif

let b:did_scnvim = 1

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
function! s:open_help_for(subject)
  let cmd = printf('HelpBrowser.openHelpFor("%s");', a:subject)
  call scnvim#sclang#send(cmd)
endfunction

command! -buffer -nargs=+ SCnvimHelp call s:open_help_for(<q-args>)
setlocal keywordprg=:SCnvimHelp
