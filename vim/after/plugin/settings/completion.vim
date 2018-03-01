if exists(':UltiSnipsEdit')
  " Only map these if ultisnips is installed.  Prevents screwing up mappings
  let g:ulti_expand_or_jump_res = 0
  function! UltiSnips_ExpandJump() abort
    call UltiSnips#ExpandSnippetOrJump()
    return g:ulti_expand_or_jump_res
  endfunction

  inoremap <silent> <CR> <C-R>=((UltiSnips_ExpandJump() > 0) ? "" : (pumvisible() ? "\<C-y>\r" : "\r"))<CR>
  xnoremap <silent> <expr> <TAB>   ":<C-U>call UltiSnips#SaveLastVisualSelection()<cr>gvs"
  snoremap <silent> <expr> <TAB>   "<ESC>:call UltiSnips#JumpForwards()<CR>"
  snoremap <silent> <expr> <S-TAB> "<ESC>:call UltiSnips#JumpBackwards()<CR>"
  snoremap <silent> <expr> <CR>    "<ESC>:call UltiSnips#JumpForwards()<CR>"
endif

if exists('g:mucomplete#chains')
  imap <c-e> <plug>(MUcompleteCte)
  imap <c-y> <plug>(MUcompleteCty)
endif
