function! scnvim#util#err(msg)
  echohl ErrorMsg | echom '[scnvim] ' . a:msg | echohl None
endfunction

function! scnvim#util#scnvim_exec(msg)
  let cmd = printf('SCNVim.exec("%s")', a:msg)
  call scnvim#sclang#send_silent(cmd)
endfunction
