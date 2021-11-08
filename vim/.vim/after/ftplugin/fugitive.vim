nnoremap <buffer> gp :Gpush<CR>
setl signcolumn=no
setl nolist

if &background ==? 'light'
  hi FugitiveDiffLine ctermbg=8 ctermfg=0 guibg=#777467 guifg=#45403a cterm=bold gui=bold
  hi FugitiveDiffHunk ctermbg=7 guibg=#999483
else
  hi FugitiveDiffLine ctermbg=238 ctermfg=248 guibg=#444444 guifg=#a8a8a8
  hi FugitiveDiffHunk ctermbg=234 guibg=#1c1c1c
endif
sign define diffline   linehl=FugitiveDiffLine
sign define diffhunk   linehl=FugitiveDiffHunk
sign define diffadd    linehl=DiffAdded
sign define diffremove linehl=DiffRemoved

function! s:highlight() abort
  exe 'sign unplace * buffer='.bufnr('%')
  for lnum in range(1, line('$'))
    if getline(lnum) =~# '^\%([A-Za-z?@]\|$\)'
      let in_hunk = 0
    endif
    if in_hunk
        exe 'sign place '.lnum.' line='.lnum.' name=diffhunk'
      " if getline(lnum) =~# '^+'
      "   exe 'sign place '.lnum.' line='.lnum.' name=diffadd'
      " elseif getline(lnum) =~# '^-'
      "   exe 'sign place '.lnum.' line='.lnum.' name=diffremove'
      " else
      "   exe 'sign place '.lnum.' line='.lnum.' name=diffhunk'
      " endif
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
  exe "norm gg\<C-n>"
  nmap <buffer> <TAB> =
endif
