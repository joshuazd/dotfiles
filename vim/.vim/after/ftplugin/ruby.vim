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

setlocal tags+=$HOME/.rbenv/versions/3.1.4/lib/ruby/gems/3.1.0/gems/tags
setlocal foldmethod=indent
setlocal suffixesadd+=.html.erb
setlocal suffixesadd+=.html.haml
setlocal iskeyword+=!,?

let b:ale_fixers = ['rubocop', 'trim_whitespace']
let b:ale_linters = ['cspell', 'debride', 'rails_best_practices', 'reek', 'ruby', 'solargraph', 'sorbet']
let b:copilot_workspace_folders = ['~/portal']

let b:endstart = '\(^\|\n\)\(.*=\)\?\s*\%(private\s\+\|protected\s\+\|public\s\+\|module_function\s\+\)*\zs\%(module\|class\|def\|if\|unless\|case\|while\|until\|for\|begin\)\>\|\<do\ze\%(\s*|.*|\)\=\s*'
let b:endend = '\(^\|\n\)\s*\zsend\ze\s*'
let b:funcstart = '\(^\|\n\)\(.*=\)\?\s*\%(private\s\+\|protected\s\+\|public\s\+\|module_function\s\+\)*\%(module\|class\|def\|\)\>\s*\zs[A-Za-z0-9_.?]*\ze'

command! TN call ruby#run_command_in_engine('TestNearest')
command! TF call ruby#run_command_in_engine('TestFile')

nnoremap <buffer> <Space>b obinding.pry<Esc>
nnoremap <buffer> <Space>B Obinding.pry<Esc>

let b:undo_ftplugin = 'setlocal suffixesadd< foldmethod< tags< iskeyword<'
