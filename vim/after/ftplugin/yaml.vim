command! Yamllint cexpr system('yamllint -f parsable ' . shellescape(expand('%')))
augroup YAML
    autocmd!
    if executable('yamllint')
      autocmd BufWritePost *.yaml,*.yml silent Yamllint
    endif
augroup END
