" File: scnvim/supercollider.vim
" Author: David Granström
" Description: scnvim interface
" Last Modified: October 08, 2018

function! scnvim#send_line(...) abort
  let is_single_line = len(a:000) == 0

  if is_single_line
    let str = getline(line("."))
    call scnvim#sclang#send(str)
  else
    let lines = getline(a:1, a:2)
    let str = join(lines, "\n")
    call scnvim#sclang#send(str)
  endif
endfunction

function! scnvim#send_selection() abort
  let selection = s:get_visual_selection()
  call scnvim#sclang#send(selection)
endfunction

function! scnvim#send_block() abort
  let [start, end] = s:get_sclang_block()
  if start && end
    call scnvim#send_line(start, end)
  else
    call scnvim#send_line()
  endif
endfunction

function! scnvim#toggle_post_window() abort
  try
    let settings = get(g:, 'scnvim_current_user_settings')
    if !exists('g:scnvim_current_user_settings')
      let settings = scnvim#util#get_user_settings()
    endif

    let orientation = settings.post_window.orientation
    let direction = settings.post_window.direction
    let size = settings.post_window.size

    let bufnr = scnvim#sclang#get_post_window_bufnr()
    let win_id = bufwinnr(bufnr)

    if win_id <= 0
      let cmd = 'silent keepjumps keepalt '
      let cmd .= printf('%s %s sbuffer!%d', orientation, direction, bufnr)
      let cmd .= printf(' | %s resize %d | wincmd w', orientation, size)
      execute cmd
    else
      " post window already open
      execute win_id . 'close'
    endif
  catch
    call scnvim#util#err(v:exception)
  endtry
endfunction

function! scnvim#clear_post_window() abort
  try
    let bufnr = scnvim#sclang#get_post_window_bufnr()
    call nvim_buf_set_lines(bufnr, 0, -1, v:true, [])
  catch
    call scnvim#util#err(v:exception)
  endtry
endfunction

function! scnvim#hard_stop() abort
  call scnvim#sclang#send_silent('thisProcess.hardStop')
endfunction

" helpers {{{
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

function! s:skip_pattern()
  return 'synIDattr(synID(line("."), col("."), 0), "name") ' .
          \ '=~? "scComment\\|scString\\|scSymbol"'
endfunction

function! s:find_match(start, end, flags)
    return searchpairpos(a:start, '', a:end, a:flags, s:skip_pattern())
endfunction

function! s:get_sclang_block()
	  let c_lnum = line('.')
	  let c_col = col('.')

    " see where we are now
	  let c = getline(c_lnum)[c_col - 1]
    let plist = ['(', ')']
    let pindex = index(plist, c)

    let p = '^('
    let p2 = '^)'

    let start_pos = [0, 0]
    let end_pos = [0, 0]

    let forward_flags = 'nW'
    let backward_flags = 'nbW'

    " if we are in a string, comment etc.
    " parse the block as if we are in the middle
    let in_comment = eval(s:skip_pattern())

    if pindex == 0 && !in_comment
      " on an opening brace
      let start_pos = [c_lnum, c_col]
      let end_pos = s:find_match(p, p2, forward_flags)
    elseif pindex == 1 && !in_comment
      " on a closing brace
      let start_pos = [c_lnum, c_col]
      let end_pos = s:find_match(p, p2, backward_flags)
    else
      " middle of a block
      let start_pos = s:find_match(p, p2, backward_flags)
      let end_pos = s:find_match(p, p2, forward_flags)
    endif

    " sort the numbers so getline can use them
    return sort([start_pos[0], end_pos[0]], 'n')
endfunction
" }}}

" vim:foldmethod=marker
