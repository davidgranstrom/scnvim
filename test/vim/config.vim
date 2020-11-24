" Install vim-plug if not found
if empty(glob('./.deps/nvim/autoload/plug.vim'))
  silent !curl -fLo './.deps/nvim/autoload/plug.vim' --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" " Run PlugInstall if there are missing plugins
" if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
"   autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
" endif

" call plug#begin('./deps/plugged')
" Plug 'davidgranstrom/scnvim', {'do': {-> call scnvim#install() }}
" call plug#end()
