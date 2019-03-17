" File: scnvim/autoload/help.vim
" Author: David Granström
" Description: scnvim help system

function! scnvim#help#open_help_for(subject)
  let internal = get(g:, 'scnvim_scdoc_vim', 0)
  if internal
    let cmd = printf('SCNvim.openHelpFor("%s", %d);', a:subject, g:scnvim_python_port)
  else
    let cmd = printf('HelpBrowser.openHelpFor("%s");', a:subject)
  endif
  call scnvim#sclang#send_silent(cmd)
endfunction

function! scnvim#help#open(uri)
  let settings = scnvim#util#get_user_settings()
  let id = get(settings.help_window, 'id')
  if !id
    execute 'split ' . a:uri
    let settings.help_window.id = win_getid()
  else
    if win_gotoid(id)
      execute 'edit ' . a:uri
    endif
  endif
endfunction

function! scnvim#help#open_from_quickfix(item_idx)
  let list = getqflist()
  let item = get(list, a:item_idx - 1)
  if !empty(item)
    let bufnr = get(item, 'bufnr')
    let uri = bufname(bufnr)
    if filereadable(uri)
      call scnvim#help#open(uri)
      " execute printf("normal! edit +/%s \"%s\"", item.pattern, uri)
    else
      call scnvim#help#render(uri)
    endif
  endif
endfunction

function! scnvim#help#render(uri)
  " SCNvimDoc.prepareHelpForURL(url);
endfunction
