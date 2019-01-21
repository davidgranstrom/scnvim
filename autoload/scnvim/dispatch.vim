" File: autoload/scnvim/dispatch.vim
" Author: David Granström
" Description: Dispatch data from sclang process

let s:server_running = 0

function! s:on_data(id, data, event)
  if !empty(a:data)
    let msg = join(a:data, '\n')
    try
      let object = json_decode(msg)
    catch
      " empty
    endtry
    if !empty(object)
      call scnvim#statusline#update(object)
    endif
  endif
endfunction

function! s:on_stderr(id, data, event)
  let msg = join(a:data, '\n')
  call scnvim#util#err(msg)
endfunction

function! scnvim#dispatch#start_server()
  call __scnvim_server_start()
  " if s:server_running
  "   return
  " endif

  " let nc = exepath('nc')
  " if empty(nc)
  "   call scnvim#util#err('Could not find executable `nc`')
  "   return
  " endif

  " let options = {
  " \ 'on_stdout': function('s:on_data'),
  " \ 'on_sterr': function('s:on_stderr'),
  " \ }
  " let port = get(g:, 'scnvim_data_port', 7777)
  " let id = jobstart([nc, '-lu', port], options)

  " if id == 0
  "   call scnvim#util#err('Invalid arguments for nc')
  " elseif id == -1
  "   call scnvim#util#err('nc is not an executable')
  " else
  "   let s:server_running = 1
  " endif
endfunction
