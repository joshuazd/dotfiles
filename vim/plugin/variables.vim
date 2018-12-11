if exists('g:loaded_variables')
  finish
endif
let g:loaded_variables = 1

" ultisnips
let g:UltiSnipsListSnippets        = '<C-@>'
let g:UltiSnipsJumpForwardTrigger  = "\<C-l>"
let g:UltiSnipsJumpBackwardTrigger = "\<C-h>"
" mucomplete
let g:mucomplete#enable_auto_at_startup = 1
let g:mucomplete#no_popup_mappings      = 1
let g:mucomplete#always_use_completeopt = 1
let g:mucomplete#chains                 = {
      \ 'default' : ['file', 'omni', 'ulti', 'dict', 'uspl', 'c-n', 'tags'],
      \ 'java'    : ['omni', 'ulti', 'c-n',  'tags', 'file'],
      \ 'vim'     : ['file', 'ulti', 'cmd',  'c-n',  'tags'],
      \ 'xml'     : ['omni', 'ulti', 'tags', 'c-n'],
      \ 'sql'     : ['c-n',  'ulti', 'tags']
      \ }
let g:mucomplete#can_complete = { }
if has('lambda')
  let g:mucomplete#can_complete.default = { 'omni' : { t -> t =~ '\m\%(\k\k\|\.\)$' } }
  let g:mucomplete#can_complete.java    = { 'omni' : { t -> t =~# '\m\(\k\|)\|]\)\%\(\.\)$'} }
  let g:mucomplete#can_complete.xml     = { 'omni' : { t -> t =~# '\m\(\k\k\|<\|\k\+:\)$'} }
endif
" jedi
let g:jedi#auto_vim_configuration     = 0
let g:jedi#show_call_signatures       = 2
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
let g:markdown_fenced_languages = ['python', 'ruby', 'bash=sh', 'xml', 'sql', 'java']
" LSP
let g:LanguageClient_serverCommands = {
      \ 'java': ['/home/vagrant/dotfiles/bin/java-language-server'],
      \ }
" echodoc
let g:echodoc#enable_at_startup = 1
" gutentags
let g:gutentags_ctags_exclude = split(&wildignore, ',')
let g:todo_words = [['TODO', '|', 'DONE'], ['ASSIGNED', 'DEVELOP', 'TESTING', '|', 'READY', 'COMPLETE']]
if executable('python3')
  let g:python_executable = 'python3'
  let g:jedi#force_py_version = 3
endif
