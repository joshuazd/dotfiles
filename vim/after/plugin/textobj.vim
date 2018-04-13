if exists('*textobj#user#plugin')

  call textobj#user#plugin('xmlattr', {
        \ 'attr-i': {
        \   'pattern': '\(\([a-zA-Z0-9\-_:@.]\+\)\(=\(\(".\{-}"\)\|\(\w\+\)\)\)\=\)',
        \   'select': 'ix',
        \ },
        \ 'attr-a': {
        \   'pattern': '\s\+\(\([a-zA-Z0-9\-_:@.]\+\)\(=\(\(".\{-}"\)\|\(\w\+\)\)\)\=\)',
        \   'select': 'ax',
        \ }})

endif
