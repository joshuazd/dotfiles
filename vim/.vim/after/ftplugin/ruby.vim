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

setlocal tags+=$HOME/.rbenv/versions/3.1.4/lib/ruby/gems/3.1.0/gems/tags
setlocal foldmethod=indent
setlocal suffixesadd+=.html.erb
setlocal iskeyword+=!,?

if !exists('g:rails_engine_paths')
  let eng_path = expand('~/backend/engines')
  let g:rails_engine_paths = ',,'
  for folder in ['lib','app/models','app/controllers/**','app/models','app/mailers',
        \'app/helpers','app/views','app/services','app/workers','app/serializers',
        \'test/functional/**','test/controllers/**','test/helpers','test/mailers','test/unit',
        \'test/workers','test/serializers','test/integration']
      let full_path = eng_path.'/'.'*'.'/'.folder
      " if isdirectory(full_path)
      let g:rails_engine_paths ..= full_path.','

      let full_path = expand('~/backend/packs').'/*/'.folder

      let g:rails_engine_paths ..= full_path.','
      " endif
      " if isdirectory(full_path.'/'.engine)
      "   let g:rails_engine_paths ..= full_path.'/'.engine.','
      " endif
    " endfor
  endfor
endif
setlocal path-=**
exec 'setlocal path^='.g:rails_engine_paths
let b:dispatch='bundle exec standardrb --format emacs --no-color %:S'
let b:ale_fixers = ['standardrb', 'rubocop', 'trim_whitespace']
let b:ale_linters = ['cspell', 'debride', 'rails_best_practices', 'reek', 'ruby', 'solargraph', 'sorbet', 'standardrb']
let b:copilot_workspace_folders =
  \ ['~/backend', '~/backend/engines/web', '~/backend/engines/api', '~/backend/engines/business_models', '~/backend/engines/credit_adapter/', '~/backend/engines/snowflake_client/']

" let b:endstart = '\(^\|\n\)\(.*=\)\?\s*\%(private\s\+\|protected\s\+\|public\s\+\|module_function\s\+\)*\zs\%(module\|class\|def\|if\|unless\|case\|while\|until\|for\|begin\)\>\%(.*[^.:@$]\<end\>\)\@!\|\<do\ze\%(\s*|.*|\)\=\s*'
let b:endstart = '\(^\|\n\)\(.*=\)\?\s*\%(private\s\+\|protected\s\+\|public\s\+\|module_function\s\+\)*\zs\%(module\|class\|def\|if\|unless\|case\|while\|until\|for\|begin\)\>\|\<do\ze\%(\s*|.*|\)\=\s*'
let b:endend = '\(^\|\n\)\s*\zsend\ze\s*'
let b:funcstart = '\(^\|\n\)\(.*=\)\?\s*\%(private\s\+\|protected\s\+\|public\s\+\|module_function\s\+\)*\%(module\|class\|def\|\)\>\s*\zs[A-Za-z0-9_.?]*\ze'

command! TN call ruby#run_command_in_engine('TestNearest')
command! TF call ruby#run_command_in_engine('TestFile')

nnoremap <buffer> <Space>b obinding.pry<Esc>
nnoremap <buffer> <Space>B Obinding.pry<Esc>

" if &l:statusline !~# '\V%{ruby#FindFunc()}'
"   setlocal statusline+=%{ruby#FindFunc()}
" endif
" if &l:statusline !~# '\V%{errors#statusline()}'
"   setlocal statusline+=%{errors#statusline()}
" endif

let b:undo_ftplugin = 'setlocal suffixesadd< foldmethod< tags< iskeyword<'
