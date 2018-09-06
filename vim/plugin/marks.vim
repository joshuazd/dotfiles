function! Marks() abort
  redir => message
  silent! execute 'marks'
  redir END
  vnew
  silent! setlocal buftype=nofile bufhidden=wipe nobuflisted
  put! =message
  wincmd p
  normal! 999zh
  redraw!
  echom '`'
  let m = nr2char(getchar())
  execute 'normal! `' . m
  wincmd p | close
  normal! 999zh
endfunction
nnoremap ' :call Marks()<CR>
