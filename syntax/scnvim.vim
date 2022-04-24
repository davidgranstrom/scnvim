" Syntax highlighting for the scnvim post window
"
" By Mads Kjeldgaard
" 2020-05-11
"
"
" Building on the work of Alex Norman, David Granström and Stephen Lumenta for
" SuperCollider, SCVIM and SCNVIM.

scriptencoding utf-8

" Check if syntax highlighting for the post window is active
if !get(g:, 'scnvim_postwin_syntax_hl', 1)
	finish
end

" Check if this syntax file has been loaded before
if exists('b:current_syntax')
	finish
endif
let b:current_syntax = 'scnvim'

syn case match " Not case sensitive

" Result of execution
syn region result start=/^->/ end=/\n/

" Using Log.quark
syn match logger /^\[\w*\]/

"""""""""""""""""""
" Error and warning messages
"""""""""""""""""""
syn match errorCursor "\^\^"
syn match errors /ERROR:.*$/
syn match receiverError /RECEIVER:.*$/
syn match fails /FAIL:.*$/
syn match warns /WARNING:.*$/
syn match exceptions /EXCEPTION:.*$/

syn match errorblock /^ERROR:.*$/
syn match receiverBlock /^RECEIVER:.*$/
syn match protectedcallstack /^PROTECTED CALL STACK:.*$/
syn match callstack /^CALL STACK:.*$/

" unittests
syn match unittestPass /^PASS:.*$/
syn match unittestRunning /^RUNNING UNIT TEST.*$/

"""""""""""""""""""
" Linking
"""""""""""""""""""

" Special scnvim links
hi def link errors ErrorMsg
hi def link errorBlock ErrorMsg
hi def link receiverError ErrorMsg
hi def link exceptions ErrorMsg
hi def link errorCursor Bold
hi def link fails ErrorMsg
hi def link syntaxErrorContent Underlined
hi def link warns WarningMsg

hi def link receiverBlock WarningMsg
hi def link callstack WarningMsg
hi def link protectedcallstack WarningMsg

hi def link logger Bold
hi def link unittestPass String

hi def link result String
