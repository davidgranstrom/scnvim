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
function! scnvim#sclang#get_post_window_bufnr()
  if exists("s:sclang") && !empty(s:sclang) && s:sclang.bufnr
    return s:sclang.bufnr
  else
    throw "sclang not started"
  endif
endfunction

function! s:create_post_window()
  let orientation = get(g:, 'scnvim_postwin_orientation', 'v')
  let direction = get(g:, 'scnvim_postwin_direction', 'right')

  if direction == 'right'
    let direction = 'botright'
  elseif direction == 'left'
    let direction = 'topleft'
  else
    throw "valid directions are: 'left' or 'right'"
  endif

  if orientation == 'v'
    let pos = 'vertical'
    let default_size = &columns / 3
  elseif orientation == 'h'
    let pos = ''
    let default_size = &lines / 3
  else
    throw "valid orientations are: 's' or 'v'"
  endif

  let size = get(g:, 'scnvim_postwin_size', default_size)

  let cmd = 'silent keepjumps keepalt '
  let cmd .= printf('%s %s new', pos, direction)
  let cmd .= printf(' | %s resize %d', pos, size)
  execute cmd

  setlocal filetype=scnvim
  execute 'file ' . 'sclang-post-window'
  keepjumps keepalt wincmd p
  return bufnr("$")
endfunction

function! s:send(cmd)
  if exists("s:sclang")
    call chansend(s:sclang.id, a:cmd)
  endif
endfunction

function! s:receive(self, data)
  let ret_bufnr = bufnr('%')
  let bufnr = get(a:self, 'bufnr')
  let post_window_visible = bufwinnr(bufnr)

  call nvim_buf_set_lines(bufnr, -1, -1, v:true, [a:data])

  if post_window_visible >= 0
    execute bufwinnr(bufnr) . 'wincmd w'
    call nvim_command("normal! G")
    execute bufwinnr(ret_bufnr) . 'wincmd w'
  endif
endfunction

autocmd scnvim FileType scnvim setlocal
      \ buftype=nofile
      \ bufhidden=hide
      \ noswapfile
      \ nonu nornu nolist nomodeline nowrap
      \ statusline=
      \ nocursorline nocursorcolumn colorcolumn=
      \ foldcolumn=0 nofoldenable winfixwidth
      \ | nnoremap <buffer><silent> <cr> :close<cr>
      \ | nnoremap <buffer><silent> q :close<cr>
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
    throw "Job table is full"
  elseif job.id == -1
    throw "sclang is not executable"
  endif

  return job
endfunction

let s:chunks = ['']
function! s:Sclang.on_stdout(id, data, event) dict
  let s:chunks[-1] .= a:data[0]
  call extend(s:chunks, a:data[1:])
  for line in s:chunks
    if !empty(line)
      call s:receive(self, line)
    else
      let s:chunks = ['']
    endif
  endfor
endfunction

let s:Sclang.on_stderr = function(s:Sclang.on_stdout)

function! s:Sclang.on_exit(id, data, event)
  unlet s:sclang
endfunction
" }}}

" vim:foldmethod=marker
