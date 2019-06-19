nnoremap <buffer> gp :Gpush<CR>
setl signcolumn=no

hi FugitiveDiffLine ctermbg=238 ctermfg=248 guibg=#444444 guifg=#a8a8a8
hi FugitiveDiffHunk ctermbg=234 guibg=#1c1c1c
sign define diffline linehl=FugitiveDiffLine
sign define diffhunk linehl=FugitiveDiffHunk

function! s:highlight() abort
  exe 'sign unplace * buffer='.bufnr('%')
  for lnum in range(1, line('$'))
    if getline(lnum) =~# '^\%([A-Za-z?@]\|$\)'
      let in_hunk = 0
    endif
    if in_hunk
      exe 'sign place '.lnum.' line='.lnum.' name=diffhunk'
    elseif getline(lnum) =~# '^\%(@@ -\)'
      exe 'sign place '.lnum.' line='.lnum.' name=diffline'
      let in_hunk = 1
    endif
  endfor
endfunction
augroup FugitiveHighlight
  autocmd!
  autocmd TextChanged <buffer> call <SID>highlight()
augroup END
if expand('%') =~# '\.git\/index'
  exe "norm \<C-n>"
  nmap <buffer> <TAB> =
endif
