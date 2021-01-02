let &runtimepath .= ','.expand('%:p:h').'/lib/plenary.nvim'
let &runtimepath .= ','.expand('%:p:h')
au BufEnter * setlocal noswapfile
