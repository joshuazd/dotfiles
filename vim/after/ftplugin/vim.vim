setlocal shiftwidth=2
setlocal softtabstop=2
setlocal foldmethod=marker
setlocal makeprg=vint\ %
setlocal keywordprg=:help
command! Lint cexpr system('vint ' . shellescape(expand('%')))
nnoremap <buffer> ,l :Lint<CR>
augroup VIM
    autocmd!
    if executable('vint')
      autocmd BufWritePost *.vim,.vimrc,vimrc silent Lint
    endif
augroup END

