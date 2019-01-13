" scnvim post window
setlocal buftype=nofile
setlocal bufhidden=hide
setlocal noswapfile
setlocal nonu nornu nolist nomodeline nowrap
setlocal nocursorline nocursorcolumn colorcolumn=
setlocal foldcolumn=0 nofoldenable winfixwidth
setlocal tabstop=4

" toggle mapping
if !exists("g:scnvim_no_mappings") || !g:scnvim_no_mappings
  if !hasmapto('<Plug>(scnvim-postwindow-toggle)', 'ni')
    nmap <buffer> <CR> <Plug>(scnvim-postwindow-toggle)
    imap <buffer> <M-CR> <c-o><Plug>(scnvim-postwindow-toggle)
  endif
endif

" close
nnoremap <buffer><silent> q :close<cr>
