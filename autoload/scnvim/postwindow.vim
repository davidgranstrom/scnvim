" File: scnvim/autoload/postwindow.vim
" Author: David Granström
" Description: scnvim post window

function! scnvim#postwindow#toggle() abort
  try
    let settings = scnvim#util#get_user_settings()
    if empty(settings)
      throw 'sclang not running'
    endif
    let orientation = settings.post_window.orientation
    let direction = settings.post_window.direction
    let size = settings.post_window.calc_size()
    let bufnr = scnvim#sclang#get_post_window_bufnr()
    let winnr = bufwinnr(bufnr)

    if winnr <= 0
      let cmd = 'silent keepjumps keepalt '
      let cmd .= printf('%s %s sbuffer!%d', orientation, direction, bufnr)
      let cmd .= printf(' | %s resize %d | wincmd p', orientation, size)
      execute cmd
    else
      " post window already open
      execute winnr . 'close'
    endif
  catch
    call scnvim#util#err(v:exception)
  endtry
endfunction

function! scnvim#postwindow#clear() abort
  try
    let bufnr = scnvim#sclang#get_post_window_bufnr()
    call nvim_buf_set_lines(bufnr, 0, -1, v:true, [])
  catch
    call scnvim#util#err(v:exception)
  endtry
endfunction
