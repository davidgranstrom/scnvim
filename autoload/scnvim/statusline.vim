" File: autoload/scnvim/statusline.vim
" Author: David Granström
" Description: Status line functions

scriptencoding utf-8

" Kept for convenience for statusline formatting
function! scnvim#statusline#server_status() abort
  return luaeval('require"scnvim.statusline".get_server_status()')
endfunction
