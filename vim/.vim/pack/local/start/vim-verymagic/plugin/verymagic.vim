if exists('g:loaded_verymagic')
  finish
endif
let g:loaded_verymagic = 1

let s:save_cpo = &cpo
set cpo&vim

nnoremap / /\v
nnoremap ? ?\v
for char in ['~', '`', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '-', '+', '=', '{', '}', '[', ']', ':', ';', "'", '<', '>', ',', '.', '?', '/']
  execute 'cnoremap <expr> ' . char . ' verymagic#verymagic("' . char . '")'
endfor

cnoremap <expr> <BS> getcmdline() =~? '\\v$' ? '<BS><BS>' : '<BS>'

let &cpo = s:save_cpo
unlet s:save_cpo
