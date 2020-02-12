" File: autoload/scnvim/lua.vim
" Author: David Granström
" Description: Lua interface

function! scnvim#lua#init() abort
  let port = luaeval('require("scnvim").init()')
  echo "port is " . port 
  " TODO: rename this to g:scnvim_port
  let g:scnvim_python_port = port
endfunction
