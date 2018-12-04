" Vim global plugin for heads-up digraph interactions...
" Maintainer:	Damian Conway
" License:	This file is placed in the public domain.

"##############################################################################
"##                                                                          ##
"##  To use:                                                                 ##
"##                                                                          ##
"##    inoremap <expr>  <C-K>   HUDG_GetDigraph()                            ##
"##                                                                          ##
"##############################################################################


" If already loaded, we're done...
if exists('loaded_hudigraphs')
    finish
endif
let loaded_hudigraphs = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

" Highlight group that emulates cursor appearance during digraph insertion...
highlight HUDG_Cursor_Emulation  ctermfg=blue ctermbg=white


inoremap <expr> <C-k> hudigraphs#HUDG_GetDigraph()

" Restore previous external compatibility options
let &cpo = s:save_cpo

