" {{{ Plugins
" kept for backwards compatibility on older vim versions
if !has('packages')
  silent! call pathogen#infect()
endif
" Set up vim to work in windows+cygwin
if has('win32')
  set runtimepath^=~/.vim
  set runtimepath+=~/.vim/after
  set packpath^=~/.vim
endif

execute 'command! '.(has('packages') ? '-complete=packadd' : '')." -nargs=1 -bang -bar Packadd call pack#add('<args>', '<bang>')"
function! PackInit() abort
  Packadd minpac

  call minpac#init()
  call minpac#add('k-takata/minpac', {'type': 'opt', 'do': {-> system('rm -rf .git .github .gitignore appveyor.yml')}})

  call minpac#init({'package_name': 'remote'})

  call minpac#add('lifepillar/vim-mucomplete')
  call minpac#add('justinmk/vim-sneak')
  call minpac#add('tpope/vim-dispatch')
  call minpac#add('tpope/vim-surround')
  call minpac#add('tpope/vim-repeat')
  call minpac#add('tpope/vim-commentary')
  call minpac#add('tpope/vim-apathy')
  call minpac#add('tpope/vim-fugitive')
  call minpac#add('tpope/vim-endwise')
  call minpac#add('tpope/vim-rails')
  call minpac#add('tpope/vim-dadbod')
  call minpac#add('tpope/vim-projectionist')
  call minpac#add('tpope/vim-vinegar')
  call minpac#add('tpope/vim-bundler')
  call minpac#add('tpope/vim-rhubarb')
  call minpac#add('vim-ruby/vim-ruby')
  call minpac#add('tommcdo/vim-lion')
  call minpac#add('romainl/vim-qf')
  call minpac#add('romainl/vim-qlist')
  call minpac#add('romainl/vim-cool')
  call minpac#add('markonm/traces.vim')
  call minpac#add('sgur/vim-editorconfig')
  call minpac#add('natebosch/vim-lsc', {'type': 'opt'})
  call minpac#add('junegunn/fzf', {'do': {-> system('./install --all')}})
  call minpac#add('junegunn/fzf.vim')
  call minpac#add('ludovicchabant/vim-gutentags')
  call minpac#add('SirVer/ultisnips', {'type': 'opt'})
  call minpac#add('joukevandermaas/vim-ember-hbs')
  call minpac#add('sunaku/vim-ruby-minitest')
  call minpac#add('mhinz/vim-signify')
  call minpac#add('dense-analysis/ale')
  call minpac#add('vim-test/vim-test')
  call minpac#add('kana/vim-textobj-user')
  call minpac#add('tek/vim-textobj-ruby')
  call minpac#add('github/copilot.vim')
  call minpac#add('jparise/vim-graphql')
  call minpac#add('hashivim/vim-terraform')
  call minpac#add('ap/vim-css-color')
endfunction

command! PackUpdate call PackInit() | call minpac#update()
command! PackClean call PackInit() | call minpac#clean()
command! PackStatus Packadd minpac | call minpac#status()

py3 import sys
if has('pythonx')
  function! s:load_snippets() abort
    if filereadable($HOME.'/.vim/UltiSnips/'.&filetype.'.snippets') || isdirectory($HOME.'/.vim/UltiSnips/'.&filetype)
      Packadd ultisnips
      runtime after/plugin/maps.vim
    endif
  endfunction
  augroup LoadSnippets
    autocmd!
    autocmd FileType * call <SID>load_snippets()
  augroup END
endif
runtime macros/matchit.vim
syntax on
filetype plugin indent on
" }}}

" {{{ Options
set hidden
set history=200
set backspace=eol,start,indent
set whichwrap+=<,>
set showcmd
set breakindent
set breakindentopt+=shift:2
set nrformats-=octal
set ignorecase
set smartcase
set infercase
set incsearch
set hlsearch
set lazyredraw
set showmatch
set matchtime=2
set timeoutlen=3000
set ttimeoutlen=0
set softtabstop=4
set shiftwidth=4
set expandtab
set smarttab
set autoindent
set splitright
set splitbelow
set nowrap
set linebreak
set laststatus=2
set scrolloff=5
set sidescroll=1
set sidescrolloff=5
set sessionoptions-=options
set sessionoptions-=blank
set display+=lastline
set switchbuf=useopen
set autoread
set path=.,**
set tags=./tags,tags
set modeline
set shortmess+=mrw
set wildmenu
set wildcharm=<C-z>
set wildmode=longest:full,list
set wildoptions=fuzzy,pum
set wildignorecase
set wildignore+=*.o,*~,*.pyc,*.versionsBackup
set wildignore+=*target/*,*bin/*,*build/*
set wildignore+=tags,Session.vim,node_modules/*
set foldmethod=marker
set foldlevelstart=99
set pumheight=15
set complete-=i
set mouse=nvi
set ttymouse=sgr
set concealcursor+=n
set spellfile=~/.vim/spell/en.utf-8.add
set formatoptions+=j
set foldtext=functions#MyFoldText()
set virtualedit+=block
set updatetime=100
set nowrapscan
if has('patch-8.1.0513')
  set diffopt+=algorithm:patience,indent-heuristic,iwhiteall,vertical
endif

if !empty($TEMP)
  set directory=$TEMP/swap//
  set backupdir=$TEMP/backup//
else
  set directory=$HOME/.tmp/swap//
  set backupdir=$HOME/.tmp/backup//
endif
for dir in [&directory,&backupdir]
  if empty(glob(dir))
    call mkdir(dir, 'p')
  endif
endfor

set completeopt+=menuone
if has('patch-7.4.784')
  set completeopt+=noselect,noinsert
endif
set completepopup+=border:off,align:menu

if &termencoding ==# 'utf-8' || &encoding ==# 'utf-8'
  set fillchars=vert:│,diff:─
  set listchars=tab:│\ ,trail:─,extends:→,nbsp:␣,leadmultispace:│\ 
else
  set listchars=tab:\|\ ,trail:-,extends:>,nbsp:.,leadmultispace:\|\ 
endif
set list

if exists('&previewpopup')
  set previewpopup=height:10,width:60
  set completeopt+=popup
endif

if exists('+clipboard')
  set clipboard^=unnamed,unnamedplus
endif
if exists('+signcolumn')
  set signcolumn=auto
endif

if has('termguicolors') && &t_Co >= 256
  set termguicolors
endif
try
  " colorscheme material
  colorscheme nord
catch
endtry

if executable('rg')
  set grepprg=rg\ --vimgrep
  set grepformat=%f:%l:%c:%m
elseif executable('ag')
  set grepprg=ag\ --vimgrep\ $*
  set grepformat=%f:%l:%c:%m
endif

if has('gui_running')
  if has('win32')
    set guifont=Consolas:h10:cANSI:qDRAFT
  else
    set guifont=DejaVu\ Sans\ Mono\ 10
  endif
  set guicursor+=a:blinkon0
  set guioptions-=T
  set guioptions+=e
  set guioptions-=m
  set guioptions-=r
  set guioptions-=L
  set guitablabel=%M\ %t
  set lines=43 columns=120
endif
" }}}

" {{{ Keymaps
nnoremap Y y$

nnoremap [b :bprevious<CR>
nnoremap ]b :bnext<CR>
nnoremap <BS> <C-^>g`"
nnoremap <silent> <Space>x :bn<Bar>bd #<CR>
nnoremap [t :tabNext<CR>
nnoremap ]t :tabprevious<CR>

nnoremap <expr> j v:count ? 'j' : 'gj'
nnoremap <expr> k v:count ? 'k' : 'gk'
nnoremap gj j
nnoremap gk k
nnoremap ' `
nnoremap c* :set hlsearch<CR>*Ncgn
xnoremap * y/\V<C-R>"<CR>
xnoremap # y?\V<C-R>"<CR>
nnoremap & :&&<CR>

" edit embedded scripts
xnoremap <Space>e :yank<Bar>vnew<Bar>silent! put!<Bar>set bt=nofile bh=wipe ft= <Bar>normal! gg=G<S-Left><S-Left><Left>
nnoremap <C-w>a :redraw!<CR>

for char in [ '_', '.', ':', ',', ';', '<bar>', '/', '<bslash>', '*', '+', '%', '`' ]
  execute 'xnoremap i' . char . ' :<C-u>normal! T' . char . 'vt' . char . '<CR>'
  execute 'onoremap i' . char . ' :normal vi' . char . '<CR>'
  execute 'xnoremap a' . char . ' :<C-u>normal! F' . char . 'vf' . char . '<CR>'
  execute 'onoremap a' . char . ' :normal va' . char . '<CR>'
endfor

cnoreabbrev <expr> grep  (getcmdtype() ==# ':' && getcmdline() ==# 'grep')  ? 'Grep'  : 'grep'
cnoreabbrev <expr> lgrep (getcmdtype() ==# ':' && getcmdline() ==# 'lgrep') ? 'LGrep' : 'lgrep'

nnoremap gb :ls<CR>:b<space>
nnoremap <Space>a :argadd **/*
nnoremap <Space>ff :find<space>
nnoremap <Space>fs :sfind<space>
nnoremap <Space>fv :vert sfind<space>
nnoremap <Space>e :e <C-r>=fnameescape(expand('%:h'))<CR>/<C-z>
nnoremap <Space>t :tjump /

nnoremap <Space>;l :set colorcolumn=
nnoremap <Space>q m":source $MYVIMRC<CR>:doautocmd VimEnter<CR>
nnoremap <Space>;g :g/\v/#<Left><Left>
xnoremap <Space>;g "ay:g/\V<C-r>=escape(@a,'\/')<CR>/#<CR>:
nnoremap <Space>;i :ilist /
nnoremap <Space>;r :%s/<C-r><C-w>//g<Left><Left>
xnoremap <Space>;r "ay:<C-u>%s/\V<C-r>=substitute(escape(@a,'\\/'),'<C-v><C-@>','','')<CR>//g<Left><Left>
nnoremap <Space>;s :call setqflist([])<bar>bufdo vimgrepadd  %<Left><Left>
nnoremap <Space>gr :silent! grep!  <Bar> redraw! <Bar> cwindow<C-Left><C-Left><C-Left><C-Left><Left>
nnoremap gr :Grep<Space>
nnoremap <Esc>OA <Up>
nnoremap <silent> <nowait> <Esc> :<C-u>nohlsearch<Bar>call popup_clear()<CR>

" vim-unimpaired inspired settings toggles
nnoremap =on :setlocal number!         <Bar>setlocal number?<CR>
nnoremap =or :setlocal relativenumber! <Bar>setlocal relativenumber?<CR>
nnoremap =ow :setlocal wrap!           <Bar>setlocal wrap?<CR>
nnoremap =oz :setlocal list!           <Bar>setlocal list?<CR>
nnoremap =os :setlocal spell!          <Bar>setlocal spell?<CR>
nnoremap =oh :setlocal hlsearch!       <Bar>setlocal hlsearch?<CR>
nnoremap =o= :setlocal cursorline!     <Bar>setlocal cursorline?<CR>
nnoremap =og :setlocal signcolumn=<C-R>=(&signcolumn ==? 'no' ? 'yes' : 'no')<CR><Bar>setlocal signcolumn?<CR>
nnoremap =ol :setlocal conceallevel=<C-R>=(&conceallevel == 0 ? '2' : '0')<CR><Bar>setlocal conceallevel?<CR>
nnoremap =oy :if exists('g:syntax_on') <Bar> syntax off <Bar> else <Bar> syntax enable <Bar> endif<CR>

nnoremap ]q :cnext<CR>
nnoremap [q :cprevious<CR>
nnoremap [Q :cfirst<CR>
nnoremap ]Q :clast<CR>
nnoremap =q :cclose<CR>
nnoremap ]l :lnext<CR>
nnoremap [l :lprevious<CR>
nnoremap [L :lfirst<CR>
nnoremap ]L :llast<CR>
nnoremap =l :lclose<CR>

" make [d and ]d show declarations
" nnoremap [d :let save=winsaveview()<CR>gD:nohlsearch<CR>md:call winrestview(save)<Bar>echo getline("'d")<CR>
" nnoremap ]d :let save=winsaveview()<CR>gd:nohlsearch<CR>md:call winrestview(save)<Bar>echo getline("'d")<CR>

" nnoremap <silent> <Space>p p=']
xnoremap <silent> p p:let @+=@0<CR>:let @"=@0<CR>:let @*=@0<CR>
nnoremap <expr> <silent> zp putoperator#PutOperator()
nmap <silent> zpp Vp

" improved searching
cnoremap <expr> <Tab> getcmdtype() ==? '/' \|\| getcmdtype() ==? '?' ? "<CR>/<C-r>/" : "<C-z>"
cnoremap <expr> <S-Tab> getcmdtype() ==? '/' \|\| getcmdtype() ==? '?' ? "<CR>?<C-r>/" : "<C-z>"

nnoremap <silent> <F5> :call vim#VimRefresh()<CR>
nnoremap <silent> <F11> :call vim#Focus()<CR>
nnoremap <silent> <Space>m :silent! make<Bar>cwindow<Bar>redraw!<CR>
nnoremap <silent> <Space>m :silent! cgetexpr system(expandcmd(&makeprg))<CR>

" better tag jumping
nnoremap <C-]> g<C-]>
xnoremap <C-]> g<C-]>
" nnoremap <C-]> :tjump <C-r><C-w><Bar>call search('<C-r><C-w>')<CR>
nnoremap <expr> <C-w><C-]> winnr('$') > 1
      \? "\"ayiw\<C-w>p:tjump \<C-r>a\<CR>"
      \: ":vertical stjump \<C-r>\<C-w>\<CR>"
nnoremap <expr> <C-w>] winnr('$') > 1
      \? "\"ayiw\<C-w>p:tjump \<C-r>a\<CR>"
      \: ":vertical stjump \<C-r>\<C-w>\<CR>"
nnoremap <C-_> :stjump <C-r><C-w><CR>
nnoremap <C-Bslash> :vertical stjump <C-r><C-w><CR>

" better file jumping
nnoremap <silent> <expr> <C-w>f winnr('$') > 1
      \? ":let fname=\"\<C-r>\<C-f>\"\|wincmd p\<CR>:find \<C-r>=fname\<CR>\<CR>"
      \: ":if findfile('\<C-r>\<C-f>') !=? ''\|vsplit\|find \<C-r>\<C-f>\|else\|execute 'normal! gf'\|endif\<CR>"

nnoremap <silent> <C-w>z :pclose<Bar>helpclose<CR>

nnoremap <silent> <space>] :call tag#get('<C-r><C-w>')<CR>

nnoremap <silent> <space>gb :GB<CR>
xnoremap <silent> <space>gb :GB<CR>

function! Sort(type, ...)
    '[,']sort
endfunction
nnoremap <silent> gs :set opfunc=Sort<CR>g@

cnoreabbrev @f <C-r>=buffer_name()<CR>
cnoreabbrev :: <C-r>=buffer_name().':'.line('.')<CR>

" }}}

" {{{ (Auto)commands
augroup vimrc
  autocmd!
  autocmd BufReadPost        *            if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif | norm! zv
  autocmd User UltiSnipsEnterFirstSnippet let in_snippet = 1
  autocmd User UltiSnipsExitLastSnippet   let in_snippet = 0
  if &termencoding ==# 'utf-8' || &encoding ==# 'utf-8'
    autocmd InsertEnter      *            setl listchars-=trail:─
    autocmd InsertLeave      *            setl listchars+=trail:─
  else
    autocmd InsertEnter      *            setl listchars-=trail:-
    autocmd InsertLeave      *            setl listchars+=trail:-
  endif
  autocmd User FugitiveObject             setl signcolumn=auto
  autocmd BufReadPost        *            if !empty(FugitiveGitDir()) | let &l:grepprg='git grep -n --no-color --untracked -I' | endif
        \| let &l:grepformat='%f:%l:%c:%m,%f:%l:%m,%m %f match%ts,%f'
  autocmd BufNewFile  */plugin/*.vim      0r ~/.vim/skeleton.vim|call skeleton#replace()|call skeleton#edit()
  autocmd BufWinEnter        *            if &buftype=='quickfix' | setlocal wrap|nnoremap <buffer> gj gj|nnoremap <buffer> gk gk|nnoremap <buffer> j j|nnoremap <buffer> k k|endif
  " if exists('##TextYankPost') && executable('base64')
  "   autocmd TextYankPost     *            if v:event.operator ==# 'y' | silent! call clip#osc52() | endif
  " endif
  " autocmd FileType ruby                   let gemfile = findfile('Gemfile', '.;') | if !empty(gemfile) && filereadable(gemfile)
  "       \| let g:lsc_server_commands['ruby'] = {'command':'bundle exec solargraph stdio','suppress_stderr': v:true } | endif
  " autocmd FileType           *            if g:lsc_server_commands->keys()->index(&filetype) != -1 | let g:ale_disable_lsp = 1 | endif
augroup END

command! TrimWhiteSpace call whitespace#TrimWhiteSpace()
" command! -range=% AnsibleEdit <line1>,<line2>yank a|silent! call ansible#AnsibleEdit()
" command! AnsibleCrypt call ansible#AnsibleEncrypt()
command! -nargs=1 Tabs setlocal tabstop=<args> softtabstop=<args> shiftwidth=<args>
command! Focus call vim#Focus()
command! -nargs=1 -complete=color Theme colo <args>|!jzd theme <args>
command! -nargs=* -complete=file Args call args#tabsplit(<f-args>)
command! -range GB call git#blame("<line1>,<line2>")

if executable('python3')
  command! -range=% FormatJSON <line1>,<line2>!python3 -m json.tool
else
  command! -range=% FormatJSON <line1>,<line2>!python2 -c
        \"import json, sys, collections; print json.dumps(json.load(sys.stdin,object_pairs_hook=collections.OrderedDict), indent=2)"
endif
command! -range=% Json2Yaml <line1>,<line2>!python3 -c "import sys,yaml,json;print(yaml.dump(json.loads(sys.stdin.read())))"
command! -nargs=+ -complete=file_in_path -bar Grep  call grep#grep('cgetexpr', <f-args>)
command! -nargs=+ -complete=file_in_path -bar LGrep call grep#grep('lgetexpr', <f-args>)
command! -nargs=0 Pair call pair#pair()

" }}}

" {{{ Statusline
if exists('+statusline')
  let in_snippet = 0
  let stl_snippet = ['', 'snippet']

  set statusline=%f\ %m%r%w%q%h%=
  set statusline+=%<%-20{stl_snippet[in_snippet]}
  set statusline+=%-20{&filetype}
  set statusline+=%-15(%l,%c%V%)%P
endif
" }}}

" {{{ Variables
" LSC
let g:lsc_reference_highlights = 1
let g:lsc_enable_autocomplete = 0
let g:lsc_trace_level = 'messages'
function! s:fixEdits(actions) abort
  return map(a:actions, function('<SID>fixEdit'))
endfunction
function! s:fixEdit(idx, maybeEdit) abort
  if !has_key(a:maybeEdit, 'command') ||
        \ !has_key(a:maybeEdit.command, 'command') ||
        \ a:maybeEdit.command.command !=# 'java.apply.workspaceEdit'
    return a:maybeEdit
  endif
  return {
        \ 'edit': a:maybeEdit.command.arguments[0],
        \ 'title': a:maybeEdit.command.title}
endfunction
function! s:lscStart(name, params) abort
  echom 'Server started!'
  return a:params
endfunction
let g:lsc_server_commands = {
      \ 'java': {
        \ 'command': 'java-language-server',
        \ 'log_level': 'Warning',
        \ 'response_hooks': {
        \   'textDocument/codeAction': function('<SID>fixEdits'),
        \ }
        \},
      \ 'javascript': 'typescript-language-server --stdio',
      \ 'typescript': 'typescript-language-server --stdio',
      \ 'typescriptreact': 'typescript-language-server --stdio',
      \ 'ruby': {
        \ 'command': 'solargraph stdio',
        \ 'suppress_stderr': v:true,
        \ 'message_hooks': {
        \   'initialized': function('<SID>lscStart'),
        \ }
        \},
      \ 'python': {
      \   'command': 'pylsp',
      \   'workspace_config': {
      \     'pylsp': {
      \       'plugins': {
      \         'pycodestyle': {
      \           'enabled': v:false
      \         },
      \         'mccabe': {
      \           'enabled': v:false
      \         },
      \         'pyflakes': {
      \           'enabled': v:false
      \         },
      \         'flake8': {
      \           'enabled': v:true
      \         },
      \       }
      \     }
      \   }
      \ }
      \}
let g:lsc_auto_map = {
      \ 'GoToDefinition': 'gd',
      \ 'GoToDefinitionSplit': ['<C-W>d', '<C-W><C-d>'],
      \ 'FindReferences': 'gr',
      \ 'FindImplementations': 'gI',
      \ 'FindCodeActions': 'ga',
      \ 'Rename': 'gR',
      \ 'ShowHover': 1,
      \ 'DocumentSymbol': 'go',
      \ 'WorkspaceSymbol': 'gS',
      \ 'SignatureHelp': '<C-m>',
      \ 'Completion': 'omnifunc',
      \ 'defaults': 1
      \}
" ultisnips
let g:UltiSnipsListSnippets        = '<C-@>'
let g:UltiSnipsJumpForwardTrigger  = "\<C-l>"
let g:UltiSnipsJumpBackwardTrigger = "\<C-h>"
" mucomplete
" this is slow on cygwin
let g:mucomplete#enable_auto_at_startup = !has('win32unix')
let g:mucomplete#enable_auto_at_startup = 0
let g:mucomplete#no_mappings            = 1
let g:mucomplete#no_popup_mappings      = 1
let g:mucomplete#always_use_completeopt = 1
let g:mucomplete#chains                 = {
      \ 'default'   : ['file', 'ulti', 'dict', 'uspl', 'c-p'],
      \ 'html'      : ['file', 'omni', 'ulti', 'keyp'],
      \ 'handlebars': ['file', 'omni', 'ulti', 'keyp'],
      \ 'html.handlebars': ['file', 'omni', 'ulti', 'keyp'],
      \ 'gitcommit' : ['tags', 'c-n'],
      \ 'java'      : ['omni', 'ulti', 'c-p',  'tags', 'file'],
      \ 'ruby'      : ['omni', 'ulti', 'tags', 'c-p'],
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
  let g:mucomplete#can_complete.python  = { 'omni' : { t -> t =~# '\m\(\k\|)\|]\)\%\(\.\)$'} }
endif
" jedi
let g:jedi#auto_vim_configuration     = 0
let g:jedi#popup_on_dot               = 0
let g:jedi#show_call_signatures       = 0
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
let g:netrw_liststyle = 3
let g:netrw_browse_split = 0
let g:netrw_winsize = 15
let g:netrw_cursor = 2
let g:netrw_list_hide = '^\.\+\/*$'
" markdown
let g:markdown_fenced_languages = ['python', 'ruby', 'bash=sh', 'sql']
" gutentags
let g:gutentags_ctags_exclude = split(&wildignore, ',')
if has('win32')
  let g:gutentags_ctags_extra_args=['--options=%HOME%\.ctags']
endif
let g:gutentags_enabled = 0
let g:todo_words = [['TODO', '|', 'DONE'], ['ASSIGNED', 'DEVELOP', 'TESTING', '|', 'READY', 'COMPLETE']]
if executable('python3')
  let g:python_executable = 'python3'
  let g:jedi#force_py_version = 3
endif
" ALE
let g:ale_fix_on_save = 1
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_on_insert_leave = 1
let g:ale_lint_on_enter = 0
let g:ale_lint_on_filetype_changed = 1
" let g:ale_hover_to_floating_preview = 1
" let g:ale_open_list = 1
let g:ale_floating_window_border = ['', '', '', '', '', '', '', '']
let g:ale_floating_preview_popup_opts = {'borderchars': [' '], 'close': 'none'}
let g:ale_virtualtext_cursor = 0
let g:ale_sign_warning = '━'
let g:ale_ruby_rubocop_executable = 'bundle'
let g:ale_ruby_standardrb_executable = 'bundle'
" signify
let g:signify_sign_add               = '│'
let g:signify_sign_delete            = '▁'
let g:signify_sign_delete_first_line = '▔'
let g:signify_sign_change            = '│'
let g:signify_sign_add    = '▊'  " U+258A LEFT THREE QUARTERS BLOCK (1 cell)
let g:signify_sign_change = '██' " U+2588 FULL BLOCK x2 (2 cells)
let g:signify_sign_change_delete     = g:signify_sign_change . g:signify_sign_delete_first_line

" FZF
let g:fzf_files_options = ['--preview', 'fzf_preview {} 2>/dev/null']
let g:fzf_buffers_options = ['--preview', 'fzf_preview {2} 2>/dev/null']
let g:fzf_preview_window = ['right,50%,<90(down,50%)', 'ctrl-/']
" let g:fzf_layout = {'window': {'width': 0.85, 'height': 0.85, 'border': 'rounded'}}
" vim-test
let test#strategy = 'dispatch'
let g:test#ruby#minitest#executable = 'm'
let g:test#ruby#rspec#executable = 'bundle exec rspec --no-color --format failures'

let g:ruby_indent_assignment_style = 'variable'

function! s:hi(group, target) abort
  if &t_Co >= 256 || has('gui_running')
    let italic = 1
  else
    let italic = 0
  endif
  let target_id = synIDtrans(hlID(a:target))
  let t_fg = synIDattr(target_id, 'fg', 'cterm')
  let t_bg = synIDattr(target_id, 'bg', 'cterm')
  let t_fmt = synIDattr(target_id, 'reverse', 'cterm') ? 'reverse,' : ''
  let g_fg = synIDattr(target_id, 'fg', 'gui')
  let g_bg = synIDattr(target_id, 'bg', 'gui')
  let g_fmt = synIDattr(target_id, 'reverse', 'gui') ? 'reverse,' : ''
  let sign_column = synIDtrans(hlID('SignColumn'))
  let t_bg = synIDattr(sign_column, 'bg', 'cterm')
  let g_bg = synIDattr(sign_column, 'bg', 'gui')
  let Syn = {x -> len(x) ? x : 'NONE'}
  execute 'highlight ' . a:group . ' ctermfg=' . Syn(t_fg) . ' ctermbg=' . Syn(t_bg) .
        \ ' guifg=' . Syn(g_fg) . ' guibg=' . Syn(g_bg) .
        \ ' cterm=' . Syn(t_fmt) . ' gui=' . Syn(g_fmt)
endfunction
function! s:hl() abort
  hi link lscDiagnosticWarning WarningMsg
  call s:hi('SignifySignAdd', 'DiffAdd')
  call s:hi('SignifySignChange', 'DiffChange')
  call s:hi('SignifySignChangeDelete', 'SignifySignChange')
  call s:hi('SignifySignDelete', 'DiffDelete')
  call s:hi('SignifySignDeleteFirstLine', 'SignifySignDelete')
  call s:hi('ALEWarningSign', 'Todo')
  call s:hi('ALEErrorSign', 'Error')
endfunction
call <SID>hl()
augroup custom_hi
  autocmd!
  autocmd ColorScheme * call <SID>hl()
augroup END
" }}}

