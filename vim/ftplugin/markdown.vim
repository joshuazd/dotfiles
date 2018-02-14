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

function! s:toggleTaskRange(type, ...) abort
  if a:0
    let [line1, line2] = [a:type, a:1]
  else
    let [line1, line2] = [line("'["), line("']")]
  endif
  for line in range(line1, line2)
    call <SID>toggleTask(line)
  endfor
endfunction

nnoremap <silent> <Plug>(MDtoggleTaskLine) :call <SID>toggleTask(line('.'))<CR>
xnoremap <silent> <Plug>(MDtoggleTask) :<C-u>call <SID>toggleTaskRange(line("'<"), line("'>"))<CR>
nnoremap <silent> <Plug>(MDtoggleTask) :<C-u>set operatorfunc=<SID>toggleTaskRange<CR>g@
if !hasmapto('<Plug>(MDtoggleTask)', 'n')
  nmap gxx <Plug>(MDtoggleTaskLine)
endif
if !hasmapto('<Plug>(MDtoggleTaskOp)', 'n')
  nmap gx <Plug>(MDtoggleTask)
endif
if !hasmapto('<Plug>(MDtoggleTask)', 'v')
  xmap gx <Plug>(MDtoggleTask)
endif
