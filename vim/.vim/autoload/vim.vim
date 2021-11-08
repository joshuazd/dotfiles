function! vim#VimRefresh() abort
  silent! GutentagsUpdate!
  silent! SignifyRefresh
  redraw!
  syntax sync fromstart
  echo 'Vim is refreshed'
endfunction

function! vim#Focus() abort
  if exists('g:focus_enabled') && g:focus_enabled == 1
    let &laststatus = g:old_laststatus
    set noshowmode
    if executable('tmux') && $TMUX !=? ''
      silent! !tmux resize-pane -Z
      silent! !tmux set status on
    endif
    let g:focus_enabled = 0
  else
    let g:focus_enabled = 1
    let g:old_laststatus = &laststatus
    set laststatus=0
    set showmode
    if executable('tmux') && $TMUX !=? ''
      silent! !tmux resize-pane -Z
      silent! !tmux set status off
    endif
  endif
endfunction
