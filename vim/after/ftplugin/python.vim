setlocal foldmethod=indent
setlocal omnifunc=jedi#completions
command! Lint cexpr system('flake8 ' . shellescape(expand('%')))
set makeprg=flake8\ %:S
set errorformat=%f:%l:%c:\ %t%n\ %m
command! -bar Fix silent execute "!autopep8 -i -a -a -a %" | redraw!
augroup PYTHON
    autocmd!
    if executable('flake8')
      autocmd BufWritePost *.py silent! make|cwindow|redraw!
    endif
augroup END
let g:jedi#goto_command = ',d'

" ipython setup {{{

    nmap  <buffer> <silent> <F10>       <Plug>(IPython-RunFile)
    " nmap  <buffer> <silent> ,d          <Plug>(IPython-OpenPyDoc)
    nmap  <buffer> <silent> ,r          <Plug>(IPython-UpdateShell)
    nmap  <buffer> <silent> <C-Return>  <Plug>(IPython-RunFile)
    nmap  <buffer> <silent> ,s          <Plug>(IPython-RunLine)
    nmap  <buffer> <silent> <Esc>s      <Plug>(IPython-RunLineAsTopLevel)
    xmap  <buffer> <silent> ,s          <Plug>(IPython-RunLines)

" }}}

