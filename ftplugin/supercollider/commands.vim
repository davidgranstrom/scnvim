" File: ftplugin/supercollider/commands.vim
" Author: David Granström
" Description: scnvim commands
" Last Modified: October 14, 2018

if exists("b:did_scnvim_commands")
  finish
endif

let b:did_scnvim_commands = 1

command! -buffer SCnvimStart call scnvim#sclang#open()
command! -buffer SCnvimStop call scnvim#sclang#close()

command! -buffer -range=% SCnvimSendFile call scnvim#send_line(<line1>, <line2>)
command! -buffer -range SCnvimSendLine call scnvim#send_line(<line1>, <line2>)
command! -buffer -range SCnvimSendSelection call scnvim#send_selection()
command! -buffer -range SCnvimSendBlock call scnvim#send_block()
