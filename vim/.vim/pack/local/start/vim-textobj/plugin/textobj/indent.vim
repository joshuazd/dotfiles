if exists('g:loaded_textobj#indent')
  finish
endif
let g:loaded_textobj#indent = 1

let s:save_cpo = &cpo
set cpo&vim

onoremap <silent> <Plug>(textobj#indent_aroundindent) :<C-u>call textobj#indent#indentTextObj(0,0)<CR>
xnoremap <silent> <Plug>(textobj#indent_aroundindent) m'<Esc>:call textobj#indent#indentTextObj(0,0)<CR><Esc>gv
onoremap <silent> <Plug>(textobj#indent_innerindent)  :<C-u>call textobj#indent#indentTextObj(1,0)<CR>
xnoremap <silent> <Plug>(textobj#indent_innerindent)  m'<Esc>:call textobj#indent#indentTextObj(1,0)<CR><Esc>gv

onoremap <silent> <Plug>(textobj#indent_blockindent_inner) :<C-u>call textobj#indent#indentTextObj(1,1)<CR>
xnoremap <silent> <Plug>(textobj#indent_blockindent_inner) m'<Esc>:call textobj#indent#indentTextObj(1,1)<CR><Esc>gv
onoremap <silent> <Plug>(textobj#indent_blockindent_outer) :<C-u>call textobj#indent#indentTextObj(0,1)<CR>
xnoremap <silent> <Plug>(textobj#indent_blockindent_outer) m'<Esc>:call textobj#indent#indentTextObj(0,1)<CR><Esc>gv

nnoremap <silent> <Plug>(textobj#indent_nextindent) :<C-u>call textobj#indent#findSameIndent(v:count1, 'j', 0, 0)<CR>
xnoremap <silent> <Plug>(textobj#indent_nextindent) <Esc>:call textobj#indent#findSameIndent(v:count1, 'j', 1, 0)<CR><Esc>gv
onoremap <silent> <Plug>(textobj#indent_nextindent) :<C-u>call textobj#indent#findSameIndent(v:count1, 'j', 0, 1)<CR>
nnoremap <silent> <Plug>(textobj#indent_previndent) :<C-u>call textobj#indent#findSameIndent(v:count1, 'k', 0, 0)<CR>
xnoremap <silent> <Plug>(textobj#indent_previndent) <Esc>:call textobj#indent#findSameIndent(v:count1, 'k', 1, 0)<CR><Esc>gv
onoremap <silent> <Plug>(textobj#indent_previndent) :<C-u>call textobj#indent#findSameIndent(v:count1, 'k', 0, 1)<CR>

if get(g:,'textobj_maps',1)
  omap ai <Plug>(textobj#indent_aroundindent)
  xmap ai <Plug>(textobj#indent_aroundindent)
  omap ii <Plug>(textobj#indent_innerindent)
  xmap ii <Plug>(textobj#indent_innerindent)

  omap iI <Plug>(textobj#indent_blockindent_inner)
  xmap iI <Plug>(textobj#indent_blockindent_inner)
  omap aI <Plug>(textobj#indent_blockindent_outer)
  xmap aI <Plug>(textobj#indent_blockindent_outer)

  nmap <Space>j <Plug>(textobj#indent_nextindent)
  xmap <Space>j <Plug>(textobj#indent_nextindent)
  omap <Space>j <Plug>(textobj#indent_nextindent)
  nmap <Space>k <Plug>(textobj#indent_previndent)
  xmap <Space>k <Plug>(textobj#indent_previndent)
  omap <Space>k <Plug>(textobj#indent_previndent)
endif

let &cpo = s:save_cpo
unlet s:save_cpo
