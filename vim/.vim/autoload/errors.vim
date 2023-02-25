function! errors#statusline() abort
  if len(getqflist()) == 0
    return ''
  else
    return '【'.len(getqflist()).'】'
  endif
endfunction
