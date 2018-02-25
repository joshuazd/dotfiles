function! functions#TrimWhiteSpace() abort
  if !&binary && &filetype !=? 'diff'
    let l:save = winsaveview()
    " vint: -ProhibitCommandRelyOnUser -ProhibitCommandWithUnintendedSideEffect
    keeppatterns %s/\s\+$//e
    " vint: +ProhibitCommandRelyOnUser +ProhibitCommandWithUnintendedSideEffect
    call winrestview(l:save)
  endif
endfunction

function! functions#ToggleSettings(setting) abort
  if type(a:setting) == v:t_string
    if execute('set ' . a:setting . '?') =~? 'no'
      return a:setting
    else
      return 'no' . a:setting
    endif
  elseif type(a:setting) == v:t_list
    let l:result = ''
    for s in a:setting
      if execute('set ' . s . '?') =~? 'no'
        let l:result .= s . ' '
      else
        let l:result .= 'no' . s . ' '
      endif
    endfor
    return l:result
  else
    return a:setting
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
