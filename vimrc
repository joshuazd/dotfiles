"===============================================
"                 PLUGINS
"===============================================
" {{{
" Set up vim to work in windows+cygwin
if has('win32')
  set runtimepath^=~/.vim
  set runtimepath+=~/.vim/after
endif

silent! call plug#begin('$HOME/.vim/bundle/')
if exists('*plug#begin')

  filetype off

  Plug 'lifepillar/vim-mucomplete'
  Plug 'justinmk/vim-sneak'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-repeat'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-apathy'
  Plug 'tpope/vim-fugitive'
  Plug 'tommcdo/vim-lion'
  Plug 'romainl/vim-qf'
  Plug 'romainl/vim-qlist'
  Plug 'markonm/traces.vim'
  Plug 'sgur/vim-editorconfig'
  Plug 'mhinz/vim-signify'

  if !has('win32')
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
    Plug 'autozimu/LanguageClient-neovim', {'branch': 'next', 'do': 'bash install.sh', 'for': ['java'] }
  endif
  if executable('ctags')
    Plug 'ludovicchabant/vim-gutentags'
  endif
  if has('pythonx')
    Plug 'SirVer/ultisnips'
  endif
  silent! call plug#end()

endif
runtime! macros/matchit.vim
syntax enable
filetype plugin indent on
" }}}

"===============================================
"              GENERAL OPTIONS
"===============================================
" {{{
set encoding=utf-8
set hidden
set backspace=eol,start,indent
set whichwrap+=<,>
set showcmd
set breakindent
set breakindentopt+=shift:2
set ignorecase
set smartcase
set incsearch
set hlsearch
set lazyredraw
set showmatch
set matchtime=2
set timeoutlen=500
set ttimeoutlen=50
set splitbelow
set splitright
set softtabstop=4
set shiftwidth=4
set expandtab
set smarttab
set autoindent
set nowrap
set linebreak
set laststatus=2
set scrolloff=5
set sidescroll=1
set sidescrolloff=5
set sessionoptions-=options
set sessionoptions-=blank
set display+=lastline
set autoread
set path=.,**
set tags=./tags,tags
set modeline
set shortmess+=cmrw
set wildmenu
set wildcharm=<C-z>
set wildmode=list:longest,list:full
set wildignorecase
set wildignore+=*.o,*~,*.pyc,*.versionsBackup
set wildignore+=*target/*,*bin/*,*build/*
set wildignore+=tags,Session.vim
set foldmethod=marker
set foldlevelstart=4
set complete-=i
set omnifunc=syntaxcomplete#Complete
set concealcursor+=n
set conceallevel=2
set spellfile=~/.vim/spell/en.utf-8.add
set winminheight=0
set winminwidth=0
set foldtext=functions#MyFoldText()
set virtualedit+=block
set fillchars=vert:│,diff:─
if has('patch-8.1.0513')
  set diffopt+=algorithm:patience,indent-heuristic,iwhiteall
endif

if !empty($TEMP)
  set backupdir=$TEMP/swap/
  set directory=$TEMP/backup/
else
  set directory=$HOME/.tmp/swap//
  set backupdir=$HOME/.tmp/backup//
endif
for dir in [&directory, &backupdir]
  if empty(glob(dir))
    call mkdir(dir, 'p')
  endif
endfor

set completeopt+=menuone
if has('patch-7.4.784')
  set completeopt+=noselect,noinsert
endif

set listchars=tab:│\ ,trail:─,extends:>,nbsp:␣
set list

if exists('+clipboard')
  set clipboard^=unnamed,unnamedplus
endif
if exists('+signcolumn')
  set signcolumn=no
endif

if has('termguicolors') && &t_Co >= 256
  set termguicolors
endif
try
  colorscheme material
catch
endtry

if executable('rg')
  set grepprg=rg\ --vimgrep
  set grepformat=%f:%l:%c:%m
elseif executable('ag')
  set grepprg=ag\ --vimgrep
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

"===============================================
"              KEYBINDINGS
"===============================================
" {{{
" map Y behave like D and C
nnoremap Y y$

" buffer navigation
nnoremap [b :bprevious<CR>
nnoremap ]b :bnext<CR>
nnoremap <BS> <C-^>
nnoremap <silent> <Space>x :bn<Bar>bd #<CR>

" line navigation
nnoremap <expr> j v:count ? 'j' : 'gj'
nnoremap <expr> k v:count ? 'k' : 'gk'
nnoremap gj j
nnoremap gk k
nnoremap ' `
nnoremap c* :set hlsearch<CR>*Ncgn

" edit embedded scripts
xnoremap <Space>e :yank<Bar>vnew<Bar>silent! put!<Bar>set bt=nofile bh=wipe ft= <Bar>normal! gg=G<S-Left><S-Left><Left>
" redraw
nnoremap <C-w>a :redraw!<CR>

" new text objects
for char in [ '_', '.', ':', ',', ';', '<bar>', '/', '<bslash>', '*', '+', '%', '`' ]
  execute 'xnoremap i' . char . ' :<C-u>normal! T' . char . 'vt' . char . '<CR>'
  execute 'onoremap i' . char . ' :normal vi' . char . '<CR>'
  execute 'xnoremap a' . char . ' :<C-u>normal! F' . char . 'vf' . char . '<CR>'
  execute 'onoremap a' . char . ' :normal va' . char . '<CR>'
endfor

" file/buffer search and management
nnoremap gb :ls<CR>:b<space>
nnoremap <Space>a :argadd **/*
nnoremap <Space>f :find<space>
nnoremap <Space>s :sfind<space>
nnoremap <Space>v :vert sfind<space>
nnoremap <Space>e :e <C-r>=fnameescape(expand('%:p:h'))<CR>/<C-z>
nnoremap <Space>t :tjump /

nnoremap <Space>l :set colorcolumn=
nnoremap <Space>g :g/\v/#<Left><Left>:
xnoremap <Space>g "ay:g/\V<C-r>=escape(@a,'\/')<CR>/#<CR>:
nnoremap <Space>i :ilist /
nnoremap <Space>r :%s/<C-r><C-w>//g<Left><Left>
xnoremap <Space>r "ay:<C-u>%s/\V<C-r>=substitute(escape(@a,'\\/'),'<C-v><C-@>','','')<CR>//g<Left><Left>
nnoremap <Esc>OA <Up>
nnoremap <silent> <nowait> <Esc> :<C-u>nohlsearch<CR>

" vim-unimpaired inspired settings toggles
nnoremap =ow :setlocal wrap!     <Bar>setlocal wrap?<CR>
nnoremap =oz :setlocal list!     <Bar>setlocal list?<CR>
nnoremap =os :setlocal spell!    <Bar>setlocal spell?<CR>
nnoremap =oh :setlocal hlsearch! <Bar>setlocal hlsearch?<CR>
nnoremap =og :setlocal signcolumn=<C-R>=(&signcolumn ==? 'no' ? 'yes' : 'no')<CR><Bar>setlocal signcolumn?<CR>
nnoremap =ol :setlocal conceallevel=<C-R>=(&conceallevel == 0 ? '2' : '0')<CR><Bar>setlocal conceallevel?<CR>
nnoremap =oy :if exists('g:syntax_on') <Bar> syntax off <Bar> else <Bar> syntax enable <Bar> endif<CR>

" quickfix maps
nnoremap ]q :cnext<CR>
nnoremap [q :cprevious<CR>
nnoremap [Q :cfirst<CR>
nnoremap ]Q :clast<CR>
nnoremap =q :cclose<CR>

" make [d and ]d show declarations
nnoremap [d :let save=winsaveview()<CR>gD:nohlsearch<CR>^"ay$:call winrestview(save)<Bar>echo @a<CR>
nnoremap ]d :let save=winsaveview()<CR>gd:nohlsearch<CR>^"ay$:call winrestview(save)<Bar>echo @a<CR>

" smarter pasting
nnoremap <silent> <Space>p p=']
xnoremap <silent> p p:let @+=@0<CR>:let @"=@0<CR>:let @*=@0<CR>
nnoremap <expr> <silent> zp putoperator#PutOperator()
nmap <silent> zpp Vp

" improved searching
cnoremap <expr> <Tab> getcmdtype() ==? '/' \|\| getcmdtype() ==? '?' ? "<CR>/<C-r>/" : "<C-z>"
cnoremap <expr> <S-Tab> getcmdtype() ==? '/' \|\| getcmdtype() ==? '?' ? "<CR>?<C-r>/" : "<C-z>"

" misc functions
nnoremap <silent> <F5> :call vim#VimRefresh()<CR>
nnoremap <silent> <F11> :call vim#Focus()<CR>
nnoremap <silent> <Space>m :silent! make<Bar>cwindow<Bar>redraw!<CR>

" better tag jumping
nnoremap <C-]> g<C-]>
xnoremap <C-]> g<C-]>
nnoremap <expr> <C-w><C-]> winnr('$') > 1
      \? "\"ayiw\<C-w>p:tjump \<C-r>a\<CR>"
      \: ":vertical stjump \<C-r>\<C-w>\<CR>"
nnoremap <expr> <C-w>] winnr('$') > 1
      \? "\"ayiw\<C-w>p:tjump \<C-r>a\<CR>"
      \: ":vertical stjump \<C-r>\<C-w>\<CR>"
nnoremap <C-_> :stjump <C-r><C-w><CR>
nnoremap <C-Bslash> :vertical stjump <C-r><C-w><CR>

" auto expansion
inoremap {<CR> {<CR>}<C-o>O

" better file jumping
nnoremap <silent> <expr> <C-w>f winnr('$') > 1
      \? ":let fname=\"\<C-r>\<C-f>\"\|wincmd p\<CR>:find \<C-r>=fname\<CR>\<CR>"
      \: ":if findfile('\<C-r>\<C-f>') !=? ''\|vsplit\|find \<C-r>\<C-f>\|else\|execute 'normal! gf'\|endif\<CR>"

" make <C-w>z more robust
nnoremap <silent> <C-w>z :pclose<Bar>helpclose<CR>

" }}}

"===============================================
"              (AUTO)COMMANDS
"===============================================
" {{{
augroup EditVim
  autocmd!
  autocmd BufReadPost        *            if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
  autocmd User UltiSnipsEnterFirstSnippet let in_snippet = 1
  autocmd User UltiSnipsExitLastSnippet   let in_snippet = 0
  autocmd InsertEnter        *            setl listchars-=trail:─
  autocmd InsertLeave        *            setl listchars+=trail:─
  autocmd FileType           *            silent! call functions#LC_maps()
  autocmd VimEnter           *            if expand('%:p:h') =~# '^.*/projects/esb' && expand('%:p') == '' && &ft == '' | setf xml  | endif
  autocmd VimEnter           *            if expand('%:p:h') =~# '^.*/projects/weblogic' && expand('%:p') == '' && &ft == '' | setf java | endif
  autocmd VimEnter           *            silent! if fugitive#head() !=? '' | set signcolumn=yes | endif
augroup END

command! TrimWhiteSpace call whitespace#TrimWhiteSpace()
command! -range=% AE <line1>,<line2>yank a|silent! call ansible#AnsibleEdit()
command! AC call ansible#AnsibleEncrypt()
command! -nargs=1 Tabs setlocal tabstop=<args> softtabstop=<args> shiftwidth=<args>
command! Focus call vim#Focus()
command! -nargs=1 -complete=color Theme colo <args>|!theme <args>
command! -range=% FormatJSON <line1>,<line2>!python2 -c
      \"import json, sys, collections; print json.dumps(json.load(sys.stdin,object_pairs_hook=collections.OrderedDict), indent=2)"

" }}}

"===============================================
"              STATUSLINE SETUP
"===============================================
" {{{
if exists('+statusline')
  let in_snippet = 0
  let stl_snippet = ['', 'snippet']

  set statusline=%f\ %m%r%w%q%h%=
  set statusline+=%<%-20{stl_snippet[in_snippet]}
  set statusline+=%-20{&filetype}
  set statusline+=%-15(%l,%c%V%)%P
endif
" }}}
