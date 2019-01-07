" File: autoload/scnvim/sclang.vim
" Author: David Granström
" Description: Spawn a sclang process

let s:recompling_class_library = 0
let s:is_exiting = 0
let s:vim_exiting = 0

" interface {{{
function! scnvim#sclang#open()
  if exists("s:sclang")
    call scnvim#util#err("sclang is already running.")
    return
  endif
  try
    " cache user settings
    let g:scnvim_user_settings = scnvim#util#get_user_settings()
    let s:sclang = s:Sclang.new()
  catch
    call scnvim#util#err(v:exception)
  endtry
endfunction

function! scnvim#sclang#close()
  try
    let s:is_exiting = 1
    call jobstop(s:sclang.id)
  catch
    call scnvim#util#err("sclang is not running")
  endtry
  let s:is_exiting = 0
endfunction

function! scnvim#sclang#recompile()
  call scnvim#sclang#send_silent("Server.quitAll;")
  let s:recompling_class_library = 1
  " on_exit callback will restart sclang
  call scnvim#sclang#close()
endfunction

function! scnvim#sclang#send(data)
  let cmd = printf("%s\x0c", a:data)
  call s:send(cmd)
endfunction

function! scnvim#sclang#send_silent(data)
  let cmd = printf("%s\x1b", a:data)
  call s:send(cmd)
endfunction

function! scnvim#sclang#is_running()
  return exists("s:sclang") && !empty(s:sclang)
endfunction
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
  let prg = get(g:, 'scnvim_user_settings').paths.sclang_executable
  let job.cmd = [prg, '-i', 'scvim', '-d', rundir]
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
  if s:vim_exiting
    return
  endif
  try
    let bufnr = scnvim#sclang#get_post_window_bufnr()
    execute 'bwipeout' . bufnr
  catch
    call scnvim#util#err(v:exception)
  endtry
  unlet s:sclang
  if s:recompling_class_library
    let s:recompling_class_library = 0
    call scnvim#sclang#open()
  endif
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
  let settings = get(g:, 'scnvim_user_settings')
  let orientation = settings.post_window.orientation
  let direction = settings.post_window.direction
  let size = settings.post_window.size

  let cmd = 'silent keepjumps keepalt '
  let cmd .= printf('%s %s new', orientation, direction)
  let cmd .= printf(' | %s resize %d', orientation, size)
  execute cmd

  setlocal filetype=scnvim
  execute 'file [sclang]'
  keepjumps keepalt wincmd p
  return bufnr("$")
endfunction

function! s:send(cmd)
  if exists("s:sclang")
    call chansend(s:sclang.id, a:cmd)
  endif
endfunction

function! s:receive(self, data)
  if s:is_exiting
    return
  endif
  let ret_bufnr = bufnr('%')
  let bufnr = get(a:self, 'bufnr')
  " scan for ERROR: marker in sclang stdout
  let found_error = match(a:data, "^ERROR") == 0
  let post_window_visible = bufwinnr(bufnr) >= 0

  let user_settings = get(g:, 'scnvim_user_settings')
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

autocmd scnvim VimLeavePre * let s:vim_exiting = 1
autocmd scnvim FileType scnvim setlocal
      \ buftype=nofile
      \ bufhidden=hide
      \ noswapfile
      \ nonu nornu nolist nomodeline nowrap
      \ nocursorline nocursorcolumn colorcolumn=
      \ foldcolumn=0 nofoldenable winfixwidth
      \ tabstop=4
      \ | nnoremap <buffer><silent> <cr> :close<cr>
      \ | nnoremap <buffer><silent> q :close<cr>
" }}}

" vim:foldmethod=marker
