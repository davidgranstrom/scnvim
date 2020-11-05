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

if (g:scnvim_colour_post_window == 1)

	" syn clear
	syn case match " Not case sensitive

	" Result of execution
	syn region result start=/->/ end=/\n/

	"""""""""""""""""""
	" Error and warning messages
	"""""""""""""""""""
	syn keyword errors ERROR
	syn keyword warns WARNING RECEIVER ARGS PATH CALL STACK Info

	" for instance blocks in stack errors ala <Instance of Object> 
	syn region instanceError start=/</ end=/>/

	" Seperator after error
	syn match separator /-----------------------------------/

	" Syntax error position
	syn match syntaxErrLine /line \d\+/ contained
	syn match syntaxErrChar /char \d\+:/ contained
	syn match syntaxErrCursor / ^/ contained
	syn region syntaxErrorContent start=/line \d\+ char \d\+/ end=/ ^/ contains=syntaxErrLine,syntaxErrChar

	"""""""""""""""""""
	" Misc
	"""""""""""""""""""

	" Welcome message
	" syn region welcome start=/\*\*\*/ end=/\*\*\*/
	syn match welcomeWords "Welcome to SuperCollider"
	syn region welcome start=/\*\*\*/ end=/$/ contains=welcomeWords

	syn region compiling start=/\ccompil/ end=/$/

	"""""""""""""""""""
	" Linking
	"""""""""""""""""""

	" Special scnvim links
	hi def link errors ErrorMsg
	hi def link syntaxErrLine Underlined
	hi def link syntaxErrChar Underlined
	hi def link syntaxErrCursor TerminalCursor
	hi def link syntaxErrorContent WarningMsg
	hi def link instanceError WarningMsg
	hi def link warns WarningMsg
	hi def link separator scComment

	hi def link welcome Title
	hi def link welcomeWords Title
	hi def link compiling Comment

	hi def link result String
endif
