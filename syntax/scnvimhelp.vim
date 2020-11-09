scriptencoding utf-8

" Without the two following lines, neco-syntax will create trouble
let b:current_syntax = ''
unlet b:current_syntax
runtime! syntax/help.vim

" Needed when importing syntax highlighting
let b:current_syntax = ''
unlet b:current_syntax
syntax include @SC syntax/supercollider.vim
syntax region scSnip matchgroup=Snip start="//SCNVIM_SNIP_START" end="//SCNVIM_SNIP_END" contains=@SC
hi link Snip Comment

let b:current_syntax = 'scnvimhelp' 
