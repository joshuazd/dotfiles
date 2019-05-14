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

command! -nargs=1 -bang -bar Packadd call pack#add('<args>', '<bang>')
if has('pythonx')
  Packadd! ultisnips
endif
runtime macros/matchit.vim
syntax on
filetype plugin indent on
" }}}

" {{{ Options
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
set ttimeoutlen=0
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
set shortmess+=mrw
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
set spellfile=~/.vim/spell/en.utf-8.add
set formatoptions+=j
set foldtext=functions#MyFoldText()
set virtualedit+=block
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

if &termencoding ==# 'utf-8' || &encoding ==# 'utf-8'
  set fillchars=vert:│,diff:─
  set listchars=tab:│\ ,trail:─,extends:→,nbsp:␣
else
  set listchars=tab:\|\ ,trail:-,extends:>,nbsp:.
endif
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

" {{{ Keymaps
nnoremap Y y$

nnoremap [b :bprevious<CR>
nnoremap ]b :bnext<CR>
nnoremap <BS> <C-^>
nnoremap <silent> <Space>x :bn<Bar>bd #<CR>

nnoremap <expr> j v:count ? 'j' : 'gj'
nnoremap <expr> k v:count ? 'k' : 'gk'
nnoremap gj j
nnoremap gk k
nnoremap ' `
nnoremap c* :set hlsearch<CR>*Ncgn

" edit embedded scripts
xnoremap <Space>e :yank<Bar>vnew<Bar>silent! put!<Bar>set bt=nofile bh=wipe ft= <Bar>normal! gg=G<S-Left><S-Left><Left>
nnoremap <C-w>a :redraw!<CR>

for char in [ '_', '.', ':', ',', ';', '<bar>', '/', '<bslash>', '*', '+', '%', '`' ]
  execute 'xnoremap i' . char . ' :<C-u>normal! T' . char . 'vt' . char . '<CR>'
  execute 'onoremap i' . char . ' :normal vi' . char . '<CR>'
  execute 'xnoremap a' . char . ' :<C-u>normal! F' . char . 'vf' . char . '<CR>'
  execute 'onoremap a' . char . ' :normal va' . char . '<CR>'
endfor

nnoremap gb :ls<CR>:b<space>
nnoremap <Space>a :argadd **/*
nnoremap <Space>f :find<space>
nnoremap <Space>s :sfind<space>
nnoremap <Space>v :vert sfind<space>
nnoremap <Space>e :e <C-r>=fnameescape(expand('%:p:h'))<CR>/<C-z>
nnoremap <Space>t :tjump /

nnoremap <Space>l :set colorcolumn=
nnoremap <Space>q m":source $MYVIMRC<CR>:doautocmd VimEnter<CR>
nnoremap <Space>g :g/\v/#<Left><Left>
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

nnoremap ]q :cnext<CR>
nnoremap [q :cprevious<CR>
nnoremap [Q :cfirst<CR>
nnoremap ]Q :clast<CR>
nnoremap =q :cclose<CR>

" make [d and ]d show declarations
nnoremap [d :let save=winsaveview()<CR>gD:nohlsearch<CR>md:call winrestview(save)<Bar>echo getline("'d")<CR>
nnoremap ]d :let save=winsaveview()<CR>gd:nohlsearch<CR>md:call winrestview(save)<Bar>echo getline("'d")<CR>

nnoremap <silent> <Space>p p=']
xnoremap <silent> p p:let @+=@0<CR>:let @"=@0<CR>:let @*=@0<CR>
nnoremap <expr> <silent> zp putoperator#PutOperator()
nmap <silent> zpp Vp

" improved searching
cnoremap <expr> <Tab> getcmdtype() ==? '/' \|\| getcmdtype() ==? '?' ? "<CR>/<C-r>/" : "<C-z>"
cnoremap <expr> <S-Tab> getcmdtype() ==? '/' \|\| getcmdtype() ==? '?' ? "<CR>?<C-r>/" : "<C-z>"

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

" better file jumping
nnoremap <silent> <expr> <C-w>f winnr('$') > 1
      \? ":let fname=\"\<C-r>\<C-f>\"\|wincmd p\<CR>:find \<C-r>=fname\<CR>\<CR>"
      \: ":if findfile('\<C-r>\<C-f>') !=? ''\|vsplit\|find \<C-r>\<C-f>\|else\|execute 'normal! gf'\|endif\<CR>"

nnoremap <silent> <C-w>z :pclose<Bar>helpclose<CR>

" }}}

" {{{ (Auto)commands
augroup vimrc
  autocmd!
  autocmd BufReadPost        *            if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
  autocmd User UltiSnipsEnterFirstSnippet let in_snippet = 1
  autocmd User UltiSnipsExitLastSnippet   let in_snippet = 0
  if &termencoding ==# 'utf-8' || &encoding ==# 'utf-8'
    autocmd InsertEnter        *            setl listchars-=trail:─
    autocmd InsertLeave        *            setl listchars+=trail:─
  else
    autocmd InsertEnter        *            setl listchars-=trail:-
    autocmd InsertLeave        *            setl listchars+=trail:-
  endif
  autocmd VimEnter           *            silent! if fugitive#head() !=? '' | setl signcolumn=auto | endif
  autocmd BufNewFile  */plugin/*.vim      0r ~/.vim/skeleton.vim|call skeleton#replace()|call skeleton#edit()
  if exists('##TextYankPost') && executable('base64')
    autocmd TextYankPost       *            if v:event.operator ==# 'y' | call clip#osc52() | endif
  endif
augroup END

command! TrimWhiteSpace call whitespace#TrimWhiteSpace()
command! -range=% AnsibleEdit <line1>,<line2>yank a|silent! call ansible#AnsibleEdit()
command! AnsibleCrypt call ansible#AnsibleEncrypt()
command! -nargs=1 Tabs setlocal tabstop=<args> softtabstop=<args> shiftwidth=<args>
command! Focus call vim#Focus()
command! -nargs=1 -complete=color Theme colo <args>|!theme <args>
command! -range=% FormatJSON <line1>,<line2>!python2 -c
      \"import json, sys, collections; print json.dumps(json.load(sys.stdin,object_pairs_hook=collections.OrderedDict), indent=2)"

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
