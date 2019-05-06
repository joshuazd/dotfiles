if exists('g:loaded_previewdoc')
  finish
endif
let g:loaded_previewdoc = 1

let s:save_cpo = &cpo
set cpo&vim

nnoremap <silent> <Plug>(PreviewDoc) :call previewdoc#PreviewDoc('<C-R>=&keywordprg<CR>','<C-R><C-w>')<CR>
xnoremap <silent> <Plug>(PreviewDoc) "ay:call previewdoc#PreviewDoc('<C-R>=&keywordprg<CR>','<C-R>a')<CR>
if !hasmapto('<Plug>(PreviewDoc)','n')
  nmap K <Plug>(PreviewDoc)
endif
if !hasmapto('<Plug>(PreviewDoc)','v')
  xmap K <Plug>(PreviewDoc)
endif

let &cpo = s:save_cpo
unlet s:save_cpo
