setlocal foldmethod=indent
if exists(':JediDebugInfo')
  setlocal omnifunc=jedi#completions
  nunmap <buffer> K
else
  setlocal omnifunc=python3complete#Complete
endif
setlocal keywordprg=pydoc3
setlocal makeprg=flake8\ %:S
setlocal errorformat=%f:%l:%c:\ %t%n\ %m
setlocal formatprg=autopep8\ -a\ -a\ -
command! -bar Fix silent execute "!autopep8 -i -a -a %" | redraw!
setlocal foldlevel=4
setlocal foldnestmax=4
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

let b:undo_ftplugin = 'setlocal omnifunc< foldmethod< keywordprg< makeprg< errorformat< formatprg< foldlevel< foldnestmax<'
