" File: scnvim/supercollider.vim
" Author: David Granström
" Description: scnvim interface
" Last Modified: October 08, 2018

function! scnvim#send_line(...) abort
  let is_single_line = len(a:000) == 0
  if is_single_line
    let line = line(".")
    let str = getline(line)
    call scnvim#sclang#send(str)
    call s:flash(line, line)
  else
    let lines = getline(a:1, a:2)
    let str = join(lines, "\n")
    call scnvim#sclang#send(str)
    call s:flash(a:1, a:2)
  endif
endfunction

function! scnvim#send_selection() abort
  let selection = s:get_visual_selection()
  call scnvim#sclang#send(selection.text)
  call s:flash(selection.start - 1, selection.end + 1)
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

function! scnvim#generate_tags() abort
  let is_running = scnvim#sclang#is_running()
  if is_running
    let tagsPath = get(g:, 'scnvim_root_dir') . '/tmp/tags'
    let snipPath = get(g:, 'scnvim_root_dir') . '/tmp/supercollider.snippets'
    call scnvim#sclang#send_silent(printf('SCNvim.generateTags("%s")', tagsPath))
    call scnvim#sclang#send_silent(printf('SCNvim.generateSnippets("%s")', snipPath))
  else
    call scnvim#util#err('sclang is not started')
  endif
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
  return {
  \ 'text': join(l:lines, "\n"),
  \ 'start': l:lnum1,
  \ 'end': l:lnum2,
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

" TODO: Move somewhere else..
highlight SCNvimEval guifg=black guibg=white

function! s:flash(start, end)
  " if !has('timers') || !exists('g:scnvim_flash_eval') return
  let repeats = get(g:, 'scnvim_flash_repeats', 1)
  let duration = get(g:, 'scnvim_flash_duration', 100)
  if repeats == 0
    return
  elseif repeats == 1
    call s:flash_once(a:start, a:end, duration)
  else
    let delta = duration / 2
    call s:flash_once(a:start, a:end, delta)
    call timer_start(duration, {-> s:flash_once(a:start, a:end, delta)}, {'repeat': repeats - 1})
  endif
endfunction

function! s:flash_once(start, end, duration)
  let m = s:highlight_region(a:start, a:end)
  call timer_start(a:duration, {-> s:clear_region(m) })
endfunction

function! s:highlight_region(start, end)
  if a:start == a:end
    let pattern = '\%' . a:start . 'l'
  else
    let pattern = '\%>' . a:start . 'l'
    let pattern .= '\%<' . a:end . 'l'
  endif
  return matchadd('SCNvimEval', pattern)
endfunction

function! s:clear_region(match)
  call matchdelete(a:match)
endfunction
" }}}

" vim:foldmethod=marker
