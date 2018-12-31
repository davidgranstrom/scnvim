function! scnvim#util#err(msg)
  echohl ErrorMsg | echom '[scnvim] ' . a:msg | echohl None
endfunction

function! scnvim#util#scnvim_exec(msg)
  let cmd = printf('SCNVim.exec("%s")', a:msg)
  call scnvim#sclang#send_silent(cmd)
endfunction

function! scnvim#util#get_user_settings()
  let post_win_orientation = get(g:, 'scnvim_postwin_orientation', 'v')
  let post_win_direction = get(g:, 'scnvim_postwin_direction', 'right')

  if post_win_direction == 'right'
    let post_win_direction = 'botright'
  elseif post_win_direction == 'left'
    let post_win_direction = 'topleft'
  else
    throw "valid directions are: 'left' or 'right'"
  endif

  if post_win_orientation == 'v'
    let post_win_orientation = 'vertical'
    let default_size = &columns / 3
  elseif post_win_orientation == 'h'
    let post_win_orientation = ''
    let default_size = &lines / 3
  else
    throw "valid orientations are: 's' or 'v'"
  endif

  let post_win_size = get(g:, 'scnvim_postwin_size', default_size)

  let postwin = {
  \ 'direction': post_win_direction,
  \ 'orientation': post_win_orientation,
  \ 'size': post_win_size,
  \ }

  return {
  \ 'post_window': postwin,
  \ }
endfunction
