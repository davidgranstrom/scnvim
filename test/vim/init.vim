" add scnvim to runtime path
let &runtimepath .= ','.expand('%:p:h:h')
au BufEnter * setlocal noswapfile
