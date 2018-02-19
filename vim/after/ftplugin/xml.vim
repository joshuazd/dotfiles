setlocal shiftwidth=2
setlocal tabstop=2
setlocal softtabstop=2
setlocal foldmethod=syntax
setlocal smarttab
setlocal conceallevel=0
setlocal wrap
setlocal foldnestmax=2
setlocal iskeyword+=-
let g:xml_syntax_folding=1 " enable xml folding
inoremap <buffer> </ </<C-x><C-o><C-n><C-y>
command! Tabs setlocal shiftwidth=2 softtabstop=2 foldmethod=syntax smarttab
command! Lint cexpr system('xmllint --noout ' . shellescape(expand('%')))
setlocal omnifunc=xmlcomplete#CompleteTags
compiler xmllint
setlocal makeprg=xmllint\ --noout\ %:S
setlocal syntax=xml
setlocal path=.,*/src/main/synapse-config/*/,*/src/main/dataservice/
setlocal suffixesadd+=.xml
setlocal breakindentopt=shift:4
nnoremap ,f zMza
augroup XML
    autocmd!
    if executable('xmllint')
      autocmd BufWritePost *.xml,*.dbs silent! make|cwindow|redraw!
    endif
augroup END
