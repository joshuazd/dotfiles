" vim-marks
" Maintainer:	joshuazd
" Version:	0.1.0
" Location:	plugin/marks.vim
"

if exists('g:loaded_marks')
  finish
endif
let g:loaded_marks = 1

let s:save_cpo = &cpo
set cpo&vim

nnoremap ' :call marks#marks()<CR>

let &cpo = s:save_cpo
unlet s:save_cpo
