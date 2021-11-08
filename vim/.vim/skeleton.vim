if exists('g:loaded_@file_name@')
  finish
endif
let g:loaded_@file_name@ = 1

let s:save_cpo = &cpo
set cpo&vim

@start_here@

let &cpo = s:save_cpo
unlet s:save_cpo
