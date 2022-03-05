" vint: -ProhibitAutocmdWithNoGroup
if !has("nvim-0.7")
    autocmd! BufEnter,BufWinEnter,BufNewFile,BufRead *.sc set filetype=supercollider
    autocmd BufEnter,BufWinEnter,BufNewFile,BufRead *.scd set filetype=supercollider
    autocmd BufEnter,BufWinEnter,BufNewFile,BufRead *.schelp set filetype=scdoc
endif
