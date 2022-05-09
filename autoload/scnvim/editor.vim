" File: scnvim/autoload/editor.vim
" Author: David Granström
" Description: scnvim editor helpers
" Note: Will be deprecated and moved to editor.lua in the future.

scriptencoding utf-8

function! s:skip_pattern() abort
  return 'synIDattr(synID(line("."), col("."), 0), "name") ' .
        \ '=~? "scLineComment\\|scComment\\|scString\\|scSymbol"'
endfunction

function! s:find_match(start, end, flags) abort
    return searchpairpos(a:start, '', a:end, a:flags, s:skip_pattern())
endfunction

function! s:flash_once(start, end, duration, mode) abort
  let m = s:highlight_region(a:start, a:end, a:mode)
  call timer_start(a:duration, {-> s:clear_region(m) })
endfunction

function! s:highlight_region(start, end, mode) abort
  if a:mode ==# 'n' || a:mode ==# 'V'
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

function! s:clear_region(match) abort
  call matchdelete(a:match)
endfunction

function! scnvim#editor#get_block() abort
    " initialize to invalid ranges
    let start_pos = [0, 0]
    let end_pos = [0, 0]
    let forward_flags = 'nW'
    let backward_flags = 'nbW'
    " searchpairpos starts the search from the cursor so save where we are
    " right now and restore the cursor after the search
    let c_curpos = getcurpos()
    " move to first column
    call setpos('.', [0, c_curpos[1], 1, 0])
    let [xs, ys] = s:find_match('(', ')', backward_flags)
    let start_pos = [xs, ys]
    if xs == 0 && ys == 0
      " we are already standing on the opening brace
      let start_pos = [line('.'), col('.')]
    else
      while xs > 0 && ys > 0
        call setpos('.', [0, xs, ys, 0])
        let start_pos = [xs, ys]
        let [xs, ys] = s:find_match('(', ')', backward_flags)
      endwhile
    endif
    call setpos('.', [0, start_pos[0], start_pos[1], 0])
    let end_pos = s:find_match('(', ')', forward_flags)
    " restore cursor
    call setpos('.', c_curpos)
    return [start_pos[0], end_pos[0]]
endfunction

function! scnvim#editor#flash(start, end, mode) abort
  let repeats = get(g:, 'scnvim_eval_flash_repeats', 2)
  let duration = get(g:, 'scnvim_eval_flash_duration', 100)
  if repeats == 0 || duration == 0
    return
  elseif repeats == 1
    call s:flash_once(a:start, a:end, duration, a:mode)
  else
    let delta = duration / 2
    call s:flash_once(a:start, a:end, delta, a:mode)
    call timer_start(duration, {-> s:flash_once(a:start, a:end, delta, a:mode)}, {'repeat': repeats - 1})
  endif
endfunction

" Could be replaced with `vim.region` later
function! scnvim#editor#get_visual_selection() abort
  " update the '</'> marks before proceeding
  exe "normal! \<Esc>"
  exe "normal! gv"
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  if &selection ==# 'exclusive'
    let col2 -= 1
  endif
  let lines = getline(lnum1, lnum2)
  if !empty(lines)
    let lines[-1] = lines[-1][:col2 - 1]
    let lines[0] = lines[0][col1 - 1:]
  endif
  return {
  \ 'lines': lines,
  \ 'line_start': lnum1,
  \ 'line_end': lnum2,
  \ 'col_start': col1,
  \ 'col_end': col2,
  \ }
endfunction
