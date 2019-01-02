" File: autoload/scnvim/sclang.vim
" Author: David Granström
" Description: Spawn a sclang process

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
  try
    let settings = scnvim#util#get_user_settings()
    let g:scnvim_current_user_settings = settings
  catch
    call scnvim#util#err(v:exception)
    return
  endtry

  let orientation = settings.post_window.orientation
  let direction = settings.post_window.direction
  let size = settings.post_window.size

  let cmd = 'silent keepjumps keepalt '
  let cmd .= printf('%s %s new', orientation, direction)
  let cmd .= printf(' | %s resize %d', orientation, size)
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
  " scan for ERROR: marker in sclang stdout
  let found_error = match(a:data, "^ERROR") == 0
  let post_window_visible = bufwinnr(bufnr) >= 0

  let user_settings = get(g:, 'scnvim_current_user_settings')
  if found_error && user_settings.post_window.auto_toggle
    if !post_window_visible
      call scnvim#toggle_post_window()
    endif
  endif

  call nvim_buf_set_lines(bufnr, -1, -1, v:true, [a:data])

  if post_window_visible
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
  try
    let bufnr = scnvim#sclang#get_post_window_bufnr()
    execute 'bwipeout' . bufnr
  catch
    call scnvim#util#err(v:exception)
  endtry
  unlet s:sclang
endfunction
" }}}

" vim:foldmethod=marker
