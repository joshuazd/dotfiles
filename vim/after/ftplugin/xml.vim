setlocal shiftwidth=2
setlocal tabstop=2
setlocal softtabstop=2
setlocal foldmethod=syntax
setlocal smarttab
setlocal conceallevel=0
set foldnestmax=2
let g:xml_syntax_folding=1 " enable xml folding
inoremap <buffer> </ </<C-x><C-o><C-y>
command! Tabs setlocal shiftwidth=2 softtabstop=2 foldmethod=syntax smarttab
command! Xmllint cexpr system('xmllint ' . shellescape(expand('%')))
compiler ant
setlocal omnifunc=xmlcomplete#CompleteTags
setlocal makeprg=mvn\ install\ -e\ -ff\ -T\ 16
set syntax=xml
set path=.,*/src/main/synapse-config/**/
nnoremap ,f zMza
augroup XML
    autocmd!
    autocmd BufWritePost *.xml,*.dbs silent Xmllint
augroup END
