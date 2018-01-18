setlocal foldmethod=marker foldlevel=0
setlocal makeprg=vint\ %
setlocal keywordprg=:help
command! Vimlint cexpr system('vint ' . shellescape(expand('%')))
augroup VIM
    autocmd!
    autocmd BufWritePost *.vim,.vimrc,vimrc silent Vimlint
augroup END

