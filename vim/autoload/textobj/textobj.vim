if exists('g:loaded_textobj')
  finish
endif
let g:loaded_textobj = 1

let s:save_cpo = &cpo
set cpo&vim

function! textobj#textobj#define_map(mode, lhs, rhs) abort
  if !hasmapto(a:rhs, get({'x':'v'}, a:mode, a:mode)) && maparg(a:lhs, a:mode) ==? ''
    execute a:mode . 'map <silent> ' . a:lhs . ' ' . a:rhs
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
