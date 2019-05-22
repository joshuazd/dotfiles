function! marks#marks() abort
  redir => message
  silent! execute 'marks'
  redir END
  vnew
  silent! setlocal buftype=nofile bufhidden=wipe nobuflisted filetype=
  put! =message
  wincmd p
  keepjumps normal! mz999zh`z
  redraw!
  echom '`'
  let m = nr2char(getchar())
  execute 'normal! `' . m
  wincmd p | close
  keepjumps normal! mz999zh`z
  delmarks z
endfunction
