function! scnvim#util#err(msg)
  echohl ErrorMsg | echom a:msg | echohl None
endfunction
