" File: scnvim/autoload/scnvim.vim
" Author: David Granström
" Description: scnvim interface

scriptencoding utf-8

function! scnvim#send_line(start, end) abort
  let is_single_line = a:start == 0 && a:end == 0
  if is_single_line
    let line = line('.')
    let str = getline(line)
    call scnvim#sclang#send(str)
    call s:flash(line, line, 'n')
  else
    let lines = getline(a:start, a:end)
    let last_line = lines[-1]
    let end_paren = match(last_line, ')')
    " don't send whatever happens after block closure
    let lines[-1] = last_line[:end_paren]
    let str = join(lines, "\n")
    call scnvim#sclang#send(str)
    call s:flash(a:start - 1, a:end + 1, 'n')
  endif
endfunction

function! scnvim#send_selection() abort
  let obj = s:get_visual_selection()
  call scnvim#sclang#send(obj.text)
  " the col_end check fixes the case of a single line selected by V
  if obj.line_start == obj.line_end && obj.col_end < 100000
    " visual by character
    call s:flash(obj.col_start - 1, obj.col_end + 1, 'v')
  else
    " visual by line
    call s:flash(obj.line_start - 1, obj.line_end + 1, 'V')
  endif
endfunction

function! scnvim#send_block() abort
  let [start, end] = s:get_block()
  if start > 0 && end > 0 && start != end
    call scnvim#send_line(start, end)
  else
    call scnvim#send_line(0, 0)
  endif
endfunction

function! scnvim#hard_stop() abort
  call scnvim#sclang#send_silent('thisProcess.stop')
endfunction

" installation

function! scnvim#install() abort
  lua require('scnvim/install').link()
endfunction

function! scnvim#uninstall() abort
  lua require('scnvim/install').unlink()
endfunction
