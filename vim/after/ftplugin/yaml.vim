command! Lint cexpr system('yamllint -f parsable ' . shellescape(expand('%')))
nnoremap <buffer> ,l :Lint<CR>
augroup YAML
    autocmd!
    if executable('yamllint')
      autocmd BufWritePost *.yaml,*.yml silent Lint
    endif
augroup END
