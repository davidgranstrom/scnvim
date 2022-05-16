" Copyright 2007 Alex Norman
" This file is part of SCVIM.
"
" SCVIM is free software: you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation, either version 3 of the License, or
" (at your option) any later version.
"
" SCVIM is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with SCVIM.  If not, see <http://www.gnu.org/licenses/>.
"
" Vim syntax file
" Language:	supercollider
" Maintainer: Stephen Lumenta <stephen.lumenta@gmail.com>
" Version:	0.2
" Last change:	2012-03-31
"
" Maintainer: David Granström <info@davidgranstrom.com>
" Version:	0.3
" Modified:	2018-01-06

scriptencoding utf-8

if exists('b:current_syntax')
  finish
endif
let b:current_syntax = 'supercollider'

syn clear

" source generated syntax file
let classes = luaeval('require("scnvim.path").get_asset "syntax"')
if filereadable(classes)
  execute "source " . classes
endif

syn match	scAoperator	"{"
syn match	scAoperator	"}"

"syn	match	scVariable	"\%(var.*\)\@<=\(\l\w*\)" "lowercase followed by wordchar
syn	match	scGlobvariable	"\~\l\w*" "~ followed by lowercase followed by wordchar
syn	match scVar "\s*var\s"
syn	match scVar "\s*classvar\s"
syn	match scVar "\s*const\s"
syn	match scArg "\s*arg\s"

" symbols, strings, numbers
syn match	scSymbol "\v(\w|\\)@<!\'.{-}(\\)@<!\'" "\{-} is a non greedy version of *
syn match	scSymbol "\v\$@<!\\\w\w*"
syn match	scSymbol "\\\\"
syn match	scSymbol "\w\+:"

syn region  scString start=+"+ skip=+\\\\\|\\"+ end=+"+

syn match	scChar	"\$\\\?."

syn match scInteger	"\%(\%(\w\|[]})\"']\s*\)\@<!-\)\=\<0[xX]\x\+\%(_\x\+\)*\>"								display
syn match scInteger	"\%(\%(\w\|[]})\"']\s*\)\@<!-\)\=\<\%(0[dD]\)\=\%(0\|[1-9]\d*\%(_\d\+\)*\)\>"						display
syn match scInteger	"\%(\%(\w\|[]})\"']\s*\)\@<!-\)\=\<0[oO]\=\o\+\%(_\o\+\)*\>"								display
syn match scInteger	"\%(\%(\w\|[]})\"']\s*\)\@<!-\)\=\<0[bB][01]\+\%(_[01]\+\)*\>"								display
syn match scFloat	"\%(\%(\w\|[]})\"']\s*\)\@<!-\)\=\<\%(0\|[1-9]\d*\%(_\d\+\)*\)\.\d\+\%(_\d\+\)*\>"					display
syn match scFloat	"\%(\%(\w\|[]})\"']\s*\)\@<!-\)\=\<\%(0\|[1-9]\d*\%(_\d\+\)*\)\%(\.\d\+\%(_\d\+\)*\)\=\%([eE][-+]\=\d\+\%(_\d\+\)*\)\>"	display
syn match scInfinity "inf"

" keywords
syn match   scControl	"\<\%(break\|rescue\|return\)\>[?!]\@!"
syn match   scKeyword	"\<\%(super\|this\|new\|yield\)\>[?!]\@!"
syn match   scBoolean	"\<\%(true\|false\)\>[?!]\@!"
syn match   scControl "\<\%(case\|begin\|do\|forBy\|loop\|if\|while\|else\)\>[?!]\@!"

" scsynth
syn match scArate "\v\.@<=ar(\w)@!"
syn match scKrate "\v\.@<=kr(\w)@!"

" operators
syn keyword  scUnaryoperator  neg reciprocal abs floor ceil frac sign squared cubed sqrt exp midicps cpsmidi midiratio ratiomidi dbamp ampdb octcps cpsoct log log2 log10 sin cos tan asin acos atan sinh cosh tanh distort softclip isPositive isNegative isStrictlyPositive
syn keyword  scBinaryoperator  min max round trunc atan2 hypot hypotApx ring1 ring2 ring3 ring4 sumsqr difsqr sqrsum sqrdif absdif thresh amclip scaleneg clip2 wrap2 fold2 excess + - *

syn match scBinaryoperator "+"
syn match scBinaryoperator "-"
syn match scBinaryoperator "*"
syn match scBinaryoperator "/"
syn match scBinaryoperator "%"
syn match scBinaryoperator "\*\*"
syn match scBinaryoperator "<"
syn match scBinaryoperator "<="
syn match scBinaryoperator ">"
syn match scBinaryoperator "<>"
syn match scBinaryoperator ">="
syn match scBinaryoperator "="
syn match scBinaryoperator "=="
syn match scBinaryoperator "==="
syn match scBinaryoperator "!="
syn match scBinaryoperator "!=="
syn match scBinaryoperator "&"
syn match scBinaryoperator "|"
syn match scBinaryoperator "<!"
syn match scBinaryoperator "?"
syn match scBinaryoperator "??"
syn match scBinaryoperator "!?"
syn match scBinaryoperator "!"
syn match scBinaryoperator "#"
syn match scBinaryoperator "_"
syn match scBinaryoperator "\.\."
syn match scBinaryoperator "\.\.\."
syn match scBinaryoperator "`"
syn match scBinaryoperator ":"

" comments
syn keyword scCommentTodo   TODO FIXME XXX TBD contained
syn match   scLineComment   "\/\/.*" contains=@Spell,scCommentTodo
syn region  scComment	      start="/\*"  end="\*/" contains=@Spell,scCommentTodo

"""""""""""""""""""""""""""""""""""""""""
" linkage

hi def link scObject Identifier
hi def link scBinaryoperator Special
hi def link scUnaryoperator Special
hi def link scAoperator Statement
hi def link scArate Statement
hi def link scKrate Statement
hi def link scSymbol Constant
hi def link scString String
hi def link scChar String
hi def link scInteger Number
hi def link scInfinity Number
hi def link scFloat Float
hi def link scGlobVariable Define
hi def link scComment		Comment
hi def link scLineComment		Comment
hi def link scCommentTodo		Todo
hi def link scVar Type
hi def link scArg Type
hi def link scControl Statement
hi def link scKeyword Keyword
hi def link scBoolean Boolean
