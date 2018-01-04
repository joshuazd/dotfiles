setlocal shiftwidth=2
setlocal tabstop=2
setlocal softtabstop=2
" setlocal noexpandtab
setlocal foldmethod=syntax
setlocal smarttab
set foldnestmax=2
let g:xml_syntax_folding=1 " enable xml folding
inoremap </ </<C-x><C-o><C-y>
command! Tabs setlocal shiftwidth=2 softtabstop=2 foldmethod=syntax smarttab
setlocal omnifunc=xmlcomplete#CompleteTags
