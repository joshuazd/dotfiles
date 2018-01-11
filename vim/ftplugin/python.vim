setlocal foldmethod=indent
setlocal omnifunc=jedi#completions

" Jedi setup {{{
    let g:jedi#show_call_signatures = 2
" }}}

" ipython setup {{{
  let g:ipy_perform_mappings = 0 "make our own mappings

    nmap  <buffer> <silent> <F10>          <Plug>(IPython-RunFile)
    nmap  <buffer> <silent> <LocalLeader>d <Plug>(IPython-OpenPyDoc)
    nmap  <buffer> <silent> <LocalLeader>r <Plug>(IPython-UpdateShell)
    nmap  <buffer> <silent> <C-Return>     <Plug>(IPython-RunFile)
    nmap  <buffer> <silent> <LocalLeader>s <Plug>(IPython-RunLine)
    nmap  <buffer> <silent> <Esc>s         <Plug>(IPython-RunLineAsTopLevel)
    xmap  <buffer> <silent> <LocalLeader>s <Plug>(IPython-RunLines)

" }}}

