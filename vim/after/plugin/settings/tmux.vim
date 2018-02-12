if exists('g:loaded_tmux_navigator') && g:loaded_tmux_navigator
  let g:tmux_navigator_no_mappings = 1

  nnoremap <silent> <C-h> :TmuxNavigateLeft<cr>
  nnoremap <silent> <C-j> :TmuxNavigateDown<cr>
  nnoremap <silent> <C-k> :TmuxNavigateUp<cr>
  nnoremap <silent> <C-l> :TmuxNavigateRight<cr>

endif
