" Plugins {{{
" filetype off
call plug#begin('~/.vim/bundle')

Plug 'w0rp/ale'
Plug 'junegunn/goyo.vim'
Plug 'davidhalter/jedi-vim', { 'for': 'python' }
Plug 'luochen1990/rainbow'
Plug 'gerw/vim-HiLinkTrace', { 'on': ['HLT','HLT!'] }
Plug 'easymotion/vim-easymotion'
Plug 'airblade/vim-gitgutter'
Plug 'tmux-plugins/vim-tmux', { 'for': 'tmux' }
Plug 'Shougo/neosnippet'
Plug 'Shougo/neosnippet-snippets'
Plug 'Shougo/neco-vim', { 'for': 'vim' }
Plug 'shougo/neocomplete.vim'
Plug 'justmao945/vim-clang', { 'for': ['c','cpp'] }
Plug 'christoomey/vim-tmux-navigator'
Plug 'godlygeek/tabular'
Plug 'jiangmiao/auto-pairs'
Plug 'Konfekt/FastFold'
Plug 'justinmk/vim-dirvish'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-unimpaired'
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }
Plug 'joshuazd/vim-ipython', { 'on': 'IPython' }
Plug 'artur-shaik/vim-javacomplete2', { 'for': 'java' }
Plug 'pearofducks/ansible-vim'
if executable("ctags")
  Plug 'ludovicchabant/vim-gutentags'
endif

call plug#end()
runtime macros/matchit.vim
" }}}

""""""""""""""""""""""""""""""""""""""""""""""""
"              GENERAL OPTIONS
""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
set ruler						" Always show current position
set cmdheight=1					" Height of the command bar
set hidden						" A buffer becomes hidden when it is abandoned
set backspace=eol,start,indent	" Configure backspace so it acts as it should act
set whichwrap+=<,>,h,l			" arrow keys and h,l move to the next line
set showcmd						" show keystrokes
set breakindent					" Indent wrapped lines by 2 {{{
set breakindentopt=shift:2		" }}}
" search {{{
set ignorecase					" Ignore case when searching
set smartcase					" When searching try to be smart about cases
set hlsearch					" Highlight search results
set incsearch					" Makes search act like search in modern browsers
" }}}
set lazyredraw					" Don't redraw while executing macros (good performance config)
set magic						" For regular expressions turn magic on
set showmatch					" Show matching brackets when text indicator is over them {{{
set matchtime=2					" How many tenths of a second to blink when matching brackets }}}
set noerrorbells				" No annoying sound on errors {{{
set novisualbell
set t_vb=
set timeoutlen=500				" }}}
set splitbelow					" Make splits behave better {{{
set splitright					" }}}
set background=dark				" dark background {{{
syntax on						" turn syntax on
colorscheme hybrid_material		" material color scheme }}}
set number						" show line numbers {{{
set relativenumber				" show relative line numbers
set numberwidth=1				" set min number column width }}}
set clipboard=unnamedplus		" make clipboard work better
set tabstop=4					" <TAB>s are 4 spaces {{{
set softtabstop=4				" number of spaces when inserting/backspacing
set shiftwidth=4				" shift 4 spaces for indentation
set expandtab					" expand tabs into spaces
set autoindent					" use the previous lines indentation level }}}
set noshowmode					" don't show mode in the statusline
set nowrap						" don't wrap lines by default
set linebreak					" wrap lines at words
set laststatus=2				" always show statusline
set cindent						" better indentation
" set cinkeys-=0#
set indentkeys-=0#
set scrolloff=999				" Set 999 lines to the cursor - when moving vertically using j/k {{{
set sidescroll=1				" scroll 1 character at a time
set sidescrolloff=15			" scroll within 15 characters }}}
set foldmethod=syntax			" fold based on syntax
set wildmenu					" Turn on the WiLd menu {{{
set wildmode=list:longest,list:full
set wildignore+=*.o,*~,*.pyc,*.versionsBackup,*/target/*,*/bin/*,tags	" Ignore compiled files
set wildignorecase				" ignore case in wildmenu }}}
au FileType * set fo-=o			" Don't insert comment when using 'o'
set sessionoptions-=options		" make sessions work better with plugins
set sessionoptions-=folds
let g:is_posix = 1
set backupdir=/tmp				" Better backups
set noswapfile
set foldlevel=12				" don't fold most things
set listchars=tab:>-,trail:~,extends:>,space:.,eol:$ " what to show for whitespace chars
set term=xterm-256color
set omnifunc=syntaxcomplete#Complete	" enable omnicompletion
set completeopt+=menuone
set concealcursor+=n			" conceal characters in normal mode
set conceallevel=2				" conceal characters by default
set autowrite					" automatically save before :next, :make, etc
set autoread					" automatically reread changed files
set path=.,**					" set path to all subdirectories
if executable("ag")				" use ag when available {{{
  set grepprg=ag\ --nogroup\ --nocolor\ --ignore-case\ --column
  set grepformat=%f:%l:%c:%m,%f:%l:%m
endif " }}}
if has("gui_running") " {{{
    " set guifont=Literation\ Mono\ Powerline\ 10
    " set guifont=DejaVuSansMono\ Nerd\ Font\ Mono\ Book\ 10
    set guifont=DejaVu\ Sans\ Mono\ Book\ 10
    set guioptions-=T
    set guioptions+=e
    set guioptions-=m
    set guioptions-=r
    set guioptions-=L
    set guitablabel=%M\ %t
    set lines=43 columns=120
endif " }}}
let g:hybrid_custom_term_colors=1
let g:xml_syntax_folding=1 " enable xml folding
" }}}

""""""""""""""""""""""""""""""""""""""""""""""""
"              KEYBINDINGS
""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
let mapleader = "\<Space>" " make leader a more sane keybinding
let maplocalleader = "," " remap localleader
" easier : mapping
noremap ; :
noremap , ;
" make 0 work better
nnoremap 0 ^
nnoremap ^ 0
" Make moving around splits easier
nnoremap <silent> <Leader>v :vs\|bn<CR>
nnoremap <silent> <Leader>s :sp\|bn<CR>
nnoremap <silent> <TAB> <c-w>w
" Make <Leader>q clear highlighting from searches
nnoremap <silent> <Leader>q :noh<return><esc>
" make it easier to use buffers
nnoremap <M-d> :bn<CR>
nnoremap <M-a> :bp<CR>
nnoremap <Esc>d :bn<CR>
nnoremap <Esc>a :bp<CR>

nnoremap <silent> <Leader><Leader> :b#<CR>
" more standard 'close buffer' behavior
nnoremap <silent> <Leader>x :bn\|bd #<CR>
" treat wrapped lines as different lines
noremap j gj
noremap k gk
noremap gj j
noremap gk k
" easier to go to end/beginning of lines
noremap L $
noremap H ^
" Buffer keymappings
nnoremap gb :ls<CR>:b<space>
nnoremap <Leader>b :buffer *<C-d>

" add files to bufferlist
nnoremap <Leader>a :argadd **/*

" find file
nnoremap <Leader>f :find *

" Close other splits easily
noremap <silent> <Leader>o :only<CR>
" Easier to save
nnoremap <C-s> :w<CR>
nnoremap q :q<CR>
inoremap <C-s> <Esc>:w<CR>i
" access to macros
nnoremap Q q
" Easier to exit insert mode
inoremap jk <Esc>
" keybinding to see whitespace
nnoremap <silent> <Leader>z :set invlist<CR>
" easier completion
inoremap <C-@> <C-x><C-o>
" toggle conceallevel
noremap <silent> <Leader>h :call ToggleConceal()<CR>
" search command
" noremap <silent> <C-f> :CtrlPLine<CR>
" paste and format
nnoremap <silent> <Leader>p p=']
nnoremap <silent> <Leader>P P=']
xnoremap <silent> <Leader>p p=']
xnoremap <silent> <Leader>P P=']
xnoremap <silent> p p:let @+=@0<CR>:let @"=@0<CR>

noremap <silent> <F5> :call VimRefresh()<CR>
function! VimRefresh() " {{{
    CtrlPClearAllCaches
    ALEToggle
    ALEToggle
    GitGutterToggle
    GitGutterToggle
    NeoCompleteClean
    NeoCompleteBufferMakeCache
    NeoCompleteMemberMakeCache
    if &filetype ==? 'java'
        JCcacheClear
    endif
endfunction " }}}
" }}}

""""""""""""""""""""""""""""""""""""""""""""""""
"              AUTOCOMMANDS
""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
augroup EditVim
    autocmd!
    autocmd InsertLeave * if pumvisible() == 0|pclose|endif " Close preview window when leaving insert mode
    autocmd BufNewFile,BufRead *.zsh-theme set filetype=zsh
    autocmd BufNewFile,BufRead *.dbs set filetype=xml
    autocmd BufNewFile,BufRead *.dmc set filetype=javascript
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
    autocmd BufNewFile,BufRead pom.xml setlocal foldmethod=syntax foldnestmax=10 conceallevel=0
augroup END

function! TrimWhiteSpace() " {{{
    %s/\s\+$//e
    ''
endfunction
command! TrimWhiteSpace call TrimWhiteSpace() " }}}

function! ToggleConceal() " {{{
    if &conceallevel == 0
        set conceallevel=2
    else
        set conceallevel=0
    endif
endfunction " }}}

function! VimGrepAll(pattern) abort
  call setqflist([])
  exe 'bufdo silent vimgrepadd ' . a:pattern . ' %'
  cwindow
  exe 'normal '
endfunction
command! -nargs=1 Search call VimGrepAll(<f-args>)
nnoremap <C-f> :Search 

command! FormatJSON %!python -c 
      \"import json, sys, collections; print json.dumps(json.load(sys.stdin,
      \object_pairs_hook=collections.OrderedDict), indent=2)"
" }}}

""""""""""""""""""""""""""""""""""""""""""""""""
"              STATUSLINE SETUP
""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
let g:modemap = {
      \ 'n' : ['N', 'NormalMode'],
      \ 'no': ['NO', 'NormalMode'],
      \ 'v' : ['V', 'VisualMode'],
      \ 'V' : ['V', 'VisualMode'],
      \ '': ['V', 'VisualMode'],
      \ 's' : ['S', 'VisualMode'],
      \ 'S' : ['S', 'VisualMode'],
      \ '': ['S', 'VisualMode'],
      \ 'i' : ['I', 'InsertMode'],
      \ 'ic': ['COMPLETE', 'InsertMode'],
      \ 'R' : ['R', 'ReplaceMode'],
      \ 'Rv': ['R', 'ReplaceMode'],
      \ 'c' : ['C', 'CommandMode'],
      \ 'cv': ['VIMEX', 'CommandMode'],
      \ 'ce': ['EX', 'CommandMode'],
      \ 'r' : ['PROMPT', 'CommandMode'],
      \ 'rm': ['MORE', 'CommandMode'],
      \ 'r?': ['CONFIRM', 'CommandMode'],
      \ '!' : ['SHELL', 'CommandMode'],
      \ 't' : ['TERM', 'CommandMode']}
function! GetModeIndicator() abort
  if &filetype ==# 'help'      | return ['Help']
  elseif &filetype ==# 'netrw' | return ['netrw']
  else                         | return g:modemap[mode()]
endfunction
let g:mode_hi = {
      \'NormalMode'  : ' ctermbg=12  ctermfg=0 ',
      \'InsertMode'  : ' ctermbg=3   ctermfg=0 ',
      \'VisualMode'  : ' ctermbg=10  ctermfg=0 ',
      \'ReplaceMode' : ' ctermbg=1   ctermfg=0 ',
      \'CommandMode' : ' ctermbg=13  ctermfg=0 '}
highlight StlGit      ctermbg=235 ctermfg=242 cterm=none
highlight MainStl     ctermbg=236 ctermfg=7   cterm=none
highlight ReadOnlyStl ctermbg=236 ctermfg=1   cterm=none
highlight InactiveStl ctermbg=242 ctermfg=235 cterm=none
highlight StatusLine  ctermbg=236 ctermfg=7   cterm=none
function! GitHunks()
  let l:githunks = GitGutterGetHunkSummary()
  let l:returnval = ' '
  let l:returnval .= (l:githunks[0] != 0 ? ' ' . l:githunks[0] . '+' : '')
  let l:returnval .= (l:githunks[1] != 0 ? ' ' . l:githunks[1] . '~' : '')
  let l:returnval .= (l:githunks[2] != 0 ? ' ' . l:githunks[2] . '-' : '')
  return l:returnval == ' ' ? '' : l:returnval
endfunction
function! GitStatusLine() abort
  let l:gitstatus = (fugitive#head() != '' ? ' ' . fugitive#head() : '')
  let l:githunks = GitHunks()
  let l:gitline = ''
  let l:gitline .= (l:githunks != '' ? l:githunks : '')
  let l:gitline .= (l:gitstatus != '' ? (l:gitline == '' ? ' ' : '') . l:gitstatus : '')
  let l:gitline .= (l:gitline != '' ? ' ' : '')
  return l:gitline
endfunction
function! LinterStatus() abort
  let l:counts = ale#statusline#Count(bufnr(''))
  let l:all_errors = l:counts.error + l:counts.style_error
  let l:all_non_errors = l:counts.total - l:all_errors
  return l:counts.total == 0 ? '' : printf(
        \ ' %dW %dE ',
        \ all_non_errors,
        \ all_errors
        \)
endfunction
fun! s:updateStatusLineHighlight(nr,newMode)
  execute 'hi! CurrMode ' . g:mode_hi[get(g:modemap, a:newMode, ["", a:newMode])[1]] . ' cterm=bold'
  execute 'hi! ModeNoBold '.g:mode_hi[get(g:modemap, a:newMode, ["", a:newMode])[1]] . ' cterm=none'
  return 1
endf
function! SetupStatusLine(nr) abort
  return get(extend(w:, {
        \ "lf_active": winnr() != a:nr
          \ ? 0
          \ : (mode(1) ==# get(g:, "lf_cached_mode", "")
            \ ? 1
            \ : s:updateStatusLineHighlight(a:nr,get(extend(g:, { "lf_cached_mode": mode(1) }), "lf_cached_mode"))
            \ ),
        \ "lf_winwd": winwidth(winnr())
        \ }), "", "")
endfunction
function! BuildStatusLine(nr) abort
  return '%{SetupStatusLine('.a:nr.')}
        \%#CurrMode#%{w:["lf_active"] ? "  " . GetModeIndicator()[0] . (&paste ? " PASTE " : " ") : ""}
        \%#StlGit#%{w:["lf_active"] ? GitStatusLine() : ""}
        \%#MainStl# %t%m
        \%#ReadOnlyStl# %{&readonly ? "RO" : ""}%#MainStl#
        \%=
        \%{ObsessionStatus("$ ")}%{w:["lf_active"] ? gutentags#statusline()." " : ""}
        \%#StlGit# %{&syntax." "}
        \%#ModeNoBold#%{w:["lf_active"] ? "  ".line(".").":".virtcol(".")." " : ""}
        \%#InactiveStl#%{w:["lf_active"] ? "" : "  ".line(".").":".virtcol(".")." "}
        \%#StlLinter#%{LinterStatus()}%#MainStl#'
endfunction
function! s:enableStatusLine() abort
  if exists("g:default_stl") | return | endif
  let g:default_stl = &statusline
  set statusline=%!BuildStatusLine(winnr())
endfunction
command! -nargs=0 EnableStatusLine call <SID>enableStatusLine()
EnableStatusLine
" }}}

""""""""""""""""""""""""""""""""""""""""""""""""
"              PLUGIN SETUP
""""""""""""""""""""""""""""""""""""""""""""""""
" {{{ filetype spefic plugins are in ftplugin folders
" gutentags setup {{{
  let g:gutentags_exclude_project_root = [
        \'/home/shepard/ansible/ansible-checkout',
        \'/home/shepard/ansible/environments',
        \'/home/shepard/ansible/playbooks-mw']
" }}}

" gitgutter setup {{{
  let g:gitgutter_sign_added = '•'
  let g:gitgutter_sign_modified = '•'
  let g:gitgutter_sign_removed = '•'
  let g:gitgutter_sign_modified_removed = '•'
" }}}

" neocomplete setup {{{

  if exists('g:loaded_neocomplete')
    let g:neocomplete#enable_at_startup = 1
    let g:neocomplete#enable_smart_case = 1
    let g:neocomplete#enable_auto_select = 1
    let g:neocomplete#enable_refresh_always = 1
    let g:neocomplete#auto_complete_delay = 0
    let g:neocomplete#enable_auto_delimiter = 1
    imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
                \ "\<Plug>(neosnippet_expand_or_jump)"
                \: pumvisible() ? "\<C-y>" : "\<TAB>"
    smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
                \ "\<Plug>(neosnippet_expand_or_jump)"
                \: "\<TAB>"
    imap <expr><CR> neosnippet#expandable() ?
                \ "\<Plug>(neosnippet_expand)"
                \: pumvisible()? "\<C-e>\<CR>" : "\<CR>\<Plug>AutoPairsReturn"
    inoremap <expr><C-l> pumvisible() ? 
                \ neocomplete#complete_common_string() : "\<C-l>"
    let g:neosnippet#enable_snipmate_compatibility = 0
    let g:neosnippet#snippets_directory = '~/.vim/after/snippets'

    if !exists('g:neocomplete#keyword_patterns')
        let g:neocomplete#keyword_patterns = {}
    endif
    let g:neocomplete#keyword_patterns._ = '\h\w*'

    if !exists('g:neocomplete#force_omni_input_patterns')
        let g:neocomplete#force_omni_input_patterns = {}
    endif

    " xml setup {{{
        let g:neocomplete#keyword_patterns.xml =
                    \'</\?\%([[:alnum:]_:-]\+\s*\)\?\%(/\?>\)\?\|&\h\%(\w*;\)\?'.
                    \'\|\h[[:alnum:]_:-]*'
        let g:neocomplete#force_omni_input_patterns.xml = '</\?'
        call neocomplete#custom#source('omni', 'rank', 1000)
    " }}}

    " python setup {{{
        let g:jedi#completions_enabled = 0
        let g:jedi#auto_vim_configuration = 0
        let g:jedi#smart_auto_mappings = 0
        let g:neocomplete#force_omni_input_patterns.python = 
              \'\%([^. \t]\.\|^\s*@\|^\s*from\s.\+import \|'.
              \'^\s*from \|^\s*import \)\w*'
    " }}}

    " clang setup {{{
        let g:clang_auto = 0 " disable auto completion for vim-clang
        let g:clang_c_completeopt = 'longest,menuone,preview'
        let g:clang_cpp_completeopt = 'longest,menuone,preview'
        let g:neocomplete#force_omni_input_patterns.c =
              \ '\h\w*\%(\.\|->\)\w*'
        let g:neocomplete#force_omni_input_patterns.cpp =
              \ '\h\w*\%(\.\|->\)\w*\|\h\w*::\w*'
        let g:neocomplete#force_omni_input_patterns.objc =
              \ '\[\h\w*\s\h\?\|\h\w*\%(\.\|->\)'
        let g:neocomplete#force_omni_input_patterns.objcpp =
              \ '\[\h\w*\s\h\?\|\h\w*\%(\.\|->\)\|\h\w*::\w*'
        let g:clang_verbose_pmenu = 1
    " }}}
  endif
" }}}

" Ansible setup {{{
    let g:ansible_unindent_after_newline = 1
    let g:ansible_attribute_highlight = "a"
    let g:ansible_extra_keywords_highlight = 1
" }}}

" ALE setup {{{
  if exists('g:loaded_ale_dont_use_this_in_other_plugins_please')
    nmap <silent> ]e <Plug>(ale_next_wrap)
    nmap <silent> [e <Plug>(ale_previous_wrap)
    let g:ale_python_flake8_options = '--max-line-length 99'
    let g:ale_virtualenv_dir_names = []
    let g:ale_warn_about_trailing_whitespace = 1
    let g:ale_lint_on_text_changed = 'normal'
    let g:ale_java_javac_options = '-Xlint:-serial'

    let g:ale_fixers = {
                \   'python': [
                \       'autopep8',
                \       'yapf'
                \   ]
                \}
  endif
" }}}

" Goyo setup {{{
    function! s:goyo_enter()
        set showmode
    endfunction

    function! s:goyo_leave()
        set noshowmode
    endfunction

    " toggle showmode because Goyo hides statusline 
    autocmd! User GoyoEnter nested call <SID>goyo_enter()
    autocmd! User GoyoLeave nested call <SID>goyo_leave()
" }}}

" Easymotion setup {{{
  if exists('g:EasyMotion_loaded')
    map <LocalLeader> <Plug>(easymotion-prefix)
    map s <Plug>(easymotion-s2)
    map f <Plug>(easymotion-f)
    map F <Plug>(easymotion-F)
    map t <Plug>(easymotion-t)
    map T <Plug>(easymotion-T)
    map / <Plug>(easymotion-sn)
    map ? <Plug>(easymotion-sn)
    omap / <Plug><easymotion-tn)
    omap ? <Plug><easymotion-tn)
    let g:EasyMotion_startofline = 0
    let g:EasyMotion_smartcase = 1
  endif
" }}}

" AutoPairs setup {{{
  " we map this in the neocomplete setup section 
  let g:AutoPairsMapCR = 0
" }}}

" rainbow parens setup {{{
  let g:rainbow_active = 1

  let g:rainbow_conf = {
              \ 'ctermfgs': [14, 11, 2, 9, 6, 5],
              \ 'separately': {
              \   'xml': 0,
              \   'vim': 0,
              \   'python': 0,
              \   'sh': 0,
              \   'c': 0,
              \   'javascript': 0,
              \   'json': 0
              \  }
              \}
" }}}
" }}}
