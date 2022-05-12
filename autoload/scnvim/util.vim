scriptencoding utf-8

let s:is_win = has('win32')

function! scnvim#util#err(msg) abort
  echohl ErrorMsg | echom '[scnvim] ' . a:msg | echohl None
endfunction

function! scnvim#util#calc_postwindow_size() abort
  let user_defined = get(g:, 'scnvim_postwin_size')
  if user_defined
    return user_defined
  endif
  let settings = scnvim#util#get_user_settings()
  let orientation = settings.post_window.orientation
  if orientation ==# 'vertical'
    let size = &columns / 2
  else
    let size = &lines / 3
  endif
  return size
endfunction

function! scnvim#util#get_user_settings() abort
  if exists('g:scnvim_user_settings')
    return g:scnvim_user_settings
  endif

  let post_win_orientation = get(g:, 'scnvim_postwin_orientation', 'v')
  let post_win_direction = get(g:, 'scnvim_postwin_direction', 'right')
  let post_win_auto_toggle = get(g:, 'scnvim_postwin_auto_toggle', 1)

  if post_win_direction ==# 'right'
    let post_win_direction = 'botright'
  elseif post_win_direction ==# 'left'
    let post_win_direction = 'topleft'
  else
    throw "valid directions are: 'left' or 'right'"
  endif

  if post_win_orientation ==# 'v'
    let post_win_orientation = 'vertical'
    let default_size = &columns / 2
  elseif post_win_orientation ==# 'h'
    let post_win_orientation = ''
    let default_size = &lines / 3
  else
    throw "valid orientations are: 'v' or 'h'"
  endif

  let post_win_size = get(g:, 'scnvim_postwin_size', default_size)
  let postwin = {
        \ 'direction': post_win_direction,
        \ 'orientation': post_win_orientation,
        \ 'size': post_win_size,
        \ 'calc_size': function('scnvim#util#calc_postwindow_size'),
        \ 'auto_toggle': post_win_auto_toggle,
        \ }

  let helpwin = {
        \ 'id': 0,
        \ }

  let settings = {
        \ 'post_window': postwin,
        \ 'help_window': helpwin,
        \ }

  " cache settings
  let g:scnvim_user_settings = settings
  return settings
endfunction
