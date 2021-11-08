if exists('g:loaded_tmuxnavigate')
  finish
endif
let g:loaded_tmuxnavigate = 1

let s:save_cpo = &cpo
set cpo&vim

let s:tmux_is_last_pane = 0
augroup tmux_navigator
  autocmd!
  autocmd WinEnter * let s:tmux_is_last_pane = 0
augroup END

nnoremap <Plug>(tmuxLeft) :call tmuxnavigate#TmuxWinCmd('h')<CR>
nnoremap <Plug>(tmuxRight) :call tmuxnavigate#TmuxWinCmd('l')<CR>
nnoremap <Plug>(tmuxUp) :call tmuxnavigate#TmuxWinCmd('k')<CR>
nnoremap <Plug>(tmuxDown) :call tmuxnavigate#TmuxWinCmd('j')<CR>
tnoremap <Plug>(tmuxLeft) <C-w>:call tmuxnavigate#TmuxWinCmd('h')<CR>
tnoremap <Plug>(tmuxRight) <C-w>:call tmuxnavigate#TmuxWinCmd('l')<CR>
tnoremap <Plug>(tmuxUp) <C-w>:call tmuxnavigate#TmuxWinCmd('k')<CR>
tnoremap <Plug>(tmuxDown) <C-w>:call tmuxnavigate#TmuxWinCmd('j')<CR>

nmap <silent> <C-h> <Plug>(tmuxLeft)
nmap <silent> <C-l> <Plug>(tmuxRight)
nmap <silent> <C-k> <Plug>(tmuxUp)
nmap <silent> <C-j> <Plug>(tmuxDown)
tmap <silent> <C-h> <Plug>(tmuxLeft)
tmap <silent> <C-l> <Plug>(tmuxRight)
tmap <silent> <C-k> <Plug>(tmuxUp)
tmap <silent> <C-j> <Plug>(tmuxDown)

let &cpo = s:save_cpo
unlet s:save_cpo
