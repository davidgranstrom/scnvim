" File: scnvim/autoload/help.vim
" Author: David Granström
" Description: scnvim help system

scriptencoding utf-8

function! scnvim#help#open_help_for(subject) abort
  let internal = get(g:, 'scnvim_scdoc', 0)
  if internal
    let settings = scnvim#util#get_user_settings()
    let scdoc_renderer = settings.paths.scdoc_render_prg
    let scdoc_render_args = scnvim#util#get_scdoc_render_args()
    if !empty(scdoc_renderer)
      let cmd = printf('SCNvim.openHelpFor("%s", "", "%s", "%s");',
            \ a:subject, scdoc_renderer, scdoc_render_args)
    else
      call scnvim#util#err('Could not find g:scnvim_scdoc_render_prg')
    endif
  else
    let cmd = printf('HelpBrowser.openHelpFor("%s");', a:subject)
  endif
  call scnvim#sclang#send_silent(cmd)
endfunction

function! scnvim#help#open(uri, pattern) abort
  let settings = scnvim#util#get_user_settings()
  let id = get(settings.help_window, 'id')
  if win_gotoid(id)
    if !empty(a:pattern)
      execute printf('edit +/%s %s', a:pattern, a:uri)
    else
      execute printf('edit %s', a:uri)
    endif
  else
    if !empty(a:pattern)
      execute 'topleft split | ' . printf('edit +/%s %s', a:pattern, a:uri)
    else
      execute 'topleft split | ' . printf('edit %s', a:uri)
    endif
    let settings.help_window.id = win_getid()
  endif
endfunction

function! scnvim#help#open_from_quickfix(item_idx) abort
  let list = getqflist()
  let item = get(list, a:item_idx - 1)
  if !empty(item)
    let bufnr = get(item, 'bufnr')
    let uri = bufname(bufnr)
    if filereadable(uri)
      call scnvim#help#open(uri, item.pattern)
    else
      call scnvim#help#render(uri, item.pattern)
    endif
  endif
endfunction

function! scnvim#help#render(uri, pattern) abort
  let settings = scnvim#util#get_user_settings()
  let scdoc_renderer = settings.paths.scdoc_render_prg
  let scdoc_render_args = scnvim#util#get_scdoc_render_args()
  if !empty(scdoc_renderer)
    let cmd = printf('SCNvim.renderMethod("%s", "%s", "%s", "%s")',
          \ a:uri, a:pattern, scdoc_renderer, scdoc_render_args)
    call scnvim#sclang#send_silent(cmd)
  else
    call scnvim#util#err('Could not find g:scnvim_scdoc_render_prg')
  endif
endfunction
