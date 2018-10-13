" File: scnvim/supercollider.vim
" Author: David Granström
" Description: Autoload functions
" Last Modified: October 08, 2018

function! scnvim#supercollider#line_send()
  if mode() == "n"
    let txt = getline(".")
  else
    let txt = s:get_visual_selection()
  endif

  call scnvim#sclang#send(txt)
endfunction

function! scnvim#supercollider#paragraph_send()
  " empty
endfunction

function! s:get_visual_selection()
  let [line_start, column_start] = getpos("'<")[1:2]
  let [line_end, column_end] = getpos("'>")[1:2]
  let lines = getline(line_start, line_end)
  if len(lines) == 0
    return ''
  endif
  let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][column_start - 1:]
  return join(lines, "\n")
endfunction
