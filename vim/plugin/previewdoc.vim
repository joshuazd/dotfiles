function! PreviewDoc(prg,word) abort
  if a:prg =~? '^:'
    silent! execute a:prg.' '.a:word
    execute 'resize '.min([&hh,line('$')])
  else
    new
    silent! execute '%!'.a:prg.' '.a:word
    setl buftype=nofile bufhidden=wipe
    execute 'resize '.min([&pvh,line('$')])
  endif
  setl previewwindow
  wincmd p
endfunction

nnoremap <Plug>(PreviewDoc) :call PreviewDoc('<C-R>=&keywordprg<CR>','<C-R><C-w>')<CR>
if !hasmapto('<Plug>(PreviewDoc)','n')
  nmap K <Plug>(PreviewDoc)
endif
