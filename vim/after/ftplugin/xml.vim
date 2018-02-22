setlocal shiftwidth=2
setlocal tabstop=2
setlocal softtabstop=2
setlocal foldmethod=syntax
setlocal smarttab
setlocal conceallevel=0
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
setlocal path=.,*/src/main/synapse-config/*/,*/src/main/dataservice/,*_DataMapper/
set suffixesadd+=.xml
setlocal isfname-=/
nnoremap ,f zMza
xmap ai <Plug>IndentMotionAround
xmap aI <Plug>IndentMotionUpper
omap ai <Plug>IndentMotionAround
omap aI <Plug>IndentMotionUpper
augroup XML
    autocmd!
    if executable('xmllint')
      autocmd BufWritePost *.xml,*.dbs silent! make|cwindow|redraw!
    endif
augroup END
