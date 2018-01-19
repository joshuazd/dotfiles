""""""""""""""""""""""""""""""""""""""""""""""""
"              GENERAL OPTIONS
""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
set ruler					" Always show current position
set cmdheight=1					" Height of the command bar
set hidden					" A buffer becomes hidden when it is abandoned
set backspace=eol,start,indent			" Configure backspace so it acts as it should act
set whichwrap+=<,>,h,l				" arrow keys and h,l move to the next line
set showcmd					" show keystrokes
set breakindent					" Indent wrapped lines by 2
set breakindentopt=shift:2
set ignorecase					" Ignore case when searching
set smartcase					" When searching try to be smart about cases
set hlsearch					" Highlight search results
set incsearch					" Makes search act like search in modern browsers
set wrapscan					" Search commands wrap around end of buffer
set lazyredraw					" Don't redraw while executing macros
set magic					" For regular expressions turn magic on
set showmatch					" Show matching brackets when text indicator is over them
set matchtime=2					" How many tenths of a second to blink when matching brackets
set timeoutlen=500				" shorter timeout
set splitbelow					" Make splits behave better
set splitright
set background=dark				" dark background
syntax enable					" turn syntax on
colorscheme hybrid_material			" material color scheme
set number					" show line numbers
set relativenumber				" show relative line numbers
set numberwidth=1				" set min number column width
set clipboard=unnamedplus			" make clipboard work better
set softtabstop=4				" number of spaces when inserting/backspacing
set shiftwidth=4				" shift 4 spaces for indentation
set expandtab					" expand tabs into spaces
set autoindent					" use the previous lines indentation level
set noshowmode					" don't show mode in the statusline
set nowrap					" don't wrap lines by default
set linebreak					" wrap lines at words
set laststatus=2				" always show statusline
set scrolloff=999				" Set 999 lines to the cursor - when moving vertically using j/k
set sidescroll=1				" scroll 1 character at a time
set sidescrolloff=15				" scroll within 15 characters
set foldmethod=syntax				" fold based on syntax
set wildmenu					" Turn on the wild menu
set wildmode=list:longest,list:full
set wildignore+=*.o,*~,*.pyc,*.versionsBackup,*/target/*,*/bin/*,tags	" Ignore compiled files
set wildignorecase				" ignore case in wildmenu
set sessionoptions-=options			" make sessions work better with plugins
set sessionoptions-=folds
set sessionoptions-=blank
let g:is_posix = 1				" make vim recognize posix compatible shells
set backupdir=/tmp				" Better backups
set noswapfile
set foldlevel=99				" don't fold things by default
set listchars=tab:»\ ,trail:~,extends:>,space:·,eol:$,nbsp:␣ " what to show for whitespace chars
set omnifunc=syntaxcomplete#Complete		" enable omnicompletion
set completeopt+=menuone			" configure popup menu
set concealcursor+=n				" conceal characters in normal mode
set conceallevel=2				" conceal characters by default
set autowrite					" automatically save before :next, :make, etc
set autoread					" automatically reread changed files
set path=.,**					" set path to all subdirectories
set signcolumn=yes				" always have signcolumn on
if executable('ag')				" use ag when available
  set grepprg=ag\ --nogroup\ --nocolor\ --ignore-case\ --column\ --vimgrep
  set grepformat=%f:%l:%c:%m,%f:%l:%m
endif
if has('gui_running')
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
endif
" }}}

""""""""""""""""""""""""""""""""""""""""""""""""
"              PLUGINS
""""""""""""""""""""""""""""""""""""""""""""""""
" Plugins {{{
call plug#begin('~/.vim/bundle')
Plug 'gerw/vim-HiLinkTrace', { 'on': ['HLT','HLT!'] }
Plug 'Konfekt/FastFold'
Plug 'godlygeek/tabular', { 'on': 'Tabularize' }
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'shougo/neocomplete.vim'
Plug 'SirVer/ultisnips'
Plug 'easymotion/vim-easymotion'
Plug 'christoomey/vim-tmux-navigator'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-commentary'
Plug 'romainl/vim-qf'
Plug 'justinmk/vim-dirvish'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-dispatch'
Plug 'xtal8/traces.vim'
Plug 'luochen1990/rainbow'
if executable('ctags')
  Plug 'ludovicchabant/vim-gutentags'
endif
" language specific plugins
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }
Plug 'joshuazd/vim-ipython', { 'on': 'IPython' }
Plug 'justmao945/vim-clang', { 'for': ['c','cpp'] }
Plug 'davidhalter/jedi-vim', { 'for': 'python' }
Plug 'Shougo/neco-vim', { 'for': 'vim' }
call plug#end()
runtime macros/matchit.vim
" }}}

""""""""""""""""""""""""""""""""""""""""""""""""
"              KEYBINDINGS
""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
nnoremap ; :
nnoremap , ;
nnoremap 0 ^
nnoremap ^ 0
nnoremap L $
nnoremap H ^

nnoremap Y y$

nnoremap <silent> <Space>v :vs\|bn<CR>
nnoremap <silent> <Space>s :sp\|bn<CR>
nnoremap <silent> <TAB> <c-w>w

nnoremap <M-d> :bn<CR>
nnoremap <M-a> :bp<CR>
nnoremap <Esc>d :bn<CR>
nnoremap <Esc>a :bp<CR>
nnoremap <silent> <Space><Space> :b#<CR>
nnoremap <silent> <Space>x :bn\|bd #<CR>

nnoremap <expr> j v:count ? 'j' : 'gj'
nnoremap <expr> k v:count ? 'k' : 'gk'

nnoremap gb :ls<CR>:b<space>
nnoremap <Space>b :buffer *<C-d>
nnoremap <Space>a :argadd **/*
nnoremap <Space>f :find *
nnoremap <Space>j :tjump /
nnoremap <Space>l :set colorcolumn=

nnoremap <Space>w :w<CR>
nnoremap <C-q> :q<CR>

inoremap jk <Esc>

nnoremap <silent> <Space>z :set invlist<CR>
nnoremap <silent> <Space>q :noh<return><esc>

nnoremap <silent> <Space>c :call functions#ToggleConceal()<CR>
xnoremap <silent> <Space>c :call functions#ToggleConceal()<CR>

nnoremap <silent> <Space>p p=']
nnoremap <silent> <Space>P P=']
xnoremap <silent> <Space>p p=']
xnoremap <silent> <Space>P P=']
xnoremap <silent> p p:let @+=@0<CR>:let @"=@0<CR>

noremap <silent> <F5> :call functions#VimRefresh()<CR>
nnoremap <silent> <F10> :silent make\|cwindow\|redraw!<CR>
cnoremap <expr> <CR> functions#CCR()

nmap <silent> <Space>hs <Plug>GitGutterStageHunk
nmap <silent> <Space>hu <Plug>GitGutterUndoHunk
nmap <silent> <Space>hp <Plug>GitGutterPreviewHunk
" }}}

""""""""""""""""""""""""""""""""""""""""""""""""
"              AUTOCOMMANDS
""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
augroup EditVim
    autocmd!
    autocmd InsertLeave        *                    if pumvisible() == 0|pclose|endif
    autocmd BufNewFile,BufRead *.zsh-theme          set filetype=zsh
    autocmd BufNewFile,BufRead *.dbs                set filetype=xml
    autocmd BufNewFile,BufRead *.dmc                set filetype=javascript
    autocmd BufReadPost        *                    if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
    autocmd BufNewFile,BufRead pom.xml,artifact.xml setlocal foldmethod=syntax foldnestmax=10 conceallevel=0
    autocmd FileType           *                    set formatoptions-=o       " Don't insert comment when using 'o'
    autocmd InsertEnter        *                    call functions#InsertToggle('enter')
    autocmd InsertLeave        *                    call functions#InsertToggle('leave')
augroup END

command! TrimWhiteSpace call functions#TrimWhiteSpace()

command! -nargs=1 Search call functions#VimGrepAll(<f-args>)
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
      \ 'n' : ['N',       'NormalMode'],  'no': ['NO', 'NormalMode'],  'v' : ['V',     'VisualMode'],
      \ 'V' : ['V',       'VisualMode'],  '': ['V',  'VisualMode'],  's' : ['S',     'VisualMode'],
      \ 'S' : ['S',       'VisualMode'],  '': ['S',  'VisualMode'],  'i' : ['I',     'InsertMode'],
      \ 'ic': ['COMPL',   'InsertMode'],  'ix': ['X',  'InsertMode'],  'R' : ['R',     'ReplaceMode'],
      \ 'Rv': ['R',       'ReplaceMode'], 'c' : ['C',  'CommandMode'], 'cv': ['VIMEX', 'CommandMode'],
      \ 'ce': ['EX',      'CommandMode'], 'r' : ['P',  'CommandMode'], 'rm': ['MORE',  'CommandMode'],
      \ 'r?': ['CONFIRM', 'CommandMode'], '!' : ['SH', 'CommandMode'], 't' : ['TERM',  'CommandMode']}
function! GetModeIndicator() abort
  if &filetype ==# 'help'        | return ['Help']
  elseif &filetype ==# 'netrw'   | return ['netrw']
  elseif &filetype ==# 'dirvish' | return ['dirvish']
  else                           | return g:modemap[mode()]
  endif
endfunction
let g:mode_hi = {
      \'NormalMode'  : ' ctermbg=4   ctermfg=234 ',
      \'InsertMode'  : ' ctermbg=3   ctermfg=234 ',
      \'VisualMode'  : ' ctermbg=10  ctermfg=234 ',
      \'ReplaceMode' : ' ctermbg=1   ctermfg=234 ',
      \'CommandMode' : ' ctermbg=13  ctermfg=234 '}
highlight StlGit      ctermbg=235 ctermfg=242 cterm=none
highlight MainStl     ctermbg=236 ctermfg=7   cterm=none
highlight ReadOnlyStl ctermbg=236 ctermfg=1   cterm=none
highlight InactiveStl ctermbg=242 ctermfg=235 cterm=none
highlight StatusLine  ctermbg=236 ctermfg=7   cterm=none
highlight StlLinter   ctermbg=1   ctermfg=0   cterm=none
function! GitHunks() abort
  let l:githunks = GitGutterGetHunkSummary()
  let l:returnval = ' '
  let l:returnval .= (l:githunks[0] != 0 ? ' ' . l:githunks[0] . '+' : '')
  let l:returnval .= (l:githunks[1] != 0 ? ' ' . l:githunks[1] . '~' : '')
  let l:returnval .= (l:githunks[2] != 0 ? ' ' . l:githunks[2] . '-' : '')
  return l:returnval ==# ' ' ? '' : l:returnval
endfunction
function! GitStatusLine() abort
  let l:gitstatus = (fugitive#head() !=# '' ? ' ' . fugitive#head() : '')
  let l:githunks = GitHunks()
  let l:gitline = ''
  let l:gitline .= (l:githunks !=# '' ? l:githunks : '')
  let l:gitline .= (l:gitstatus !=# '' ? (l:gitline ==# '' ? ' ' : '') . l:gitstatus : '')
  let l:gitline .= (l:gitline !=# '' ? ' ' : '')
  return l:gitline
endfunction
function! QfList() abort
    let l:qflist = len(qf#GetList())
    if l:qflist ==# '0'
        return ''
    else
        return ' '.l:qflist.' '
    endif
endfunction
function! s:updateStatusLineHighlight(nr,newMode) abort
  execute 'hi! CurrMode ' . g:mode_hi[get(g:modemap, a:newMode, ['', a:newMode])[1]] . ' cterm=bold'
  execute 'hi! ModeNoBold '.g:mode_hi[get(g:modemap, a:newMode, ['', a:newMode])[1]] . ' cterm=none'
  return 1
endf
function! SetupStatusLine(nr) abort
  return get(extend(w:, {
        \ 'lf_active': winnr() != a:nr
          \ ? 0
          \ : (mode(1) ==# get(g:, 'lf_cached_mode', '')
            \ ? 1
            \ : s:updateStatusLineHighlight(a:nr,get(extend(g:, { 'lf_cached_mode': mode(1) }), 'lf_cached_mode'))
            \ ),
        \ 'lf_winwd': winwidth(winnr())
        \ }), '', '')
endfunction
function! BuildStatusLine(nr) abort
  return '%{SetupStatusLine('.a:nr.')}
        \%#CurrMode#%{w:["lf_active"] ? "  " . GetModeIndicator()[0] . (&paste ? " PASTE " : " ") : ""}
        \%#StlGit#%{w:["lf_active"] ? GitStatusLine() : ""}
        \%#MainStl# %t%m
        \%#ReadOnlyStl# %{&readonly ? "RO" : ""}%#MainStl#
        \%=
        \%{ObsessionStatus("$")}%{w:["lf_active"] ? gutentags#statusline() != "" ? " ".gutentags#statusline()." " : " " : " "}
        \%#StlGit#%{&syntax == "" ? "" : " ".&syntax." "}
        \%#ModeNoBold#%{w:["lf_active"] ? " ".line(".").":".virtcol(".")." " : ""}
        \%#InactiveStl#%{w:["lf_active"] ? "" : " ".line(".").":".virtcol(".")." "}
        \%#StlLinter#%{QfList()}%#MainStl#'
endfunction
function! s:enableStatusLine() abort
  set statusline=%!BuildStatusLine(winnr())
endfunction
command! -nargs=0 EnableStatusLine call <SID>enableStatusLine()
EnableStatusLine
" }}}

""""""""""""""""""""""""""""""""""""""""""""""""
"              PLUGIN SETUP
""""""""""""""""""""""""""""""""""""""""""""""""
" {{{ filetype specific plugin settings are in ftplugin folders
" gitgutter setup {{{
    let g:gitgutter_sign_modified_removed = '±'
    nmap [h <Plug>GitGutterPrevHunk
    nmap ]h <Plug>GitGutterNextHunk
" }}}

" neocomplete/ultisnips setup {{{

    let g:neocomplete#enable_at_startup = 1
    let g:neocomplete#enable_smart_case = 1
    let g:neocomplete#enable_refresh_always = 1
    let g:neocomplete#auto_complete_delay = 0
    let g:neocomplete#enable_auto_delimiter = 1
    let g:UltiSnipsJumpForwardTrigger='<NOP>'
    let g:UltiSnipsExpandTrigger='<NOP>'
    let g:ulti_expand_or_jump_res = 0
    let g:ulti_jump_forwards_res = 0
    let g:ulti_jump_backwards_res = 0
    call neocomplete#custom#source('ultisnips', 'rank', 1000)

    inoremap <silent> <expr><TAB> "<C-R>=functions#TabMapping()<CR>"
    inoremap <silent> <expr><S-TAB> "<C-R>=functions#ReverseTabMapping()<CR>"
    xnoremap <silent> <expr><TAB> ":<C-U>call UltiSnips#SaveLastVisualSelection()<cr>gvs"
    snoremap <silent> <expr><TAB> "<ESC>:call UltiSnips#JumpForwards()<cr>"
    snoremap <silent> <expr><S-TAB> "<ESC>:call UltiSnips#JumpBackwards()<cr>"
    imap <silent> <CR> <C-R>=((functions#EnterMapping() > 0) ? "" : pumvisible() ? "\eo" : "\r")<CR><Plug>AutoPairsReturn
    
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
        let g:clang_c_completeopt = 'menuone,preview'
        let g:clang_cpp_completeopt = 'menuone,preview'
        let g:neocomplete#force_omni_input_patterns.c =
              \ '\h\w*\%(\.\|->\)\w*'
        let g:neocomplete#force_omni_input_patterns.cpp =
              \ '\h\w*\%(\.\|->\)\w*\|\h\w*::\w*'
        let g:clang_verbose_pmenu = 1
    " }}}
" }}}

" netrw setup {{{
    let g:loaded_netrw       = 1
    let g:loaded_netrwPlugin = 1
" }}}

" Easymotion setup {{{
    map , <Plug>(easymotion-prefix)
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
                \  'xml':         0,
                \  'python':      0,
                \  'sh':          0,
                \  'c':           0,
                \  'javascript':  0,
                \  'json':        0
                \  }
                \}
" }}}
" }}}
