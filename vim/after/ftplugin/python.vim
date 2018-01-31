setlocal foldmethod=indent
setlocal omnifunc=jedi#completions
let b:vcm_tab_complete = 'omni'
let b:vcm_omni_pattern = '\k[\k\.]\+'
imap <buffer> <silent> . .<TAB>
command! Lint cexpr system('flake8 ' . shellescape(expand('%')))
set makeprg=flake8\ %
command! -bar Fix silent execute "!autopep8 -i -a -a -a %" | redraw!
augroup PYTHON
    autocmd!
    if executable('flake8')
      autocmd BufWritePost *.py silent Lint
    endif
augroup END

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

