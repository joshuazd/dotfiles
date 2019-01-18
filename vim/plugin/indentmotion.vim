if exists('g:loaded_indentmotion')
  finish
endif
let g:loaded_indentmotion = 1

let s:save_cpo = &cpo
set cpo&vim

onoremap <silent> <Plug>(indentmotion_aroundindent) :<C-u>call indentmotion#indentTextObj(0)<CR>
onoremap <silent> <Plug>(indentmotion_innerindent)  :<C-u>call indentmotion#indentTextObj(1)<CR>
xnoremap <silent> <Plug>(indentmotion_aroundindent) <Esc>:call indentmotion#indentTextObj(0)<CR><Esc>gv
xnoremap <silent> <Plug>(indentmotion_innerindent)  <Esc>:call indentmotion#indentTextObj(1)<CR><Esc>gv

nnoremap <silent> <Plug>(indentmotion_nextindent) :<C-u>call indentmotion#findSameIndent(v:count1, 'j', 0, 0)<CR>
nnoremap <silent> <Plug>(indentmotion_previndent) :<C-u>call indentmotion#findSameIndent(v:count1, 'k', 0, 0)<CR>
xnoremap <silent> <Plug>(indentmotion_nextindent) <Esc>:call indentmotion#findSameIndent(v:count1, 'j', 1, 0)<CR><Esc>gv
xnoremap <silent> <Plug>(indentmotion_previndent) <Esc>:call indentmotion#findSameIndent(v:count1, 'k', 1, 0)<CR><Esc>gv
onoremap <silent> <Plug>(indentmotion_nextindent) :<C-u>call indentmotion#findSameIndent(v:count1, 'j', 0, 1)<CR>
onoremap <silent> <Plug>(indentmotion_previndent) :<C-u>call indentmotion#findSameIndent(v:count1, 'k', 0, 1)<CR>

onoremap <silent> <Plug>(indentmotion_blockindent) :<C-u>call indentmotion#blockTextObj()<CR>
xnoremap <silent> <Plug>(indentmotion_blockindent) <Esc>:call indentmotion#blockTextObj()<CR><Esc>gv

function! s:define_map(mode, lhs, rhs) abort
  if !hasmapto(a:rhs, get({'x':'v'}, a:mode, a:mode)) && maparg(a:lhs, a:mode) ==? ''
    execute a:mode . 'map <silent> ' . a:lhs . ' ' . a:rhs
  endif
endfunction

call <SID>define_map('o', 'ai', '<Plug>(indentmotion_aroundindent)')
call <SID>define_map('x', 'ai', '<Plug>(indentmotion_aroundindent)')

call <SID>define_map('o', 'ii', '<Plug>(indentmotion_innerindent)')
call <SID>define_map('x', 'ii', '<Plug>(indentmotion_innerindent)')

call <SID>define_map('n', '<Space>j', '<Plug>(indentmotion_nextindent)')
call <SID>define_map('x', '<Space>j', '<Plug>(indentmotion_nextindent)')
call <SID>define_map('o', '<Space>j', '<Plug>(indentmotion_nextindent)')

call <SID>define_map('n', '<Space>k', '<Plug>(indentmotion_previndent)')
call <SID>define_map('x', '<Space>k', '<Plug>(indentmotion_previndent)')
call <SID>define_map('o', '<Space>k', '<Plug>(indentmotion_previndent)')

call <SID>define_map('o', 'iI', '<Plug>(indentmotion_blockindent)')
call <SID>define_map('x', 'iI', '<Plug>(indentmotion_blockindent)')

let &cpo = s:save_cpo
unlet s:save_cpo
