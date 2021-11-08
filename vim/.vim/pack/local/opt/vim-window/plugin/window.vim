if exists('g:loaded_window')
  finish
endif
let g:loaded_window = 1

let s:save_cpo = &cpo
set cpo&vim

nnoremap <Plug>(WindowLeft) <C-w><:silent! call repeat#set("\<Plug>(WindowLeft)")<CR>
nnoremap <Plug>(WindowRight) <C-w>>:silent! call repeat#set("\<Plug>(WindowRight)")<CR>
nnoremap <Plug>(WindowUp) <C-w>+:silent! call repeat#set("\<Plug>(WindowUp)")<CR>
nnoremap <Plug>(WindowDown) <C-w>-:silent! call repeat#set("\<Plug>(WindowDown)")<CR>

function! window#define_map(mode, lhs, rhs) abort
  if maparg(a:lhs, a:mode) ==? ''
    execute a:mode . 'map <silent> ' . a:lhs . ' ' . a:rhs
  endif
endfunction

call window#define_map('n', '<C-w><', '<Plug>(WindowLeft)')
call window#define_map('n', '<C-w>>', '<Plug>(WindowRight)')
call window#define_map('n', '<C-w>+', '<Plug>(WindowUp)')
call window#define_map('n', '<C-w>-', '<Plug>(WindowDown)')

let &cpo = s:save_cpo
unlet s:save_cpo
