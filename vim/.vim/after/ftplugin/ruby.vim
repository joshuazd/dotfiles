if executable('solargraph') && exists(':Packadd') && &filetype ==? 'ruby'
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

  " nnoremap <buffer> gd :ALEGoToDefinition<CR>
  " nnoremap <C-LeftMouse> :ALEGoToDefinition<CR>
  " nnoremap <buffer> <C-w>d :ALEGoToTypeDefinition -split<CR>
  " nnoremap <buffer> <C-w><C-d> :ALEGoToTypeDefinition -split<CR>
  " nnoremap <buffer> gr :ALEFindReferences<CR>
  " nnoremap <buffer> gI :ALEGoToImplementation<CR>
  " nnoremap <buffer> ga :ALECodeAction<CR>
  " nnoremap <buffer> gR :ALERename<CR>
  " nnoremap <buffer> go :ALESymbolSearch<space>
  " setlocal keywordprg=:ALEHover
  " setlocal omnifunc=ale#completion#OmniFunc
endif

nnoremap <buffer> <space>c :Econtroller<space>
nnoremap <buffer> <space>m :Emodel<space>
nnoremap <buffer> <space>ft :Etest<space>
nnoremap <buffer> <space>ut :Eunittest<space>
nnoremap <buffer> <space>fa :Efactory<space>
nnoremap <buffer> <space>se :Eservice<space>
nnoremap <buffer> <space>st :Eservicetest<space>
nnoremap <buffer> <space>li :Elib<space>

if match(expand('%:.'), '^\/Users\/jzinkduda\/\.rbenv') != -1
  silent! ALEDisableBuffer
endif

setlocal tags+=$HOME/.rbenv/versions/3.1.3/lib/ruby/gems/3.1.0/gems/tags
setlocal foldmethod=indent
setlocal suffixesadd+=.html.erb
setlocal iskeyword+=!,?
setlocal path=,,
setlocal path+=engines/web/app/controllers/web/api
setlocal path+=engines/web/app/controllers/web
setlocal path+=engines/api/app/controllers/api/v202209
setlocal path+=engines/business_models/app/models
setlocal path+=engines/business_models/app/services
setlocal path+=engines/business_models/app/services/business_models
setlocal path+=engines/web/app/services
setlocal path+=engines/web/app/services/web
setlocal path+=engines/api/app/services
setlocal path+=engines/api/app/services/api
setlocal path+=engines/business_models/lib/utilities
let b:dispatch='bundle exec standardrb --format emacs --no-color %:S'
let b:ale_fixers = ['standardrb', 'rubocop', 'trim_whitespace']
let b:ale_linters = ['brakeman', 'cspell', 'debride', 'rails_best_practices', 'reek', 'ruby', 'solargraph', 'sorbet', 'standardrb']

" let b:endstart = '\(^\|\n\)\(.*=\)\?\s*\%(private\s\+\|protected\s\+\|public\s\+\|module_function\s\+\)*\zs\%(module\|class\|def\|if\|unless\|case\|while\|until\|for\|begin\)\>\%(.*[^.:@$]\<end\>\)\@!\|\<do\ze\%(\s*|.*|\)\=\s*'
let b:endstart = '\(^\|\n\)\(.*=\)\?\s*\%(private\s\+\|protected\s\+\|public\s\+\|module_function\s\+\)*\zs\%(module\|class\|def\|if\|unless\|case\|while\|until\|for\|begin\)\>\|\<do\ze\%(\s*|.*|\)\=\s*'
let b:endend = '\(^\|\n\)\s*\zsend\ze\s*'
let b:funcstart = '\(^\|\n\)\(.*=\)\?\s*\%(private\s\+\|protected\s\+\|public\s\+\|module_function\s\+\)*\%(module\|class\|def\|\)\>\s*\zs[A-Za-z0-9_.?]*\ze'

function! ruby#run_command_in_engine(command) abort
  let cwd = getcwd()
  exec 'cd '.matchstr(expand('%:.'), '^engines/\w\+')
  exec a:command
  exec 'cd '.cwd
endfunction

command! TN call ruby#run_command_in_engine('TestNearest')
command! TF call ruby#run_command_in_engine('TestFile')

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

let b:undo_ftplugin = 'setlocal suffixesadd< foldmethod< tags< iskeyword<'
