if exists('g:loaded_textobj#method')
  finish
endif
let g:loaded_textobj#method = 1

let s:save_cpo = &cpo
set cpo&vim

" vint: -ProhibitCommandRelyOnUser
function! s:method(whitespace, visualmode) abort
  normal [mV]M
  if a:whitespace
    normal ]m
    let lnum = line('.')
    normal [Mj
    if line('.') >= lnum && getline('.') !~? '^\s*$'
      normal! k
    endif
  endif
endfunction
" vint: +ProhibitCommandRelyOnUser

xnoremap <silent> <Plug>(textobj#method_inner) :<C-u>call <SID>method(0,visualmode())<CR>
onoremap <silent> <Plug>(textobj#method_inner) :<C-u>call <SID>method(0,'V')<CR>
xnoremap <silent> <Plug>(textobj#method_around) :<C-u>call <SID>method(1,visualmode())<CR>
onoremap <silent> <Plug>(textobj#method_around) :<C-u>call <SID>method(1,'V')<CR>

call textobj#textobj#define_map('x', 'im', '<Plug>(textobj#method_inner)')
call textobj#textobj#define_map('o', 'im', '<Plug>(textobj#method_inner)')
call textobj#textobj#define_map('x', 'am', '<Plug>(textobj#method_around)')
call textobj#textobj#define_map('o', 'am', '<Plug>(textobj#method_around)')

let &cpo = s:save_cpo
unlet s:save_cpo

