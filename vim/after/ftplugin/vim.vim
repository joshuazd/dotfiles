setlocal shiftwidth=2
setlocal softtabstop=2
setlocal foldmethod=marker
setlocal makeprg=vint\ %
setlocal keywordprg=:help
command! Lint cexpr system('vint ' . shellescape(expand('%')))
setlocal errorformat=%f:%l:%c:\ %t%n:\ %m,%f:%l:%c:\ %m
augroup VIM
    autocmd!
    if executable('vint')
      autocmd BufWritePost *.vim,.vimrc,vimrc silent! make|cwindow|redraw!
    endif
augroup END

