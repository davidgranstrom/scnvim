" File: autoload/scnvim/sclang.vim
" Author: David Granström
" Description: Spawn a sclang process
"
" Note: This file is kept for backwards compatabilty and might be removed in
" the future. Users and plugin authors are encouraged to use the wrapped lua
" functions directly instead.

scriptencoding utf-8

autocmd scnvim VimLeavePre * call scnvim#sclang#close()

" interface

function! scnvim#sclang#open() abort
  lua require'scnvim/sclang'.start()
endfunction

function! scnvim#sclang#close() abort
  lua require'scnvim/sclang'.stop()
endfunction

function! scnvim#sclang#recompile() abort
  lua require'scnvim/sclang'.recompile()
endfunction

function! scnvim#sclang#send(data) abort
  call luaeval('require"scnvim/sclang".send(unpack(_A))', [a:data, v:false]) 
endfunction

function! scnvim#sclang#send_silent(data) abort
  call luaeval('require"scnvim/sclang".send(unpack(_A))', [a:data, v:true]) 
endfunction

function! scnvim#sclang#is_running() abort
  return luaeval('require"scnvim/sclang".is_running()')
endfunction
