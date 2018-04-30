setlocal shiftwidth=2
setlocal softtabstop=2
setlocal foldmethod=marker
setlocal makeprg=vint\ %:S
setlocal keywordprg=:help
setlocal errorformat=%f:%l:%c:\ %t%n:\ %m,%f:%l:%c:\ %m
setlocal path=.,$HOME/dotfiles/vim/*,$HOME/dotfiles/vim/after/*,$HOME/dotfiles/vim/bundle/**,,
setlocal suffixesadd+=.vim
augroup VIM
    autocmd!
    if executable('vint')
      autocmd BufWritePost *.vim,.vimrc,vimrc silent! make|cwindow|redraw!
    endif
augroup END
