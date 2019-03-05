if exists('g:loaded_sneak_plugin')

    nmap f <Plug>Sneak_f
    nmap F <Plug>Sneak_F
    xmap f <Plug>Sneak_f
    xmap F <Plug>Sneak_F
    omap f <Plug>Sneak_f
    omap F <Plug>Sneak_F

    nmap t <Plug>Sneak_t
    nmap T <Plug>Sneak_T
    xmap t <Plug>Sneak_t
    xmap T <Plug>Sneak_T
    omap t <Plug>Sneak_t
    omap T <Plug>Sneak_T

    nmap , <Plug>Sneak_,
    omap , <Plug>Sneak_,
    xmap , <Plug>Sneak_,

    silent! unmap \

endif

if exists('g:loaded_fzf')
  runtime! autoload/quickfix.vim
  command! -bang Rg call fzf#run(fzf#wrap('rg',
        \{'source': 'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>),
        \ 'options': ['--multi','--ansi','--preview-window', <bang>0 ? 'up:75%' : 'right:50%'],
        \ 'down': '25%',
        \ 'sink*': funcref('quickfix#add')}, <bang>0 ) )
endif

if exists('did_plugin_ultisnips')
  let g:ulti_expand_or_jump_res = 0
  function! UltiSnips_ExpandJump() abort
    call UltiSnips#ExpandSnippetOrJump()
    return g:ulti_expand_or_jump_res
  endfunction

  inoremap <silent> <TAB> <C-R>=((UltiSnips_ExpandJump() > 0) ? "" : (pumvisible() ? "\<C-y>\<TAB>" : "\<TAB>"))<CR>
  inoremap <silent> <expr> <S-TAB> "<ESC>:call UltiSnips#JumpBackwards()<CR>"
  xnoremap <silent> <expr> <TAB>   ":<C-U>call UltiSnips#SaveLastVisualSelection()<cr>gvs"
  snoremap <silent> <expr> <TAB>   "<ESC>:call UltiSnips#JumpForwards()<CR>"
  snoremap <silent> <expr> <S-TAB> "<ESC>:call UltiSnips#JumpBackwards()<CR>"
endif

if exists('g:loaded_mucomplete')
  if exists('g:loaded_endwise')
    imap <expr> <cr> pumvisible() ? "<c-y><cr>" : "\<cr>\<Plug>DiscretionaryEnd"
  else
    inoremap <expr> <cr> pumvisible() ? "<c-y><cr>" : "\<cr>"
  endif
  inoremap <expr> <right> mucomplete#extend_fwd("\<right>")
  inoremap <expr> <left> mucomplete#extend_bwd("\<left>")
endif

if exists('g:loaded_qlist')
  nnoremap <Space>i :Ilist<space>
  nmap <Space>8 <Plug>QlistIncludefromtop:cdo s//g<Left><Left>
endif

if exists('g:loaded_fugitive')
  nnoremap gs :Gstatus<CR>
endif
