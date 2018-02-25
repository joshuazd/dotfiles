function! functions#TrimWhiteSpace() abort
  if !&binary && &filetype !=? 'diff'
    let l:save = winsaveview()
    " vint: -ProhibitCommandRelyOnUser -ProhibitCommandWithUnintendedSideEffect
    keeppatterns %s/\s\+$//e
    " vint: +ProhibitCommandRelyOnUser +ProhibitCommandWithUnintendedSideEffect
    call winrestview(l:save)
  endif
endfunction

function! functions#VimRefresh() abort
  if exists('g:loaded_gutentags') && g:loaded_gutentags == 1
    GutentagsUpdate!
  endif
  redraw!
  syntax sync fromstart
  echo 'Vim is refreshed'
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
