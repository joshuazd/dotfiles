setlocal omnifunc=javascriptcomplete#CompleteJS
setlocal path=.,*/src/main/synapse-config,*/src/main/dataservice/,*_DataMapper/,*/dataservice/,*/src/main/synapse-config/*
let b:undo_ftplugin = 'setlocal omnifunc< path<'
if executable('typescript-language-server') && exists(':Packadd')
  silent! nunmap K
  silent! xunmap K
  Packadd vim-lsc
  nnoremap <buffer> gd :LSClientGoToDefinition<CR>
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
