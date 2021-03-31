syn match words "\<\a\|\.\a" contains=words display transparent
syn match words "\a\+:" display contained

" hi def link words Underlined
hi def link words Statement

" syn match numbers "\<\d\|\.\d" contains=numbers display transparent
" syn match numbers "\d\+" display contained
" syn match numbers "\.\d\+" display contained

" hi def link numbers Number

