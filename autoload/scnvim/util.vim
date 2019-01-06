function! scnvim#util#err(msg)
  echohl ErrorMsg | echom '[scnvim] ' . a:msg | echohl None
endfunction

function! scnvim#util#scnvim_exec(msg)
  let cmd = printf('SCNVim.exec("%s")', a:msg)
  call scnvim#sclang#send_silent(cmd)
endfunction

function! scnvim#util#echo_ar_kr_args()
  if v:char == '('
    let c_lnum = line('.')
    " we want to move back one step and lines are zero indexed so subtract 2
    let start = col('.') - 2
    let match = synIDattr(synID(c_lnum, start, 1), "name")
    if match == 'scArate' || match == 'scKrate'
      let line = getline(c_lnum)
      let result = []
      if match == 'scArate'
        let method = '.ar'
      else
        let method = '.kr'
      endif
      " we are standing on 'r' in either .ar/.kr so skip the first 3 chars
      " scan until next non-word char
      let start -= 3
      while line[start] !~ '\W' && start >= 0
        call add(result, line[start])
        let start -= 1
      endwhile
      let result = join(reverse(result), '')
      if !empty(result)
        let result .= method
        let cmd = printf('Help.methodArgs("%s")', result)
        call scnvim#util#scnvim_exec(cmd)
      endif
    endif
  endif
endfunction

function! scnvim#util#get_user_settings()
  let post_win_orientation = get(g:, 'scnvim_postwin_orientation', 'v')
  let post_win_direction = get(g:, 'scnvim_postwin_direction', 'right')
  let post_win_auto_toggle = get(g:, 'scnvim_postwin_auto_toggle', 1)

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
  \ 'auto_toggle': post_win_auto_toggle,
  \ }

  return {
  \ 'post_window': postwin,
  \ }
endfunction
