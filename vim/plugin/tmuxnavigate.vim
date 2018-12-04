let s:tmux_is_last_pane = 0
augroup tmux_navigator
  autocmd!
  autocmd WinEnter * let s:tmux_is_last_pane = 0
augroup END

nnoremap <Plug>(tmuxLeft) :call tmuxnavigate#TmuxWinCmd('h')<CR>
nnoremap <Plug>(tmuxRight) :call tmuxnavigate#TmuxWinCmd('l')<CR>
nnoremap <Plug>(tmuxUp) :call tmuxnavigate#TmuxWinCmd('k')<CR>
nnoremap <Plug>(tmuxDown) :call tmuxnavigate#TmuxWinCmd('j')<CR>

nmap <silent> <C-h> <Plug>(tmuxLeft)
nmap <silent> <C-l> <Plug>(tmuxRight)
nmap <silent> <C-k> <Plug>(tmuxUp)
nmap <silent> <C-j> <Plug>(tmuxDown)
