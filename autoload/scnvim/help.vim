" File: scnvim/autoload/help.vim
" Author: David Granström
" Description: scnvim help system

function! scnvim#help#open_help_for(subject)
  let internal = get(g:, 'scnvim_scdoc', 0)
  if internal
    let settings = scnvim#util#get_user_settings()
    let pandoc_path = settings.paths.pandoc_executable 
    let has_pandoc = !empty(pandoc_path)
    if has_pandoc
      let cmd = printf('SCNvim.openHelpFor("%s", %d, "", "%s");',
            \ a:subject, g:scnvim_python_port, pandoc_path)
    else
      call scnvim#util#err('Could not find pandoc executable.')
    endif
  else
    let cmd = printf('HelpBrowser.openHelpFor("%s");', a:subject)
  endif
  call scnvim#sclang#send_silent(cmd)
endfunction

function! scnvim#help#open(uri, pattern)
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

function! scnvim#help#open_from_quickfix(item_idx)
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

function! scnvim#help#render(uri, pattern)
  let settings = scnvim#util#get_user_settings()
  let pandoc_path = settings.paths.pandoc_executable
  let has_pandoc = !empty(pandoc_path)
  if has_pandoc
    let cmd = printf("SCNvim.renderMethod(\"%s\", %d, \"%s\", \"%s\")",
          \ a:uri, g:scnvim_python_port, a:pattern, pandoc_path)
    call scnvim#sclang#send_silent(cmd)
  else
    call scnvim#util#err('Could not find pandoc executable.')
  endif
endfunction
