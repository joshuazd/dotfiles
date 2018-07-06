if exists('g:loaded_sneak_plugin') && g:loaded_sneak_plugin == 1

    " 1-character enhanced 'f'
    nmap f <Plug>Sneak_f
    nmap F <Plug>Sneak_F
    " visual-mode
    xmap f <Plug>Sneak_f
    xmap F <Plug>Sneak_F
    " operator-pending-mode
    omap f <Plug>Sneak_f
    omap F <Plug>Sneak_F

    " 1-character enhanced 't'
    nmap t <Plug>Sneak_t
    nmap T <Plug>Sneak_T
    " visual-mode
    xmap t <Plug>Sneak_t
    xmap T <Plug>Sneak_T
    " operator-pending-mode
    omap t <Plug>Sneak_t
    omap T <Plug>Sneak_T

endif

if exists(':Files')
  nnoremap \f :Files<CR>
  command! -bang -nargs=* Rg
        \ call fzf#vim#grep(
        \   'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
        \   <bang>0 ? fzf#vim#with_preview('up:60%')
        \           : fzf#vim#with_preview('right:50%:hidden', '?'),
        \   <bang>0)
  nnoremap \g :Rg<CR>
  nnoremap \l :Lines<CR>
  nnoremap \j :Tags<CR>
endif

if exists('did_plugin_ultisnips')
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

if exists('g:loaded_mucomplete')
  imap <c-e> <plug>(MUcompletePopupCancel)
  imap <c-y> <plug>(MUcompletePopupAccept)
  imap <expr> <right> pumvisible() ? "\<plug>(MUcompleteExtendFwd)" : "\<right>"
  imap <expr> <left> pumvisible() ? "\<plug>(MUcompleteExtendBwd)" : "\<left>"
endif

if exists('g:loaded_qlist') && g:loaded_qlist == 1
  
  nnoremap <Space>i :Ilist<space>
  nmap <Space>8 <Plug>QlistIncludefromtop:cdo s//g<Left><Left>

endif
