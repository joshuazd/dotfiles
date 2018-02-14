function! s:toggleTask(line) abort
  let l:match = matchstr(getline(a:line), '\[ \]')
  if len(l:match)
    call setline(a:line, substitute(getline(a:line), '\[ \]', '\[x\]', ''))
  else
    let l:match = matchstr(getline(a:line), '\[x\]')
    if len(l:match)
      call setline(a:line, substitute(getline(a:line), '\[x\]', '\[ \]', ''))
    endif
  endif
endfunction

nnoremap <silent> <Plug>(MDtoggleTask)  :call <SID>toggleTask(line('.'))<CR>
if !hasmapto('<Plug>(MDtoggleTask)')
  nmap ,x <Plug>(MDtoggleTask)
endif
