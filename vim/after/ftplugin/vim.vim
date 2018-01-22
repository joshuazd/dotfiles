setlocal shiftwidth=2
setlocal foldmethod=marker foldlevel=0
setlocal makeprg=vint\ %
setlocal keywordprg=:help
command! Vimlint cexpr system('vint ' . shellescape(expand('%')))
augroup VIM
    autocmd!
    if executable('vint')
      autocmd BufWritePost *.vim,.vimrc,vimrc silent Vimlint
    endif
augroup END

