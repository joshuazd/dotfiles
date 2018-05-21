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
setlocal path=.,*/src/main/synapse-config/*/,*/src/main/dataservice/,*_DataMapper/
set suffixesadd+=.xml
setlocal isfname-=/
nnoremap ,f zMzr
augroup XML
    autocmd!
    if executable('xmllint')
      autocmd BufWritePost *.xml,*.dbs silent! make|cwindow|redraw!
    endif
    autocmd CursorHold,CursorHoldI,CursorMoved,InsertEnter,InsertLeave * redraw|echo FindAPI()
augroup END

nnoremap <buffer> <Space>r :echom FindAPI()<CR>
function! FindAPI() abort
  let l:resource = search('<resource', 'bn')
  let l:url = matchstr(getline(l:resource), '\%(ur[il]-\(mapping\|template\)="\)\@<=[^"]*"\@=')
  return l:url
endfunction
