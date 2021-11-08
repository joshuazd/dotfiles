function! whitespace#TrimWhiteSpace() abort
  if !&binary && &filetype !=? 'diff'
    let save = winsaveview()
    " vint: -ProhibitCommandRelyOnUser -ProhibitCommandWithUnintendedSideEffect
    keeppatterns %s/\s\+$//e
    " vint: +ProhibitCommandRelyOnUser +ProhibitCommandWithUnintendedSideEffect
    call winrestview(save)
  endif
endfunction
