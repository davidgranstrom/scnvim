scriptencoding utf-8

let s:is_win = has('win32')

function! scnvim#util#err(msg) abort
  echohl ErrorMsg | echom '[scnvim] ' . a:msg | echohl None
endfunction

function! scnvim#util#escape_path(path) abort
  return (s:is_win && !&shellslash) ? escape(a:path, '\') : a:path
endfunction

function! scnvim#util#find_sclang_executable() abort
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
  throw 'could not find sclang exeutable'
endfunction

function! scnvim#util#find_scdoc_render_prg() abort
  let exe = get(g:, 'scnvim_scdoc_render_prg', '')
  if !empty(exe)
    " user defined
    return scnvim#util#escape_path(expand(exe))
  elseif !empty(exepath('pandoc'))
    " default
    return scnvim#util#escape_path(exepath('pandoc'))
  else
    return ''
  endif
endfunction

function! scnvim#util#get_scdoc_render_args() abort
  " default render args
  return get(g:, 'scnvim_scdoc_render_args', '% --from html --to plain -o %')
endfunction

function! scnvim#util#generate_tags() abort
  let is_running = scnvim#sclang#is_running()
  if is_running
    let root_dir = get(g:, 'scnvim_root_dir')
    let root_dir = scnvim#util#escape_path(root_dir)
    let snippet_format = get(g:, 'scnvim_snippet_format', 'ultisnips')
    call scnvim#sclang#send_silent(printf('SCNvim.generateAssets("%s", "%s")', root_dir, snippet_format))
  else
    call scnvim#util#err('sclang is not started')
  endif
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

  let sclang_executable = scnvim#util#find_sclang_executable()
  let scdoc_render_prg = scnvim#util#find_scdoc_render_prg()
  let paths = {
        \ 'sclang_executable': sclang_executable,
        \ 'scdoc_render_prg': scdoc_render_prg,
        \ }

  let settings = {
        \ 'paths': paths,
        \ 'post_window': postwin,
        \ 'help_window': helpwin,
        \ }

  " cache settings
  let g:scnvim_user_settings = settings
  return settings
endfunction
