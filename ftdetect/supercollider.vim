if !exists('g:do_filetype_lua')
  autocmd BufEnter,BufWinEnter,BufNewFile,BufRead *.schelp set filetype=scdoc
endif
