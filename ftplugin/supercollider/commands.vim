" File: ftplugin/supercollider/commands.vim
" Author: David Granström
" Description: scnvim commands

if exists("b:did_scnvim_commands")
  finish
endif

let b:did_scnvim_commands = 1

command! -buffer SCNvimStart call scnvim#sclang#open()
command! -buffer SCNvimStop call scnvim#sclang#close()
command! -buffer SCNvimRecompile call scnvim#sclang#recompile()
command! -buffer SCNvimTags call scnvim#util#generate_tags()
command! -buffer SCNvimStatusLine call scnvim#statusline#sclang_poll()
command! -buffer -nargs=+ SCNvimHelp call <SID>open_help_for(<q-args>)

" util
function! s:open_help_for(subject)
  let native = get(g:, 'scnvim_scdoc_vim', 0)
  if native
    let cmd = printf('SCNvim.openHelpFor("%s", %d);', a:subject, g:scnvim_python_port)
  else
    let cmd = printf('HelpBrowser.openHelpFor("%s");', a:subject)
  endif
  call scnvim#sclang#send_silent(cmd)
endfunction
