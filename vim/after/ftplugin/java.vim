compiler ant
setlocal makeprg=mvn\ install\ -e\ -ff\ -q
setlocal path=.,src/main/java/com/panera/*/,src/main/java/
setlocal foldmarker={,}
setlocal define=\\s*\\%(\\%(public\\\|private\\\|protected\\\|static\\\|abstract\\\|final\\)\\s*\\)\\+\\%(void\\\|int\\\|short\\\|long\\\|byte\\\|float\\\|double\\\|char\\\|boolean\\\|[A-Z][a-zA-Z0-9_\\.]*\\%(<.*>\\)\\=\\)\\s*
setlocal include=^\\s*import\\s*\\%(static\\)\\=\\s*
setlocal complete-=i
augroup JAVA
  autocmd!
  " autocmd User lsp_setup call lsp#register_server({'name':'jdt.ls','cmd':{server_info->['java-language-server']},'whitelist':['java']})
  " autocmd BufWritePost *.java silent LspDocumentDiagnostics
augroup END
" if executable('java-language-server')
"   setlocal omnifunc=lsp#complete
"   nnoremap <buffer> gd :LspDefinition<CR>
"   nnoremap <buffer> ,r :LspRename<CR>
"   nnoremap <buffer> ,a :LspCodeAction<CR>
" endif
nnoremap <buffer> <silent> K :call LanguageClient#textDocument_hover()<CR>
nnoremap <buffer> <silent> gd :call LanguageClient#textDocument_definition()<CR>
nnoremap <buffer> <silent> <F2> :call LanguageClient#textDocument_rename()<CR>
