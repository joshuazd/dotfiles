if exists('g:loaded_textobj#declaration')
  finish
endif
let g:loaded_textobj#declaration = 1

let s:save_cpo = &cpo
set cpo&vim

function! s:declaration(whitespace, visualmode) abort
  let ws = a:whitespace
  " find the first word on the current line
  let match = escape(matchstr(getline('.'), '\v^\s*\zs' . get(b:, 'textobj_declaration_char', '\k') . '+'), '!@#$%^&*()[]-+={};:<>,.\|?/`~')
  normal! ^
  " jump back to the first line after a line that doesn't start with the match
  call search('\v^\s*%(%(^\s*' . match . ')@<!.)+$' . (ws ? '\n%(^\s*$\n|.)\ze' : '') . '\_s*.', 'bWec')
  execute 'normal! ' . a:visualmode
  " jump forward to the line before the next line that doesn't match
  call search('\v\S\s*\n^\_s*%(%(' . match . ')@<!.)*$', 'Wc')
  if ws
    call search('\v\_s*\n\ze(\s*\S*)', 'Wce')
  endif
endfunction

xnoremap <silent> <Plug>(textobj#declaration_inner) :<C-u>call <SID>declaration(0,visualmode())<CR>
onoremap <silent> <Plug>(textobj#declaration_inner) :<C-u>call <SID>declaration(0,'V')<CR>
xnoremap <silent> <Plug>(textobj#declaration_around) :<C-u>call <SID>declaration(1,visualmode())<CR>
onoremap <silent> <Plug>(textobj#declaration_around) :<C-u>call <SID>declaration(1,'V')<CR>

if get(g:,'textobj_maps',1)
  xmap id <Plug>(textobj#declaration_inner)
  omap id <Plug>(textobj#declaration_inner)
  xmap ad <Plug>(textobj#declaration_around)
  omap ad <Plug>(textobj#declaration_around)
endif

let &cpo = s:save_cpo
unlet s:save_cpo
