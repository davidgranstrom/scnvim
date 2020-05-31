" File: scnvim/autoload/document.vim
" Author: David Granström
" Description: scnvim document

scriptencoding utf-8

function! scnvim#document#set_current_path() abort
  if scnvim#sclang#is_running()
    let path = expand('%:p')
    let cmd = ''
    let cmd .= 'if (\SCNvim.asClass.notNil) {'
    let cmd .= printf('\SCNvim.asClass.currentPath = "%s"', path)
    let cmd .= '}'
    call scnvim#sclang#send_silent(cmd)
  endif
endfunction
