" Copied from sc_indent.vim
" https://github.com/supercollider/scvim
" License GPLv3
"

if exists ('b:did_scvim_indent')
  finish
endif

let b:did_scvim_indent = 1

setlocal indentexpr=GetSCIndent()
setlocal indentkeys+=0),0],0}

if exists ('*GetSCIndent')
  finish
endif

function! GetSCIndent()
  let curr_line = getline(v:lnum)
  let lnum = prevnonblank(v:lnum - 1)

  if lnum == 0
    return 0
  endif

  let prev_line = getline(lnum)

  let ind = indent(lnum)

  " don't create indentation for code blocks
  if prev_line =~# '^($'
    return ind
  end

  if prev_line =~# '\(\/\/.*\)\@\<![[({]\s*\([^])}]*\)\=$'
    let ind = ind + &shiftwidth
  endif

  if curr_line =~# '\v^\s*[)}\]]'
    "if synIDattr(synID(line("."), col("."), 0), "name") =~? "scComment" ||
    "	synIDattr(synID(line("."), col("."), 0), "name") =~? "scString" ||
    "	synIDattr(synID(line("."), col("."), 0), "name") =~? "scSymbol"
    "	"do nothing
    "else
    let ind = ind - &shiftwidth
    "end
  endif

  return ind
endfunction
