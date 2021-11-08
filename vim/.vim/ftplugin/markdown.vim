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
  if a:0 " Invoked from visual mode
    let [line1, line2] = [line("'<"), line("'>")]
  else
    let [line1, line2] = [line("'["), line("']")]
  endif
  for line in range(line1, line2)
    call <SID>toggleTask(line)
  endfor
endfunction

nnoremap <silent> <Plug>(MDtoggleTaskLine) :call <SID>toggleTask(line('.'))<CR>
xnoremap <silent> <Plug>(MDtoggleTask) :<C-u>call <SID>toggleTaskRange(visualmode(), 1)<CR>
nnoremap <silent> <Plug>(MDtoggleTask) :set operatorfunc=<SID>toggleTaskRange<CR>g@
if !hasmapto('<Plug>(MDtoggleTask)', 'n')
  nmap <buffer> gcc <Plug>(MDtoggleTaskLine)
endif
if !hasmapto('<Plug>(MDtoggleTaskOp)', 'n')
  nmap <buffer> gc <Plug>(MDtoggleTask)
endif
if !hasmapto('<Plug>(MDtoggleTask)', 'v')
  xmap <buffer> gc <Plug>(MDtoggleTask)
endif


function! s:MDindent(dir) abort
  execute 'normal! ' . a:dir
  let l:char = getline('.')[col('.')-1]
  if l:char ==? '-'
    normal! ^r*$
  else
    normal! ^r-$
  endif
  if getline('.')[col('$')-2] !=? ' '
    normal! A 
  endif
  startinsert!
endfunction
inoremap <buffer> ;l <esc>:call <SID>MDindent('>>')<CR>
inoremap <buffer> ;h <esc>:call <SID>MDindent('<<')<CR>
