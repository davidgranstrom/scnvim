" File: autoload/supercollider/socket.vim
" Author: David Granström
" Description: Open socket to sclang stdin
" Last Modified: October 08, 2018

function! supercollider#socket#connect()
  if exists("s:socket_pid") return
  if exists("s:socket_addr")
    let addr = s:socket_addr
  else
    let addr = "/tmp/scnvim-pipe"
  endif

  let s:socket_pid = sockconnect("pipe", addr);

  if !s:socket_pid > 0
     throw "scnvim: Could not connect to scvim stdin"
  endif
endfunction

function! supercollider#socket#send(data)
  if s:socket_pid > 0
    chansend(s:socket_pid, a:data)
  endif
endfunction

function! supercollider#socket#close()
  if s:socket_pid > 0
    chanclose(s:socket_pid)
  else
    throw "scnvim: Error closing channel"
  endif
endfunction
