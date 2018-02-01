let g:UltiSnipsJumpForwardTrigger="\<C-l>"
let g:UltiSnipsJumpBackwardTrigger="\<C-h>"
let g:UltiSnipsExpandTrigger="<C-\\>"
let g:ulti_expand_or_jump_res = 0
let g:ulti_jump_forwards_res = 0
let g:ulti_jump_backwards_res = 0
let g:vcm_s_tab_behavior = 1
let g:vcm_default_maps = 0

function! UltiSnips_ExpandJump() abort
  call UltiSnips#ExpandSnippetOrJump()
  return g:ulti_expand_or_jump_res
endfunction

imap <silent> <TAB> <Plug>vim_completes_me_forward
imap <silent> <S-TAB> <Plug>vim_completes_me_backward
imap <silent> <CR> <C-R>=((UltiSnips_ExpandJump() > 0) ? "" : "\r")<CR><Plug>AutoPairsReturn
xnoremap <silent> <expr> <TAB>   ":<C-U>call UltiSnips#SaveLastVisualSelection()<cr>gvs"
snoremap <silent> <expr> <TAB>   "<ESC>:call UltiSnips#JumpForwards()<CR>"
snoremap <silent> <expr> <S-TAB> "<ESC>:call UltiSnips#JumpBackwards()<CR>"
snoremap <silent> <expr> <CR>    "<ESC>:call UltiSnips#JumpForwards()<CR>"


" python setup {{{
let g:jedi#completions_enabled = 0
let g:jedi#auto_vim_configuration = 0
let g:jedi#smart_auto_mappings = 0
" }}}

" clang setup {{{
let g:clang_auto = 0 " disable auto completion for vim-clang
let g:clang_c_completeopt = 'menuone,preview'
let g:clang_cpp_completeopt = 'menuone,preview'
let g:clang_verbose_pmenu = 1
" }}}

