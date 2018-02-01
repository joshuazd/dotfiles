" let g:neocomplete#enable_at_startup = 1
" let g:neocomplete#enable_smart_case = 1
" let g:neocomplete#enable_refresh_always = 1
" let g:neocomplete#auto_complete_delay = 0
" let g:neocomplete#enable_auto_delimiter = 1
let g:UltiSnipsJumpForwardTrigger="\<C-l>"
let g:UltiSnipsJumpBackwardTrigger="\<C-h>"
let g:UltiSnipsExpandTrigger="<C-\\>"
let g:ulti_expand_or_jump_res = 0
let g:ulti_jump_forwards_res = 0
let g:ulti_jump_backwards_res = 0
let g:vcm_s_tab_behavior = 1
let g:vcm_default_maps = 0

imap <silent> <TAB> <Plug>vim_completes_me_forward
imap <silent> <S-TAB> <Plug>vim_completes_me_backward
imap <silent> <CR> <C-R>=((functions#EnterMapping() > 0) ? "" : "\r")<CR><Plug>AutoPairsReturn
xnoremap <silent> <expr> <TAB>   ":<C-U>call UltiSnips#SaveLastVisualSelection()<cr>gvs"
snoremap <silent> <expr> <TAB>   "<ESC>:call UltiSnips#JumpForwards()<CR>"
snoremap <silent> <expr> <S-TAB> "<ESC>:call UltiSnips#JumpBackwards()<CR>"
snoremap <silent> <expr> <CR>    "<ESC>:call UltiSnips#JumpForwards()<CR>"


" if !exists('g:neocomplete#keyword_patterns')
"   let g:neocomplete#keyword_patterns = {}
" endif
" let g:neocomplete#keyword_patterns._ = '\h\w*'

" if !exists('g:neocomplete#force_omni_input_patterns')
"   let g:neocomplete#force_omni_input_patterns = {}
" endif

" " xml setup {{{
" let g:neocomplete#keyword_patterns.xml =
"       \'</\?\%([[:alnum:]_:-]\+\s*\)\?\%(/\?>\)\?\|&\h\%(\w*;\)\?'.
"       \'\|\h[[:alnum:]_:-]*'
" let g:neocomplete#force_omni_input_patterns.xml = '</\?'
" }}}

" python setup {{{
let g:jedi#completions_enabled = 0
let g:jedi#auto_vim_configuration = 0
let g:jedi#smart_auto_mappings = 0
" let g:neocomplete#force_omni_input_patterns.python = 
"       \'\%([^. \t]\.\|^\s*@\|^\s*from\s.\+import \|'.
"       \'^\s*from \|^\s*import \)\w*'
" }}}

" clang setup {{{
let g:clang_auto = 0 " disable auto completion for vim-clang
let g:clang_c_completeopt = 'menuone,preview'
let g:clang_cpp_completeopt = 'menuone,preview'
" let g:neocomplete#force_omni_input_patterns.c =
"       \ '\h\w*\%(\.\|->\)\w*'
" let g:neocomplete#force_omni_input_patterns.cpp =
"       \ '\h\w*\%(\.\|->\)\w*\|\h\w*::\w*'
let g:clang_verbose_pmenu = 1
" }}}

