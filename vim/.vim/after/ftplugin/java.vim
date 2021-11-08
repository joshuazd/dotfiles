command! -buffer Test edit src/test/**/%:t:rTest.java
compiler ant
setlocal makeprg=mvn\ package\ -e\ -ff
setlocal path=.,./..,src/main/resources/META-INF/
setlocal foldmarker={,}
setlocal define=\\s*\\%(\\%(public\\\|private\\\|protected\\\|static\\\|abstract\\\|final\\)\\s*\\)\\+\\%(void\\\|int\\\|short\\\|long\\\|byte\\\|float\\\|double\\\|char\\\|boolean\\\|[A-Z][a-zA-Z0-9_\\.]*\\%(<.*>\\)\\=\\)\\s*
setlocal include=^\\s*import\\s*\\%(static\\)\\=\\s*
setlocal complete-=i
if executable('java-language-server') && exists(':Packadd')
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
  MUcompleteAutoOff
endif
let b:wlsenv='/mnt/c/Users/jzinkduda/apps/wls12120/wlserver/server/bin/setWLSEnv.sh'
function! s:deploy(bang) abort
  let b:war_name = get(b:, 'war_name', 'target/'.fnamemodify(getcwd(),':t'))
  execute 'Start'.a:bang.' -wait=error source '.b:wlsenv.' && java weblogic.Deployer -deploy -source $PWD/'.b:war_name.' -adminurl t3://localhost:7001 -username '.get(b:, 'weblogic_username', 'weblogic').' -password '.get(b:, 'weblogic_password', 'webl0gic')
endfunction
function! s:build_and_deploy(bang) abort
  let b:dispatch = 'mvn compile war:manifest war:exploded -T 1C -e -ff'
  Dispatch
  unlet b:dispatch
  let g:build_bang = a:bang
  augroup finish_build
    autocmd!
      autocmd VimResized * call s:deploy(g:build_bang)
            \ | execute 'autocmd! finish_build'
            \ | augroup! finish_build
            \ | unlet g:build_bang
    augroup END
endfunction
function! s:diagnostic_popup() abort
  silent! call popup_close(b:popup)
  let diagnostic = lsc#diagnostics#underCursor()
  if !has_key(diagnostic, 'message')
    return
  endif
  let b:popup = popup_atcursor(diagnostic['message'], {'padding':[],'maxwidth':50,'col':diagnostic['range']['start']['character']})
  call setwinvar(b:popup, '&linebreak', 1)
endfunction

let g:lsc_enable_popup_syntax = v:false

" function! s:highlight_references() abort
"   " let s:pending[&filetype] = v:true
"   " let s:highlights_request += 1
"   let l:params = lsc#params#documentPosition()
"   let l:server = lsc#server#forFileType(&filetype)[0]
"   call l:server.request('textDocument/documentHighlight', l:params,
"       \ funcref('<SID>HandleHighlights',
"       \ [s:highlights_request, getcurpos(), bufnr('%'), &filetype]))
" endfunction

" silent! autocmd! LSC CursorMoved *
" augroup JavaLSC
"   autocmd!
"   if get(g:, 'loaded_lsc', 0)
"     " autocmd CursorMoved * call s:highlight_references()
"     autocmd CursorMoved * call s:diagnostic_popup()
"     autocmd BufWritePost * call s:diagnostic_popup()
"   endif
" augroup END
command! -bang Build call s:build_and_deploy('<bang>')
command! -bang Deploy call s:deploy('<bang>')
let b:surround_{char2nr('{')} = "\1block: \1 {\n".(&l:expandtab ? repeat(' ',&l:shiftwidth) : "\t")."\r\n}"
let b:surround_indent = 1
let b:undo_ftplugin = 'setlocal makeprg< path< foldmarker< define< include< complete<'
