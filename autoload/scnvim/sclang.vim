" File: autoload/scnvim/sclang.vim
" Author: David Granström
" Description: Spawn a sclang process

scriptencoding utf-8

let s:is_exiting = 0
let s:Sclang = {}

autocmd scnvim VimLeavePre * call scnvim#sclang#close()

" interface

function! scnvim#sclang#open() abort
  if scnvim#sclang#is_running()
    call scnvim#util#err('sclang is already running.')
    return
  endif
  try
    let s:is_exiting = 0
    let s:sclang_job = s:Sclang.new()
    call scnvim#lua#init()
    call scnvim#document#set_current_path()
  catch
    call scnvim#util#err(v:exception)
  endtry
endfunction

function! scnvim#sclang#close() abort
  if scnvim#sclang#is_running()
    let s:is_exiting = 1
    call scnvim#sclang#send_silent('0.exit')
    call jobwait([s:sclang_job.id], 1000)
    call scnvim#lua#deinit()
  else
    call scnvim#util#err('sclang is not running')
  endif
endfunction

function! scnvim#sclang#recompile() abort
if scnvim#sclang#is_running()
lua << EOF
local scnvim = require('scnvim')
local udp = require('scnvim/udp')
scnvim.send('thisProcess.recompile')
scnvim.send(string.format('SCNvim.port = %d', udp.port))
vim.api.nvim_call_function('scnvim#document#set_current_path', {})
EOF
else
  call scnvim#util#err('sclang is not running')
endif
endfunction

function! scnvim#sclang#send(data) abort
  let cmd = printf("%s\x0c", a:data)
  call s:send(cmd)
endfunction

function! scnvim#sclang#send_silent(data) abort
  let cmd = printf("%s\x1b", a:data)
  call s:send(cmd)
endfunction

function! scnvim#sclang#is_running() abort
  return exists('s:sclang_job') && has_key(s:sclang_job, 'id') && jobwait([s:sclang_job.id], 0)[0] == -1
endfunction

" job handlers

function! s:Sclang.new() abort
  let options = { 'name': 'sclang' }
  let settings = scnvim#util#get_user_settings()
  let job = extend(copy(s:Sclang), options)
  let rundir = expand('%:p:h')
  let prg = settings.paths.sclang_executable

  let job.bufnr = scnvim#postwindow#create()
  let job.cmd = [prg, '-i', 'scnvim', '-d', rundir]
  let job.id = jobstart(job.cmd, job)

  if job.id == 0
    throw 'job table is full'
  elseif job.id == -1
    throw 'could not find sclang executable'
  endif
  return job
endfunction

let s:chunks = ['']
function! s:Sclang.on_stdout(id, data, event) dict abort
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

function! s:Sclang.on_exit(id, data, event) abort
  call scnvim#postwindow#destroy()
  unlet s:sclang_job
endfunction

" helpers

function! s:send(cmd) abort
  if scnvim#sclang#is_running()
    call chansend(s:sclang_job.id, a:cmd)
  endif
endfunction

let s:max_lines = get(g:, 'scnvim_postwin_scrollback', 5000)
let s:not_win = !has('win32')

function! s:receive(self, data) abort
  if s:is_exiting
    return
  endif
  let bufnr = get(a:self, 'bufnr')
  let winnr = bufwinid(bufnr)
  " scan for ERROR: marker in sclang stdout
  let found_error = match(a:data, '^ERROR') == 0
  let post_window_visible = winnr >= 0

  let settings = scnvim#util#get_user_settings()
  if found_error && settings.post_window.auto_toggle
    if !post_window_visible
      call scnvim#postwindow#toggle()
    endif
  endif

  let data = s:not_win ? a:data : substitute(a:data, '\r', '', '')
  call nvim_buf_set_lines(bufnr, -1, -1, v:true, [data])

  let num_lines = nvim_buf_line_count(bufnr)
  if s:max_lines > 0 && num_lines > s:max_lines
    call nvim_buf_set_lines(bufnr, 0, s:max_lines / 2, v:true, [])
    let num_lines = nvim_buf_line_count(bufnr)
  endif

  if post_window_visible
    call nvim_win_set_cursor(winnr, [num_lines, 0])
  endif
endfunction
