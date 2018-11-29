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

function! s:marks() abort
  redir => message
  silent! execute 'marks'
  redir END
  vnew
  silent! setlocal buftype=nofile bufhidden=wipe nobuflisted
  put! =message
  wincmd p
  normal! 999zh
  redraw!
  echom '`'
  let m = nr2char(getchar())
  execute 'normal! `' . m
  wincmd p | close
  normal! 999zh
endfunction
nnoremap ' :call <SID>marks()<CR>

let &cpo = s:save_cpo
unlet s:save_cpo
