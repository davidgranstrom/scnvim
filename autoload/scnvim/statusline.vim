function! scnvim#statusline#server_status()
  return &ft ==# 'supercollider' ? get(g:scnvim_stl_widgets, 'server_status', '') : ''
endfunction

function! scnvim#statusline#level_meter()
  return &ft ==# 'supercollider' ? get(g:scnvim_stl_widgets, 'level_meter', '') : ''
endfunction

function! scnvim#statusline#sclang_poll()
  if exists('g:scnvim_python_port')
    let cmd = printf('SCNvim.updateStatusLine(%d, %d)', get(g:, 'scnvim_statusline_interval', 1), g:scnvim_python_port)
    call scnvim#sclang#send_silent(cmd)
  endif
endfunction

" json encoded data
function! scnvim#statusline#update(data) abort
  try
    let object = json_decode(a:data)
  catch
    return
  endtry
  let server_status = get(object, 'server_status', '')
  let level_meter = get(object, 'level_meter', '')
  call extend(g:scnvim_stl_widgets, {
  \ 'server_status': server_status,
  \ 'level_meter': level_meter,
  \ })
endfunction
