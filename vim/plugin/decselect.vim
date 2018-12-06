if exists('g:loaded_decselect')
  finish
endif
let g:loaded_decselect = 1

let s:save_cpo = &cpo
set cpo&vim

onoremap <silent> <Plug>(decselect) :<C-u>call decselect#Select(0)<CR>
xnoremap <silent> <Plug>(decselect) :<C-u>call decselect#Select(1)<CR>

if !hasmapto('<Plug>(decselect)')
  omap <silent> ad <Plug>(decselect)
  xmap <silent> ad <Plug>(decselect)
endif

let &cpo = s:save_cpo
unlet s:save_cpo
