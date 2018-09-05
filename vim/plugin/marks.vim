function! Marks() abort
  redir => message
  silent! execute 'marks'
  redir END
  vnew
  silent! setlocal buftype=nofile bufhidden=wipe nobuflisted
  put! =message
  wincmd p
  redraw!
  echom '`'
  let m = nr2char(getchar())
  execute 'normal! `' . m
  wincmd p | close
endfunction
nnoremap ' :call Marks()<CR>
