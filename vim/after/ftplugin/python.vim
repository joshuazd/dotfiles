setlocal foldmethod=indent
if exists(':JediDebugInfo')
  setlocal omnifunc=jedi#completions
else
  setlocal omnifunc=python3complete#Complete
  inoremap <buffer> <silent> . .<C-x><C-o>
endif
command! Lint cexpr system('flake8 ' . shellescape(expand('%')))
setlocal makeprg=flake8\ %:S
setlocal errorformat=%f:%l:%c:\ %t%n\ %m
setlocal formatprg=autopep8\ -a\ -a\ -
command! -bar Fix silent execute "!autopep8 -i -a -a %" | redraw!
augroup PYTHON
    autocmd!
    if executable('flake8')
      autocmd BufWritePost *.py silent! make|cwindow|redraw!
    endif
augroup END
let g:jedi#goto_command = ',d'
let g:jedi#rename_command = ',r'

" ipython setup {{{

    " nmap  <buffer> <silent> <F10>       <Plug>(IPython-RunFile)
    " nmap  <buffer> <silent> ,d          <Plug>(IPython-OpenPyDoc)
    " nmap  <buffer> <silent> ,l          <Plug>(IPython-UpdateShell)
    " nmap  <buffer> <silent> <C-Return>  <Plug>(IPython-RunFile)
    " nmap  <buffer> <silent> ,s          <Plug>(IPython-RunLine)
    " nmap  <buffer> <silent> <Esc>s      <Plug>(IPython-RunLineAsTopLevel)
    " xmap  <buffer> <silent> ,s          <Plug>(IPython-RunLines)

" }}}

