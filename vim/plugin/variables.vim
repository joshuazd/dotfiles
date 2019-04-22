if exists('g:loaded_variables')
  finish
endif
let g:loaded_variables = 1

" Projectionist
let g:projectionist_heuristics = {
    \ '*_ESB/': {
    \   'pom.xml': {'type': 'pom'},
    \   '*_ESB/pom.xml': {'type': 'pom'},
    \   '*_Deployment/pom.xml': {'type': 'pom'},
    \   '**/src/main/synapse-config/api/*.xml': {'type': 'api'},
    \   '**/src/main/synapse-config/templates/*.xml': {'type': 'template'},
    \   '**/src/main/synapse-config/endpoints/*.xml': {'type': 'endpoint'},
    \   '**/src/main/synapse-config/local-entries/*.xml': {'type': 'localentry'},
    \   '**/src/main/synapse-config/tasks/*.xml': {'type': 'task'},
    \   '**/src/main/synapse-config/message-stores/*.xml': {'type': 'messagestore'},
    \   '**/src/main/synapse-config/message-processors/*.xml': {'type': 'messageprocessor'},
    \   '**/src/main/synapse-config/sequences/*.xml': {'type': 'sequence'},
    \   '**/src/main/synapse-config/proxy-services/*.xml': {'type': 'proxy'}
    \ },
    \ 'src/main/java/': {
    \   'src/main/java/**/controller/*.java': {'type': 'controller'},
    \   'src/main/java/**/model/*.java': {'type': 'model'},
    \   'src/main/java/**/dao/*.java': {'type': 'dao'},
    \   'src/main/java/**/service/*.java': {'type': 'service'},
    \   'src/main/java/**/util/*.java': {'type': 'util'}
    \ }
    \}


" LSC
let g:lsc_reference_highlights = v:false
let g:lsc_enable_autocomplete = v:false
let g:lsc_server_commands = {
      \ 'java': {
        \ 'command': 'java-language-server',
        \ 'log_level': 'Warning'
        \}
      \}
let g:lsc_auto_map = {
      \ 'GoToDefinition': 'gd',
      \ 'GoToDefinitionSplit': ['<C-W>d', '<C-W><C-d>'],
      \ 'FindReferences': 'gr',
      \ 'FindImplementations': 'gI',
      \ 'FindCodeActions': 'ga',
      \ 'Rename': 'gR',
      \ 'ShowHover': v:true,
      \ 'DocumentSymbol': 'go',
      \ 'WorkspaceSymbol': 'gS',
      \ 'SignatureHelp': '<C-m>',
      \ 'Completion': 'omnifunc',
      \}

" ultisnips
let g:UltiSnipsListSnippets        = '<C-@>'
let g:UltiSnipsJumpForwardTrigger  = "\<C-l>"
let g:UltiSnipsJumpBackwardTrigger = "\<C-h>"
" mucomplete
if !has('win32unix') " this is slow on cygwin
  let g:mucomplete#enable_auto_at_startup = 1
endif
let g:mucomplete#no_mappings            = 1
let g:mucomplete#no_popup_mappings      = 1
let g:mucomplete#always_use_completeopt = 1
let g:mucomplete#chains                 = {
      \ 'default'   : ['file', 'omni', 'ulti', 'dict', 'uspl', 'c-p', 'tags'],
      \ 'gitcommit' : ['tags', 'c-n'],
      \ 'java'      : ['omni', 'ulti', 'c-p',  'tags', 'file'],
      \ 'vim'       : ['file', 'ulti', 'cmd',  'c-p',  'tags'],
      \ 'xml'       : ['omni', 'ulti', 'tags', 'c-p'],
      \ 'sql'       : ['c-p',  'ulti', 'tags'],
      \ 'markdown'  : ['c-p',  'ulti', 'tags']
      \ }
let g:mucomplete#can_complete = { }
if has('lambda')
  let g:mucomplete#can_complete.default = { 'omni' : { t -> t =~ '\m\%(\k\k\|\.\)$' } }
  let g:mucomplete#can_complete.java    = { 'omni' : { t -> t =~# '\m\(\k\|)\|]\)\%\(\.\)$'} }
  let g:mucomplete#can_complete.xml     = { 'omni' : { t -> t =~# '\m\(\k\k\|<\|\k\+:\)$'} }
endif
" jedi
let g:jedi#auto_vim_configuration     = 0
let g:jedi#popup_on_dot               = 0
let g:jedi#show_call_signatures       = 1
let g:jedi#show_call_signatures_delay = 50
let g:jedi#auto_close_doc             = 0
" lion
let g:lion_squeeze_spaces = 1
" sneak
let g:sneak#label      = 1
let g:sneak#s_next     = 1
let g:sneak#use_ic_scs = 1
" netrw
let g:netrw_banner = 0
let g:netrw_liststyle = 0
let g:netrw_browse_split = 4
let g:netrw_winsize = 15
" markdown
let g:markdown_fenced_languages = ['python', 'ruby', 'bash=sh', 'xml', 'sql']
" echodoc
let g:echodoc#enable_at_startup = 1
" gutentags
let g:gutentags_ctags_exclude = split(&wildignore, ',')
if has('win32')
  let g:gutentags_ctags_extra_args=['--options=%HOME%\.ctags']
endif
let g:todo_words = [['TODO', '|', 'DONE'], ['ASSIGNED', 'DEVELOP', 'TESTING', '|', 'READY', 'COMPLETE']]
if executable('python3')
  let g:python_executable = 'python3'
  let g:jedi#force_py_version = 3
endif
" signify
let g:signify_vcs_list        = ['git']
let g:signify_sign_add        = '┃'
let g:signify_sign_delete     = '_'
let g:signify_sign_change     = '┃'
let g:signify_sign_delete_first_line = '¯'
let g:signify_sign_show_count = 0
function! s:hl_Signify() abort
  hi link SignifySignAdd    StringDelimiter
  hi link SignifySignChange Identifier
  hi link SignifySignDelete Special
endfunction
call <SID>hl_Signify()
augroup signify
  autocmd!
  autocmd ColorScheme * call <SID>hl_Signify()
augroup END
