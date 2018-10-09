" File: autoload/supercollider/sclang.vim
" Author: David Granström
" Description: Spawn a sclang process in a vim PTY
" Last Modified: October 08, 2018

let s:Sclang = {"pid": 0}

function! s:Sclang.on_stdout(id, data, event)
  echo join(a:data)
endfunction

let s:Sclang.on_stderr = function(s:Sclang.on_stdout)

function! s:Sclang.on_exit(id, data, event)
  echom "sclang exited"
  s:sclang_pid = 0
endfunction

function! supercollider#sclang#open()
  if exists("s:sclang_pid") || exists("s:sclang_pid") && s:sclang_pid == 0
    return
  endif

  let object = extend(copy(s:Sclang), {'name': 'sclang'})
  let object.cmd = ['sclang', '-i', 'scvim']

  botright 10split sclang
  " TODO: rundir opt
  let s:sclang_pid = termopen(object.cmd)
  let object.pid = s:sclang_pid

  if s:sclang_pid == 0
    throw "scnvim: Job table is full"
  elseif s:sclang_pid == -1
     throw "scnvim: sclang is not executable"
  endif

  startinsert
  " wincmd w
endfunction

function! supercollider#sclang#send(data)
  if exists("s:sclang_pid")
    let cmd = printf("%s\x0c\n", a:data)
    call chansend(s:sclang_pid, cmd)
  endif
endfunction

function! supercollider#sclang#sendsilent(data)
  if exists("s:sclang_pid")
    let cmd = printf("%s\x1b\n", a:data)
    call chansend(s:sclang_pid, cmd)
  endif
endfunction

function! supercollider#sclang#close()
  if exists("s:sclang_pid")
    call jobstop(s:sclang_pid)
    s:sclang_pid = 0
  else
    throw "scnvim: Error closing channel"
  endif
endfunction
