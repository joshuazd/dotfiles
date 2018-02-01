function! functions#TrimWhiteSpace() abort
  if !&binary && &filetype !=? 'diff'
    let l:save = winsaveview()
    " vint: -ProhibitCommandRelyOnUser -ProhibitCommandWithUnintendedSideEffect
    keeppatterns %s/\s\+$//e
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

function! functions#ToggleConceal() abort
  if &conceallevel == 0
    echo 'set conceallevel=2'
    set conceallevel=2
  else
    echo 'set conceallevel=0'
    set conceallevel=0
  endif
endfunction

function! functions#VimRefresh() abort
  GutentagsUpdate!
  redraw!
  syntax sync fromstart
endfunction

function! functions#ToggleSignColumn() abort
  if &signcolumn ==? 'no'
    echo 'set signcolumn=yes'
    set signcolumn=yes
    GitGutterEnable
  else
    echo 'set signcolumn=no'
    set signcolumn=no
    GitGutterDisable
  endif
endfunction

