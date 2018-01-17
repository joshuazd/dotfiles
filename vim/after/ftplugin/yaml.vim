command! Yamllint cexpr system('yamllint -f parsable ' . shellescape(expand('%')))
augroup YAML
    autocmd!
    autocmd BufWritePost *.yaml,*.yml silent Yamllint
augroup END
