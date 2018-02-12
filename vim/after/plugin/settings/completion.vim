if exists(':UltiSnipsEdit')
  " Only map these if ultisnips is installed.  Prevents screwing up mappings
  let g:ulti_expand_or_jump_res = 0
  function! UltiSnips_ExpandJump() abort
    call UltiSnips#ExpandSnippetOrJump()
    return g:ulti_expand_or_jump_res
  endfunction

  imap <silent> <expr> <CR> UltiSnips_ExpandJump() > 0 ? "" : "\<Plug>(MUcompleteCR)"
  xnoremap <silent> <expr> <TAB>   ":<C-U>call UltiSnips#SaveLastVisualSelection()<cr>gvs"
  snoremap <silent> <expr> <TAB>   "<ESC>:call UltiSnips#JumpForwards()<CR>"
  snoremap <silent> <expr> <S-TAB> "<ESC>:call UltiSnips#JumpBackwards()<CR>"
  snoremap <silent> <expr> <CR>    "<ESC>:call UltiSnips#JumpForwards()<CR>"
endif

if exists('g:mucomplete#chains')
  let g:mucomplete#chains.default += ['ulti']
  imap <c-e> <plug>(MUcompleteCte)
  imap <c-y> <plug>(MUcompleteCty)
endif

set completefunc=SnippetComplete
function! SnippetComplete(findstart, base)
  if a:findstart
    let line = getline('.')
    let start = col('.') - 1
    while start > 0 && line[start - 1] =~? '\a'
      let start -= 1
    endwhile
    return start
  else
    let suggestions = []
    let snippets = UltiSnips#SnippetsInCurrentScope()
    for entry in keys(snippets)
      if entry =~# '^'.a:base
        call add(suggestions, {'word': entry, 'menu':snippets[entry], 'kind':'S'})
      endif
    endfor
    return suggestions
  endif
endfunction
inoremap <expr> <C-s> (pumvisible() ? "\<C-u>" : "\<C-x>\<C-u>")
inoremap <C-f> <C-x><C-f>
