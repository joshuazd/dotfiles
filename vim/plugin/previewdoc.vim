nnoremap <Plug>(PreviewDoc) :call previewdoc#PreviewDoc('<C-R>=&keywordprg<CR>','<C-R><C-w>')<CR>
xnoremap <Plug>(PreviewDoc) "ay:call previewdoc#PreviewDoc('<C-R>=&keywordprg<CR>','<C-R>a')<CR>
if !hasmapto('<Plug>(PreviewDoc)','n')
  nmap K <Plug>(PreviewDoc)
endif
if !hasmapto('<Plug>(PreviewDoc)','v')
  xmap K <Plug>(PreviewDoc)
endif
