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

  inoremap <silent> <C-J> <C-R>=((UltiSnips_ExpandJump() > 0) ? "" : (pumvisible() ? "\<C-y>\<TAB>" : "\<TAB>"))<CR>
  " inoremap <silent> <expr> <S-TAB> "<ESC>:call UltiSnips#JumpBackwards()<CR>"
  xnoremap <silent> <expr> <C-J>   ":<C-U>call UltiSnips#SaveLastVisualSelection()<cr>gvs"
  snoremap <silent> <expr> <C-J>   "<ESC>:call UltiSnips#JumpForwards()<CR>"
  " snoremap <silent> <expr> <S-TAB> "<ESC>:call UltiSnips#JumpBackwards()<CR>"
endif

if exists('g:loaded_copilot')
  imap <silent><script><expr> <TAB> copilot#Accept("\<TAB>")
  imap <silent> <C-L> <Plug>(copilot-suggest)
endif

if exists('g:loaded_mucomplete')
  if exists('g:loaded_endwise')
    imap <expr> <cr> pumvisible() ? "<c-y><cr>" : "\<cr>\<Plug>DiscretionaryEnd"
  else
    inoremap <expr> <cr> pumvisible() ? "<c-y><cr>" : "\<cr>"
  endif
	imap <c-n> <plug>(MUcompleteFwd)
	imap <c-p> <plug>(MUcompleteBwd)
	" inoremap <silent> <plug>(MUcompleteFwdKey) <c-j>
	" imap <c-j> <plug>(MUcompleteCycFwd)
	" inoremap <silent> <plug>(MUcompleteBwdKey) <c-h>
	" imap <c-h> <plug>(MUcompleteCycBwd)
endif

if exists('g:loaded_qlist')
  nnoremap <Space>i :Ilist<space>
  nmap <Space>8 <Plug>QlistIncludefromtop:cdo s//g<Left><Left>
endif

if exists('g:loaded_fugitive')
  nnoremap <space>gs :rightbelow Git<CR>
  nnoremap <space>gS :rightbelow Git!<CR>
  nnoremap <space>gl :Gpull<CR>
  nnoremap <space>gp :Gpush<CR>
  cnoreabbrev @@ <C-r>=FugitiveHead()<CR>
endif

if exists(':History')
  nnoremap <space>H :History<CR>
  nnoremap <space>F :Files<CR>
  nnoremap <space>G :GFiles<CR>
  nnoremap <space>T :Tags<CR>
  nnoremap <space>L :Lines<CR>
  nnoremap <space>B :Buffers<CR>
endif

if exists('g:loaded_ale_dont_use_this_in_other_plugins_please')
  nmap ]e <Plug>(ale_next)
  nmap [e <Plug>(ale_previous)
  nmap ]E <Plug>(ale_last)
  nmap [E <Plug>(ale_first)
endif

if exists('g:loaded_signify')
  omap ih <plug>(signify-motion-inner-pending)
  xmap ih <plug>(signify-motion-inner-visual)
  omap ah <plug>(signify-motion-outer-pending)
  xmap ah <plug>(signify-motion-outer-visual)
endif

if exists('g:loaded_endwise')
  nmap o A<CR>
endif
