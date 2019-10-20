function! scnvim#util#err(msg)
  echohl ErrorMsg | echom '[scnvim] ' . a:msg | echohl None
endfunction

function! scnvim#util#echo_args()
  if v:char != '(' || !exists('g:scnvim_python_port')
    return
  endif

  let l_num = line('.')
  let c_col = col('.') - 2
  let line = getline(l_num)

  let method = []
  " loop until we hit a valid object or reach first column
  let match = synIDattr(synID(l_num, c_col, 1), "name")
  while match != 'scObject' && c_col >= 0
    call add(method, line[c_col])
    let c_col -= 1
    let match = synIDattr(synID(l_num, c_col, 1), "name")
  endwhile

  " add last char (will be empty if we never entered loop above)
  call add(method, line[c_col])
  let method = join(reverse(method), '')

  " since lines are zero indexed (and synID for match above is not)
  " we subtract one before we continue
  let c_col -= 1

  if match == 'scObject'
    let result = []
    " scan until next non-word char
    while line[c_col] !~ '\W' && c_col >= 0
      call add(result, line[c_col])
      let c_col -= 1
    endwhile
    let result = join(reverse(result), '')
    if !empty(result)
      let result .= method
      let cmd = printf('SCNvim.methodArgs("%s", %d)', result, g:scnvim_python_port)
      call scnvim#sclang#send_silent(cmd)
    endif
  endif
endfunction

function! scnvim#util#find_sclang_executable()
  let exe = get(g:, 'scnvim_sclang_executable', '')
  if !empty(exe)
    " user defined
    return expand(exe)
  elseif !empty(exepath('sclang'))
    " in $PATH
    return exepath('sclang')
  else
    " try some known locations
    let loc = '/Applications/SuperCollider.app/Contents/MacOS/sclang'
    if executable(loc)
      return loc
    endif
    let loc = '/Applications/SuperCollider/SuperCollider.app/Contents/MacOS/sclang'
    if executable(loc)
      return loc
    endif
  endif
  throw "could not find sclang exeutable"
endfunction

function! scnvim#util#find_pandoc_executable()
  let exe = get(g:, 'scnvim_pandoc_executable', '')
  if !empty(exe)
    " user defined
    return expand(exe)
  elseif !empty(exepath('pandoc'))
    " in $PATH
    return exepath('pandoc')
  else
    return ''
endfunction

function! scnvim#util#generate_tags() abort
  let is_running = scnvim#sclang#is_running()
  if is_running
    let root_dir = get(g:, 'scnvim_root_dir')
    call scnvim#sclang#send_silent(printf('SCNvim.generateAssets("%s")', root_dir))
  else
    call scnvim#util#err('sclang is not started')
  endif
endfunction

function! scnvim#util#calc_postwindow_size()
  let user_defined = get(g:, 'scnvim_postwin_size')
  if user_defined
    return user_defined
  endif
  let settings = scnvim#util#get_user_settings()
  let orientation = settings.post_window.orientation
  if orientation == 'vertical'
    let size = &columns / 2
  else
    let size = &lines / 3
  endif
  return size
endfunction

function! scnvim#util#get_user_settings()
  if exists('g:scnvim_user_settings')
    return g:scnvim_user_settings
  endif

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
    let default_size = &columns / 2
  elseif post_win_orientation == 'h'
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

  let sclang_executable = scnvim#util#find_sclang_executable()
  let pandoc_executable = scnvim#util#find_pandoc_executable()
  let paths = {
        \ 'sclang_executable': sclang_executable,
        \ 'pandoc_executable': pandoc_executable,
        \ }
  let info = {
        \ 'floating': exists('*nvim_open_win') && get(g:, 'scnvim_arghints_float', 1) == 1 ? v:true : v:false,
        \ }

  let settings = {
        \ 'paths': paths,
        \ 'post_window': postwin,
        \ 'help_window': helpwin,
        \ 'info': info,
        \ }

  " cache settings
  let g:scnvim_user_settings = settings
  return settings
endfunction

function! scnvim#util#try_close_float()
  let winid = get(g:, 'scnvim_arghints_float_id')
  if winid > 0
    call nvim_win_close(winid, v:true)
    let g:scnvim_arghints_float_id = 0
  endif
endfunction
