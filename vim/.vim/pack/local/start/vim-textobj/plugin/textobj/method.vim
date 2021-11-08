if exists('g:loaded_textobj#method')
  finish
endif
let g:loaded_textobj#method = 1

let s:save_cpo = &cpo
set cpo&vim

" vint: -ProhibitCommandRelyOnUser
function! s:method(whitespace, visualmode) abort
  normal [mV]M
  if a:whitespace && line('.') < line('$')
    normal! j
    if getline('.') !~? '^\s*$'
      normal! k
    endif
  endif
endfunction
" vint: +ProhibitCommandRelyOnUser

xnoremap <silent> <Plug>(textobj#method_inner) :<C-u>call <SID>method(0,visualmode())<CR>
onoremap <silent> <Plug>(textobj#method_inner) :<C-u>call <SID>method(0,'V')<CR>
xnoremap <silent> <Plug>(textobj#method_around) :<C-u>call <SID>method(1,visualmode())<CR>
onoremap <silent> <Plug>(textobj#method_around) :<C-u>call <SID>method(1,'V')<CR>

if get(g:,'textobj_maps',1)
  xmap im <Plug>(textobj#method_inner)
  omap im <Plug>(textobj#method_inner)
  xmap am <Plug>(textobj#method_around)
  omap am <Plug>(textobj#method_around)
endif

let &cpo = s:save_cpo
unlet s:save_cpo

