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
  let cmd = printf('HelpBrowser.openHelpFor("%s");', a:subject)
  call scnvim#sclang#send(cmd)
endfunction
