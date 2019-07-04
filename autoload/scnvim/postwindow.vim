" File: scnvim/autoload/postwindow.vim
" Author: David Granström
" Description: scnvim post window

let s:bufnr = 0
let s:bufname = get(g:, 'scnvim_postwin_title', '[sclang]')

function! scnvim#postwindow#create() abort
  if bufexists(s:bufname)
    let s:bufnr = bufnr(s:bufname)
    let winnr = bufwinnr(s:bufnr)
    let should_close = 0
    if winnr < 0
      call scnvim#postwindow#open()
      " open to get the winnr
      let winnr = bufwinnr(s:bufnr)
      let should_close = 1
    endif
    execute winnr . "wincmd w"
    setlocal filetype=scnvim
    execute "wincmd p"
    " restore if postwindow was closed
    if should_close
      call scnvim#postwindow#close()
    endif
  endif
  if s:bufnr == 0
    let s:bufnr = s:create_post_window()
  endif
  return s:bufnr
endfunction

function! scnvim#postwindow#open() abort
  let settings = scnvim#util#get_user_settings()
  let orientation = settings.post_window.orientation
  let direction = settings.post_window.direction
  let size = settings.post_window.calc_size()

  let cmd = 'silent keepjumps keepalt '
  let cmd .= printf('%s %s sbuffer!%d', orientation, direction, s:bufnr)
  let cmd .= printf(' | %s resize %d | wincmd p', orientation, size)
  execute cmd
endfunction

function! scnvim#postwindow#close() abort
  let bufnr = scnvim#postwindow#get_bufnr()
  let winnr = bufwinnr(bufnr)
  if winnr > 0
    execute winnr . 'close'
  endif
endfunction

function! scnvim#postwindow#destroy() abort
  try
    let bufnr = scnvim#postwindow#get_bufnr()
    execute 'bwipeout' . bufnr
    let s:bufnr = 0
  catch
    call scnvim#util#err(v:exception)
  endtry
endfunction

function! scnvim#postwindow#toggle() abort
  try
    if !scnvim#sclang#is_running()
      throw 'sclang not running'
    endif
    let settings = scnvim#util#get_user_settings()
    let bufnr = scnvim#postwindow#get_bufnr()
    let winnr = bufwinnr(bufnr)

    if winnr < 0
      call scnvim#postwindow#open()
    else
      call scnvim#postwindow#close()
    endif
  catch
    call scnvim#util#err(v:exception)
  endtry
endfunction

function! scnvim#postwindow#clear() abort
  try
    let bufnr = scnvim#postwindow#get_bufnr()
    call nvim_buf_set_lines(bufnr, 0, -1, v:true, [])
  catch
    call scnvim#util#err(v:exception)
  endtry
endfunction

function! scnvim#postwindow#get_bufnr() abort
  if s:bufnr
    return s:bufnr
  else
    throw 'sclang not started'
    return -1
  endif
endfunction

function! s:create_post_window() abort
  let settings = scnvim#util#get_user_settings()
  let orientation = settings.post_window.orientation
  let direction = settings.post_window.direction
  let size = settings.post_window.size

  let cmd = 'silent keepjumps keepalt '
  let cmd .= printf('%s %s new', orientation, direction)
  let cmd .= printf(' | %s resize %d', orientation, size)
  execute cmd

  setlocal filetype=scnvim
  execute printf('file %s', s:bufname)
  keepjumps keepalt wincmd p
  return bufnr("$")
endfunction
