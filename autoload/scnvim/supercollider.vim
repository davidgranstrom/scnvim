" File: scnvim/supercollider.vim
" Author: David Granström
" Description: Autoload functions
" Last Modified: October 08, 2018

function! scnvim#supercollider#send_line(...)
	let lines = getline(a:1, a:2)
  let str = join(lines, "\n")
  call scnvim#sclang#send(str)
endfunction

function! scnvim#supercollider#send_selection()
	let selection = s:get_visual_selection()
  call scnvim#sclang#send(selection)
endfunction

function! scnvim#supercollider#send_paragraph()
  " empty
endfunction

" from neoterm
function! s:get_visual_selection()
  let [l:lnum1, l:col1] = getpos("'<")[1:2]
  let [l:lnum2, l:col2] = getpos("'>")[1:2]
  if &selection ==# 'exclusive'
    let l:col2 -= 1
  endif
  let l:lines = getline(l:lnum1, l:lnum2)
  let l:lines[-1] = l:lines[-1][:l:col2 - 1]
  let l:lines[0] = l:lines[0][l:col1 - 1:]
  return join(l:lines, "\n")
endfunction
