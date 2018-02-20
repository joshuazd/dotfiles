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
    echo ':setlocal conceallevel=2'
    setlocal conceallevel=2
  else
    echo ':setlocal conceallevel=0'
    setlocal conceallevel=0
  endif
endfunction

function! functions#ToggleSettings(setting) abort
  if execute('set ' . a:setting . '?') =~? 'no'
    echo ':setlocal ' . a:setting
    execute('setlocal ' . a:setting)
  else
    echo ':setlocal no' . a:setting
    execute('setlocal no' . a:setting)
  endif
endfunction

function! functions#VimRefresh() abort
  GutentagsUpdate!
  redraw!
  syntax sync fromstart
  echo 'Vim is refreshed'
endfunction

function! functions#ToggleSignColumn() abort
  if &signcolumn ==? 'no'
    echo ':setlocal signcolumn=yes'
    setlocal signcolumn=yes
    GitGutterEnable
  else
    echo ':setlocal signcolumn=no'
    setlocal signcolumn=no
    GitGutterDisable
  endif
endfunction

function! functions#AnsibleEdit() abort
  silent! new
  silent! put! a
  silent! keeppatterns %s/^\s\+//
  silent! execute 'write!' fnameescape(tempname())
  silent! !cp % temp
  silent! !ansible-vault view temp >| %
  silent! !rm temp
  silent! redraw!
  echo 'Ansible vault decrypted'
endfunction

function! functions#AnsibleEncrypt() abort
  silent! set buftype=
  silent! execute 'write!' fnameescape(tempname())
  silent! !ansible-vault encrypt %
  silent! redraw!
  echo 'Ansible vault encrypted'
endfunction
