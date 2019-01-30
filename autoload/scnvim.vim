" File: scnvim/autoload/scnvim.vim
" Author: David Granström
" Description: scnvim interface

function! scnvim#send_line(...) abort
  let is_single_line = len(a:000) == 0
  if is_single_line
    let line = line(".")
    let str = getline(line)
    call scnvim#sclang#send(str)
    call s:flash(line, line, v:false)
  else
    let lines = getline(a:1, a:2)
    let str = join(lines, "\n")
    call scnvim#sclang#send(str)
    call s:flash(a:1, a:2, v:false)
  endif
endfunction

function! scnvim#send_selection() abort
  let selection = s:get_visual_selection()
  call scnvim#sclang#send(selection.text)
  call s:flash(selection.start - 1, selection.end + 1, v:true)
endfunction

function! scnvim#send_block() abort
  let [start, end] = s:get_sclang_block()
  if start && end
    call scnvim#send_line(start, end)
  else
    call scnvim#send_line()
  endif
endfunction

function! scnvim#hard_stop() abort
  call scnvim#sclang#send_silent('thisProcess.hardStop')
endfunction

" helpers
function! s:get_visual_selection()
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  if &selection ==# 'exclusive'
    let col2 -= 1
  endif
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][:col2 - 1]
  let lines[0] = lines[0][col1 - 1:]
  return {
        \ 'text': join(lines, "\n"),
        \ 'start': col1,
        \ 'end': col2,
        \ }
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

    let p = '('
    let p2 = ')'

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

function! s:flash(start, end, selection)
  let repeats = get(g:, 'scnvim_eval_flash_repeats', 2)
  let duration = get(g:, 'scnvim_eval_flash_duration', 100)
  if repeats == 0 || duration == 0
    return
  elseif repeats == 1
    call s:flash_once(a:start, a:end, duration, a:selection)
  else
    let delta = duration / 2
    call s:flash_once(a:start, a:end, delta, a:selection)
    call timer_start(duration, {-> s:flash_once(a:start, a:end, delta, a:selection)}, {'repeat': repeats - 1})
  endif
endfunction

function! s:flash_once(start, end, duration, selection)
  let m = s:highlight_region(a:start, a:end, a:selection)
  call timer_start(a:duration, {-> s:clear_region(m) })
endfunction

function! s:highlight_region(start, end, selection)
  if !a:selection
    if a:start == a:end
      let pattern = '\%' . a:start . 'l'
    else
      let pattern = '\%>' . a:start . 'l'
      let pattern .= '\%<' . a:end . 'l'
    endif
  else
    let pattern = '\%' . line('.') . 'l'
    if a:start == a:end
      let pattern .= '\%' . a:start . 'c'
    else
      let pattern .= '\%>' . a:start . 'c'
      let pattern .= '\%<' . a:end . 'c'
    endif
  endif
  return matchadd('SCNvimEval', pattern)
endfunction

function! s:clear_region(match)
  call matchdelete(a:match)
endfunction
