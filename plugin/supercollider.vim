if exists('g:scnvim_loaded')
  finish
endif
let g:scnvim_loaded = 1

noremap <unique><script><silent> <Plug>(scnvim-send-line) :<c-u>call scnvim#send_line()<cr>
noremap <unique><script><silent> <Plug>(scnvim-send-block) :<c-u>call scnvim#send_block()<cr>
noremap <unique><script><silent> <Plug>(scnvim-send-selection) :<c-u>call scnvim#send_selection()<cr>
noremap <unique><script><silent> <Plug>(scnvim-open-postwindow) :<c-u>call scnvim#open_post_window()<cr>
