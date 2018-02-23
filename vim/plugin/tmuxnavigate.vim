let s:tmux_is_last_pane = 0
augroup tmux_navigator
  autocmd!
  autocmd WinEnter * let s:tmux_is_last_pane = 0
augroup END

function! s:VimNavigate(direction)
  try
    execute 'wincmd ' . a:direction
  catch
    echohl ErrorMsg | echo 'E11: Invalid in command-line window; <CR> executes, CTRL-C quits: wincmd k' | echohl None
  endtry
endfunction

" Like `wincmd` but also change tmux panes instead of vim windows when needed.
function! s:TmuxWinCmd(direction)
  if $TMUX !=? ''
    call s:TmuxAwareNavigate(a:direction)
  else
    call s:VimNavigate(a:direction)
  endif
endfunction

function! s:TmuxAwareNavigate(direction)
  let nr = winnr()
  let tmux_last_pane = (a:direction ==? 'p' && s:tmux_is_last_pane)
  if !tmux_last_pane
    call s:VimNavigate(a:direction)
  endif
  let at_tab_page_edge = (nr == winnr())
  " Forward the switch panes command to tmux if:
  " a) we're toggling between the last tmux pane;
  " b) we tried switching windows in vim but it didn't have effect.
  " if s:ShouldForwardNavigationBackToTmux(tmux_last_pane, at_tab_page_edge)
  if tmux_last_pane || at_tab_page_edge
    let args = 'select-pane -t ' . shellescape($TMUX_PANE) . ' -' . tr(a:direction, 'phjkl', 'lLDUR')
    silent call system('tmux -S ' . split($TMUX,',')[0] . ' ' . args)
    let s:tmux_is_last_pane = 1
  else
    let s:tmux_is_last_pane = 0
  endif
endfunction

nnoremap <Plug>(tmuxLeft) :call <SID>TmuxWinCmd('h')<CR>
nnoremap <Plug>(tmuxRight) :call <SID>TmuxWinCmd('l')<CR>
nnoremap <Plug>(tmuxUp) :call <SID>TmuxWinCmd('k')<CR>
nnoremap <Plug>(tmuxDown) :call <SID>TmuxWinCmd('j')<CR>

nmap <silent> <C-h> <Plug>(tmuxLeft)
nmap <silent> <C-l> <Plug>(tmuxRight)
nmap <silent> <C-k> <Plug>(tmuxUp)
nmap <silent> <C-j> <Plug>(tmuxDown)
