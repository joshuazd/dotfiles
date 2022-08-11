if executable('solargraph') && exists(':Packadd') && &filetype ==? 'ruby'
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

setlocal tags+=$HOME/.rbenv/versions/2.7.6/lib/ruby/gems/2.7.0/gems/tags
setlocal foldmethod=syntax
setlocal suffixesadd+=.html.erb
let b:dispatch='bundle exec standardrb --format emacs --no-color %:S'
let b:ale_fixers = ['standardrb']

" let b:endstart = '\(^\|\n\)\(.*=\)\?\s*\%(private\s\+\|protected\s\+\|public\s\+\|module_function\s\+\)*\zs\%(module\|class\|def\|if\|unless\|case\|while\|until\|for\|begin\)\>\%(.*[^.:@$]\<end\>\)\@!\|\<do\ze\%(\s*|.*|\)\=\s*'
let b:endstart = '\(^\|\n\)\(.*=\)\?\s*\%(private\s\+\|protected\s\+\|public\s\+\|module_function\s\+\)*\zs\%(module\|class\|def\|if\|unless\|case\|while\|until\|for\|begin\)\>\|\<do\ze\%(\s*|.*|\)\=\s*'
let b:endend = '\(^\|\n\)\s*\zsend\ze\s*'
let b:funcstart = '\(^\|\n\)\(.*=\)\?\s*\%(private\s\+\|protected\s\+\|public\s\+\|module_function\s\+\)*\%(module\|class\|def\|\)\>\s*\zs[A-Za-z0-9_.?]*\ze'

function! ruby#FindFunc() abort
  " find most recent function
  let function_line = search(b:funcstart, 'bnWc')
  let [bufnum, lnum, col, off] = getpos('.')
  let search_range = join(getline(function_line, lnum - 1), "\n")
  let starts = []
  let ends = []
  call substitute(search_range, b:endstart, '\=add(starts, submatch(0))', 'g')
  call substitute(search_range, b:endend, '\=add(ends, submatch(0))', 'g')
  if len(starts) > len(ends)
    " inside the function
    let name = matchstr(getline(function_line), b:funcstart)
    return (name !=? '' ? ' ' . name : '')
  else
    return ''
  endif
endfunction

nnoremap <buffer> <Space>p obinding.pry<Esc>

" if &l:statusline !~# '\V%{ruby#FindFunc()}'
"   setlocal statusline+=%{ruby#FindFunc()}
" endif
" if &l:statusline !~# '\V%{errors#statusline()}'
"   setlocal statusline+=%{errors#statusline()}
" endif

let b:undo_ftplugin = 'setlocal suffixesadd< foldmethod< tags<'
