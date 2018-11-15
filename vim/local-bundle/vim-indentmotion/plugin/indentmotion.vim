" vim-indentmotion
" Maintainer:	joshuazd
" Version:	0.1.0
" Location:	plugin/indentmotion.vim
"

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

if !hasmapto('<Plug>(indentmotion_aroundindent')
  omap <silent> ai <Plug>(indentmotion_aroundindent)
  xmap <silent> ai <Plug>(indentmotion_aroundindent)
endif

if !hasmapto('<Plug>(indentmotion_innerindent')
  omap <silent> ii <Plug>(indentmotion_innerindent)
  xmap <silent> ii <Plug>(indentmotion_innerindent)
endif

if !hasmapto('<Plug>(indentmotion_nextindent')
  nmap <silent> <Space>j <Plug>(indentmotion_nextindent)
  xmap <silent> <Space>j <Plug>(indentmotion_nextindent)
  omap <silent> <Space>j <Plug>(indentmotion_nextindent)
endif

if !hasmapto('<Plug>(indentmotion_previndent')
  nmap <silent> <Space>k <Plug>(indentmotion_previndent)
  xmap <silent> <Space>k <Plug>(indentmotion_previndent)
  omap <silent> <Space>k <Plug>(indentmotion_previndent)
endif

if !hasmapto('<Plug>(indentmotion_blockindent')
  omap <silent> iI <Plug>(indentmotion_blockindent)
  xmap <silent> iI <Plug>(indentmotion_blockindent)
endif

let &cpo = s:save_cpo
unlet s:save_cpo
