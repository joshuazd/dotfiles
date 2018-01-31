setlocal shiftwidth=2
setlocal tabstop=2
setlocal softtabstop=2
setlocal foldmethod=syntax
setlocal smarttab
setlocal conceallevel=0
setlocal wrap
setlocal foldnestmax=2
let g:xml_syntax_folding=1 " enable xml folding
inoremap <buffer> </ </<C-x><C-o><C-n><C-y>
command! Tabs setlocal shiftwidth=2 softtabstop=2 foldmethod=syntax smarttab
command! Lint cexpr system('xmllint --noout ' . shellescape(expand('%')))
compiler ant
setlocal omnifunc=xmlcomplete#CompleteTags
setlocal makeprg=mvn\ clean\ install\ -e\ -ff\ -T\ 16\ -q
setlocal syntax=xml
setlocal path=.,*/src/main/synapse-config/*/
setlocal suffixesadd+=.xml
setlocal breakindentopt=shift:4
nnoremap ,f zMza
augroup XML
    autocmd!
    if executable('xmllint')
      autocmd BufWritePost *.xml,*.dbs silent Lint
    endif
augroup END
