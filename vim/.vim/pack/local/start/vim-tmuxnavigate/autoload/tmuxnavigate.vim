function! s:VimNavigate(direction) abort
  try
    execute 'wincmd ' . a:direction
  catch
    echohl ErrorMsg | echo 'E11: Invalid in command-line window; <CR> executes, CTRL-C quits: wincmd k' | echohl None
  endtry
endfunction

" Like `wincmd` but also change tmux panes instead of vim windows when needed.
function! tmuxnavigate#TmuxWinCmd(direction) abort
  if $TMUX !=? ''
    call s:TmuxAwareNavigate(a:direction)
  else
    call s:VimNavigate(a:direction)
  endif
endfunction

function! s:TmuxAwareNavigate(direction) abort
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


