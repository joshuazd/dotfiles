setlocal shiftwidth=2
setlocal tabstop=2
setlocal softtabstop=2
setlocal foldmethod=syntax
setlocal smarttab
setlocal conceallevel=0
setlocal wrap
set foldnestmax=2
let g:xml_syntax_folding=1 " enable xml folding
inoremap <buffer> </ </<C-x><C-o><C-y>
command! Tabs setlocal shiftwidth=2 softtabstop=2 foldmethod=syntax smarttab
command! Xmllint cexpr system('xmllint --noout ' . shellescape(expand('%')))
compiler ant
setlocal omnifunc=xmlcomplete#CompleteTags
setlocal makeprg=mvn\ clean\ install\ -e\ -ff\ -T\ 16
set syntax=xml
set path=.,*/src/main/synapse-config/**/
set suffixesadd+=.xml
nnoremap ,f zMza
augroup XML
    autocmd!
    if executable('xmllint')
      autocmd BufWritePost *.xml,*.dbs silent Xmllint
    endif
augroup END
