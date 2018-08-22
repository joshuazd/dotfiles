setlocal shiftwidth=2
setlocal softtabstop=2
setlocal foldmethod=marker
setlocal makeprg=vint\ %:S
setlocal keywordprg=:help
setlocal errorformat=%f:%l:%c:\ %t%n:\ %m,%f:%l:%c:\ %m
setlocal path=.,$HOME/dotfiles/vim/*,$HOME/dotfiles/vim/after/*,,
setlocal suffixesadd+=.vim

" Move around functions.
nnoremap <silent><buffer> [m m':call search('^\s*fu\%[nction]\>', "bW")<CR>
xnoremap <silent><buffer> [m m':<C-U>exe "normal! gv"<Bar>call search('^\s*fu\%[nction]\>', "bW")<CR>
nnoremap <silent><buffer> ]m m':call search('^\s*fu\%[nction]\>', "W")<CR>
xnoremap <silent><buffer> ]m m':<C-U>exe "normal! gv"<Bar>call search('^\s*fu\%[nction]\>', "W")<CR>
nnoremap <silent><buffer> [M m':call search('^\s*endf*\%[unction]\>', "bW")<CR>
xnoremap <silent><buffer> [M m':<C-U>exe "normal! gv"<Bar>call search('^\s*endf*\%[unction]\>', "bW")<CR>
nnoremap <silent><buffer> ]M m':call search('^\s*endf*\%[unction]\>', "W")<CR>
xnoremap <silent><buffer> ]M m':<C-U>exe "normal! gv"<Bar>call search('^\s*endf*\%[unction]\>', "W")<CR>

augroup VIM
    autocmd!
    if executable('vint')
      autocmd BufWritePost *.vim,.vimrc,vimrc silent! make|cwindow|redraw!
    endif
augroup END
