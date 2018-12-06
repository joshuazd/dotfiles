if exists('g:loaded_ccr')
  finish
endif
let g:loaded_ccr = 1

let s:save_cpo = &cpo
set cpo&vim

cnoremap <expr> <CR> ccr#CCR()

let s:save_cpo = &cpo
set cpo&vim
