" File: ftplugin/supercollider/commands.vim
" Author: David Granström
" Description: scnvim commands

scriptencoding utf-8

if exists('b:did_scnvim_commands')
  finish
endif

let b:did_scnvim_commands = 1

command! -buffer SCNvimStart call scnvim#sclang#open()
command! -buffer SCNvimStop call scnvim#sclang#close()
command! -buffer SCNvimRecompile call scnvim#sclang#recompile()
command! -buffer SCNvimTags call scnvim#util#generate_tags()
command! -buffer SCNvimStatusLine call scnvim#statusline#sclang_poll()
command! -buffer SCNvimInstall call scnvim#lua#install()
command! -buffer -nargs=+ SCNvimHelp call scnvim#help#open_help_for(<q-args>)
