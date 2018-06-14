setlocal shiftwidth=2
setlocal softtabstop=2
setlocal foldmethod=indent
setlocal smarttab
setlocal conceallevel=0
setlocal foldnestmax=2
setlocal iskeyword+=-
inoremap <buffer> </ </<C-x><C-o><C-n><C-y>
nnoremap <buffer> { ?<[^\/]\+><CR>
nnoremap <buffer> } /<[^\/]\+><CR>
command! Tabs setlocal shiftwidth=2 softtabstop=2 foldmethod=syntax smarttab
setlocal omnifunc=xmlcomplete#CompleteTags
compiler xmllint
setlocal makeprg=xmllint\ --noout\ %:S
setlocal formatprg=xmllint\ --format\ -
setlocal syntax=xml
setlocal path=.,*/src/main/synapse-config/*/,*/src/main/dataservice/,*_DataMapper/,*/dataservice/
set suffixesadd+=.xml,.dbs
setlocal isfname-=/
nnoremap ,f zMzr
augroup XML
    autocmd!
    if executable('xmllint')
      autocmd BufWritePost *.xml,*.dbs silent! make|cwindow|redraw!
    endif
augroup END
