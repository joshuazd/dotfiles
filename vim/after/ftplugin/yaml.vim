setlocal makeprg=yamllint\ -f\ parsable\ -d\ \"{rules:\ {line-length:\ disable}}\"\ %
setlocal errorformat=%f:%l:%c:\ [%trror]\ %m,%f:%l:%c:\ [%tarning]\ %m
command! Lint cexpr system('yamllint -f parsable -d "{rules: {line-length: disable}}" ' . shellescape(expand('%')))
nnoremap <buffer> ,l :Lint<CR>
augroup YAML
    autocmd!
    if executable('yamllint')
      autocmd BufWritePost *.yaml,*.yml silent! make|cwindow|redraw!
    endif
augroup END
