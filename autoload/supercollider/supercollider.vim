" File: supercollider/supercollider.vim
" Author: David Granström
" Description: Autoload functions
" Last Modified: October 08, 2018

function! supercollider#line_send(data)
  supercollider#socket#send(a:data)
endfunction

function! supercollider#paragraph_send(data)
  supercollider#socket#send(a:data)
endfunction
