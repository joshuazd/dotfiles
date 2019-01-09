if exists('g:loaded_hudigraphs')
  finish
endif
let g:loaded_hudigraphs = 1

let s:save_cpo = &cpo
set cpo&vim

" Highlight group that emulates cursor appearance during digraph insertion
highlight HUDG_Cursor_Emulation  ctermfg=blue ctermbg=white

inoremap <expr> <C-k> hudigraphs#HUDG_GetDigraph()

let &cpo = s:save_cpo
unlet s:save_cpo
