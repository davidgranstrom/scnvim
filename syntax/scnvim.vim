" Syntax highlighting for the scnvim post window
"
" By Mads Kjeldgaard
" 2020-05-11
"
"
" Building on the work of Alex Norman, David Granström and Stephen Lumenta for
" SuperCollider, SCVIM and SCNVIM.

scriptencoding utf-8

if exists('b:current_syntax')
  finish
endif
let b:current_syntax = 'scnvim'

syn case match " Not case sensitive
syn keyword errors ERROR
syn keyword warns WARNING RECEIVER ARGS PATH CALL STACK

" Error messages

" for instance blocks in stack errors ala <Instance of Object> 
syn region instanceError start=/</ end=/>/

" Seperator after error
syn match separator /-----------------------------------/

" Result of execution
syn region result start=/->/ end=/\n/

" Set highlight colors
hi def link scObject Identifier
hi def link errors ErrorMsg
hi def link instanceError WarningMsg
hi def link warns WarningMsg
hi def link separator Comment
hi def link result String
