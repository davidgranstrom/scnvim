" File: autoload/scnvim/sclang.vim
" Author: David Granström
" Description: Spawn a sclang process
" Last Modified: October 13, 2018

" interface {{{
function! scnvim#sclang#open()
  if exists("s:sclang")
    call scnvim#util#err("sclang is already running.")
    return
  endif
  try
    let s:sclang = s:Sclang.new()
  catch
    call scnvim#util#err(v:exception)
  endtry
endfunction

function! scnvim#sclang#close()
  try
    call jobstop(s:sclang.id)
  catch
    call scnvim#util#err("sclang is not running")
  endtry
endfunction

function! scnvim#sclang#send(data)
  let cmd = printf("%s\x0c", a:data)
  call s:send(cmd)
endfunction

function! scnvim#sclang#send_silent(data)
  let cmd = printf("%s\x1b", a:data)
  call s:send(cmd)
endfunction
" }}}

" helpers {{{
function! s:create_post_window()
  " TODO: be able to control vertical/horizontal split
  execute 'keepjumps keepalt ' . 'rightbelow ' . 'vnew'
  setlocal filetype=scnvim
  keepjumps keepalt wincmd p
  return bufnr("$")
endfunction

function! s:send(cmd)
  if exists("s:sclang")
    echo a:cmd
    call chansend(s:sclang.id, a:cmd)
  endif
endfunction

function! s:receive(self, data)
  let ret_bufnr = bufnr('%')
  let ret_mode = mode()
  let ret_line = line('.')
  let ret_col = col('.')

  let bufnr = get(a:self, 'bufnr')

  " go to sclang buf
  execute 'keepjumps keepalt buf! ' . bufnr
  call append(line('$'), a:data)
  call cursor(line('$'), 1)

  " return to where we were
  execute 'keepjumps keepalt buf! ' . ret_bufnr
   " Restore mode and position
  if ret_mode =~ '[vV]'
    keepjumps normal! gv
  elseif ret_mode =~ '[sS]'
    exe "keepjumps normal! gv\<c-g>"
  endif
  keepjumps call cursor(ret_line, ret_col)
endfunction

autocmd scnvim FileType scnvim setlocal
      \ buftype=nofile
      \ bufhidden=hide
      \ noswapfile
      \ nonu nornu nolist nomodeline nowrap
      \ statusline=
      \ nocursorline nocursorcolumn colorcolumn=
      \ foldcolumn=0 nofoldenable winfixwidth
      \ | noremap <buffer> <silent> q <c-o>:close<cr>
" }}}

" job handlers {{{
let s:Sclang = {}

function! s:Sclang.new()
  let options = {
        \ 'name': 'sclang',
        \ 'lines': [],
        \ 'bufnr': 0,
        \ }
  let job = extend(copy(s:Sclang), options)
  let rundir = getcwd()

  let job.bufnr = s:create_post_window()
  let job.cmd = ['sclang', '-i', 'scvim', '-d', rundir]
  let job.id = jobstart(job.cmd, job)

  if job.id == 0
    throw "scnvim: Job table is full"
  elseif job.id == -1
    throw "scnvim: sclang is not executable"
  endif

  return job
endfunction

let s:chunks = ['']
function! s:Sclang.on_stdout(id, data, event) dict
  let s:chunks[-1] .= a:data[0]
  call extend(s:chunks, a:data[1:])
  for line in s:chunks
    call s:receive(self, line)
    let s:chunks = ['']
  endfor
endfunction

let s:Sclang.on_stderr = function(s:Sclang.on_stdout)

function! s:Sclang.on_exit(id, data, event)
  unlet s:sclang
endfunction
" }}}

" vim:foldmethod=marker
