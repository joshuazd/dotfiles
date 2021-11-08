setlocal makeprg=pdflatex\ %

augroup Latex
  autocmd!
  if exists(':Make')
    autocmd BufWritePost <buffer> Make!
  endif
augroup END
