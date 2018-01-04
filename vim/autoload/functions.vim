function! functions#TrimWhiteSpace()
  if !&binary && &filetype !=? 'diff'
    let l:save = winsaveview()
    " vint: -ProhibitCommandRelyOnUser -ProhibitCommandWithUnintendedSideEffect
    %s/\s\+$//e
    " vint: +ProhibitCommandRelyOnUser +ProhibitCommandWithUnintendedSideEffect
    call winrestview(l:save)
  endif
endfunction

function! functions#VimGrepAll(pattern) abort
  call setqflist([])
  exe 'bufdo silent vimgrepadd ' . a:pattern . ' %'
  cwindow
  exe 'normal '
endfunction

function! functions#ToggleConceal()
    if &conceallevel == 0
        set conceallevel=2
    else
        set conceallevel=0
    endif
endfunction

function! functions#VimRefresh()
    ALEToggle
    ALEToggle
    GitGutterToggle
    GitGutterToggle
    NeoCompleteClean
    NeoCompleteBufferMakeCache
    NeoCompleteMemberMakeCache
    if &filetype ==? 'java'
        JCcacheClear
    endif
endfunction
