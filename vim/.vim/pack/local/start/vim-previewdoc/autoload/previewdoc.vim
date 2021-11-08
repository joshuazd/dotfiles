function! previewdoc#PreviewDoc(prg,word) abort
  if a:prg =~? '^:'
    silent! execute a:prg.' '.a:word
    execute 'resize '.min([&hh,line('$')])
  else
    new
    silent! execute '%!'.a:prg.' '.a:word
    setl buftype=nofile bufhidden=wipe
    execute 'resize '.min([&pvh,line('$')])
  endif
  silent! setl previewwindow
  wincmd p
endfunction
