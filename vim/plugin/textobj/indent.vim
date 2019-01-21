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

call textobj#textobj#define_map('o', 'ai', '<Plug>(textobj#indent_aroundindent)')
call textobj#textobj#define_map('x', 'ai', '<Plug>(textobj#indent_aroundindent)')
call textobj#textobj#define_map('o', 'ii', '<Plug>(textobj#indent_innerindent)')
call textobj#textobj#define_map('x', 'ii', '<Plug>(textobj#indent_innerindent)')

call textobj#textobj#define_map('o', 'iI', '<Plug>(textobj#indent_blockindent_inner)')
call textobj#textobj#define_map('x', 'iI', '<Plug>(textobj#indent_blockindent_inner)')
call textobj#textobj#define_map('o', 'aI', '<Plug>(textobj#indent_blockindent_outer)')
call textobj#textobj#define_map('x', 'aI', '<Plug>(textobj#indent_blockindent_outer)')

call textobj#textobj#define_map('n', '<Space>j', '<Plug>(textobj#indent_nextindent)')
call textobj#textobj#define_map('x', '<Space>j', '<Plug>(textobj#indent_nextindent)')
call textobj#textobj#define_map('o', '<Space>j', '<Plug>(textobj#indent_nextindent)')
call textobj#textobj#define_map('n', '<Space>k', '<Plug>(textobj#indent_previndent)')
call textobj#textobj#define_map('x', '<Space>k', '<Plug>(textobj#indent_previndent)')
call textobj#textobj#define_map('o', '<Space>k', '<Plug>(textobj#indent_previndent)')

let &cpo = s:save_cpo
unlet s:save_cpo
