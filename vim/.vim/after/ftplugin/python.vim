if executable('pylsp') && exists(':Packadd') && &filetype ==? 'python'
  silent! nunmap K
  silent! xunmap K
  Packadd vim-lsc
  nnoremap <buffer> gd :LSClientGoToDefinition<CR>
  nnoremap <C-LeftMouse> :LSClientGoToDefinition<CR>
  nnoremap <buffer> <C-w>d :LSClientGoToDefinitionSplit<CR>
  nnoremap <buffer> <C-w><C-d> :LSClientGoToDefinitionSplit<CR>
  nnoremap <buffer> gr :LSClientFindReferences<CR>
  nnoremap <buffer> gI :LSClientFindImplementations<CR>
  nnoremap <buffer> ga :LSClientFindCodeActions<CR>
  nnoremap <buffer> gR :LSClientRename<CR>
  nnoremap <buffer> go :LSClientDocumentSymbol<CR>
  nnoremap <buffer> gS :LSClientWorkspaceSymbol<CR>
  nnoremap <buffer> <C-m> :LSClientSignatureHelp<CR>
  setlocal keywordprg=:LSClientShowHover
  setlocal omnifunc=lsc#complete#complete

endif

setlocal path-=**
setlocal foldmethod=indent
setlocal keywordprg=pydoc3
setlocal makeprg=flake8\ %:S
setlocal errorformat=%f:%l:%c:\ %t%n\ %m
setlocal formatprg=autopep8\ -a\ -a\ -
command! -bar Fix silent execute "!autopep8 -i -a -a %" | redraw!
setlocal foldlevel=4
setlocal foldnestmax=4
" augroup PYTHON
"     autocmd!
"     if executable('flake8')
"       autocmd BufWritePost <buffer> silent! make|cwindow|redraw!
"     endif
" augroup END
" let b:ale_linters = ['pylsp']
let b:ale_fixers = ['autopep8', 'autoimport']

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
