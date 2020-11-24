" add scnvim to runtime path
let &runtimepath .= ','.expand('%:p:h:h')
