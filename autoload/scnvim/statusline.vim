" File: autoload/scnvim/statusline.vim
" Author: David Granström
" Description: Status line functions

scriptencoding utf-8

function! scnvim#statusline#server_status() abort
  return &filetype ==# 'supercollider' ? get(g:scnvim_stl_widgets, 'server_status', '') : ''
endfunction

function! scnvim#statusline#level_meter() abort
  return &filetype ==# 'supercollider' ? get(g:scnvim_stl_widgets, 'level_meter', '') : ''
endfunction

function! scnvim#statusline#sclang_poll() abort
  let interval = get(g:, 'scnvim_statusline_interval', 1)
  let cmd = printf('SCNvim.updateStatusLine(%d)', interval)
  call scnvim#sclang#send_silent(cmd)
endfunction
