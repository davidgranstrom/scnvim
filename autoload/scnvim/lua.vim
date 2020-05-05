" File: autoload/scnvim/lua.vim
" Author: David Granström
" Description: Lua interface

scriptencoding utf-8

function! scnvim#lua#init() abort
  lua require('scnvim').init()
endfunction

function! scnvim#lua#deinit() abort
  lua require('scnvim').deinit()
endfunction

function! scnvim#lua#install() abort
  lua require('scnvim').install()
endfunction
