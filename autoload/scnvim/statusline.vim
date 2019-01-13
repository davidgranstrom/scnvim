function! scnvim#statusline#server_status()
  return &ft ==# 'supercollider' ? get(g:scnvim_stl_widgets, 'server_status', '') : ''
endfunction

function! scnvim#statusline#level_meter()
  return &ft ==# 'supercollider' ? get(g:scnvim_stl_widgets, 'level_meter', '') : ''
endfunction

function! scnvim#statusline#update(data) abort
  let server_status = get(a:data, 'server_status', '')
  let level_meter = get(a:data, 'level_meter', '')
  call extend(g:scnvim_stl_widgets, {
  \ 'server_status': server_status,
  \ 'level_meter': level_meter,
  \ })
endfunction
