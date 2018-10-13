" File: autoload/supercollider/sclang.vim
" Author: David Granström
" Description: Spawn a sclang process
" Last Modified: October 13, 2018

" interface {{{
function! supercollider#sclang#open()
  if exists("s:sclang")
    echo "sclang is already running."
  endif

  let s:sclang = s:Sclang.new()
  let s:sclang.post_win = s:CreatePostWindow()

  let g:Sclang = s:sclang
endfunction

function! supercollider#sclang#close()
  if exists("s:sclang")
    call jobstop(s:sclang.id)
  endif
endfunction

function! supercollider#sclang#send(data)
  let cmd = printf("%s\x0c", a:data)
  call s:SendCmd(cmd)
endfunction

function! supercollider#sclang#send_silent(data)
  let cmd = printf("%s\x1b", a:data)
  call s:SendCmd(cmd)
endfunction
" }}}

" helpers {{{
function! s:SendCmd(cmd)
  if exists("s:sclang")
    call chansend(s:sclang.id, a:cmd)
  endif
endfunction

function! s:CreatePostWindow()
  botright 8split sclang

  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile

  let attrs = {
    \ "bufnr": bufnr("%"),
    \ "winid": win_getid(),
    \ }

  return attrs
endfunction
" }}}

" job handlers {{{
let s:Sclang = {}

function! s:Sclang.new()
  let object = extend(copy(s:Sclang), {'name': 'sclang'})
  " TODO: rundir opt
  let object.cmd = ['sclang', '-i', 'scvim']
  let object.id = jobstart(object.cmd, object)

  if object.id == 0
    throw "scnvim: Job table is full"
  elseif object.id == -1
    throw "scnvim: sclang is not executable"
  endif

  return object
endfunction

let s:chunks = ['']
function! s:Sclang.on_stdout(id, data, event) dict
  let s:chunks[-1] .= a:data[0]
  call extend(s:chunks, a:data[1:])

  let curwin_id = win_getid()

  if bufexists(self.post_win.bufnr)
    call win_gotoid(self.post_win.winid)
    call append(line('$'), s:chunks)
    call cursor("$", 1)
  endif

  call win_gotoid(curwin_id)
endfunction

let s:Sclang.on_stderr = function(s:Sclang.on_stdout)

function! s:Sclang.on_exit(id, data, event)
  unlet s:sclang
endfunction
" }}}

" vim:foldmethod=marker
