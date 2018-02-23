""""""""""""""""""""""""""""""""""""""""""""""""
"              GENERAL OPTIONS
""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
set hidden                                    " A buffer becomes hidden when it is abandoned
set backspace=eol,start,indent                " Configure backspace so it acts as it should act
set whichwrap+=<,>,h,l                        " arrow keys and h,l move to the next line
set showcmd                                   " show keystrokes
set breakindent                               " Indent wrapped lines by 2
set breakindentopt=shift:2
set ignorecase                                " Ignore case when searching
set smartcase                                 " When searching try to be smart about cases
set hlsearch                                  " Highlight search results
set incsearch                                 " Makes search act like search in modern browsers
set lazyredraw                                " Don't redraw while executing macros
set showmatch                                 " Show matching brackets when text indicator is over them
set matchtime=2                               " How many tenths of a second to blink when matching brackets
set timeoutlen=500                            " shorter timeout
set ttimeoutlen=100                           " shorter timeout
set splitbelow                                " Make splits behave better
set splitright
syntax on                                     " turn syntax on
colorscheme material                          " material color scheme
set clipboard=unnamedplus                     " make clipboard work better
set softtabstop=4                             " number of spaces when inserting/backspacing
set shiftwidth=4                              " shift 4 spaces for indentation
set expandtab                                 " expand tabs into spaces
set autoindent                                " use the previous lines indentation level
set noshowmode                                " don't show mode in the statusline
set nowrap                                    " don't wrap lines by default
set linebreak                                 " wrap lines at words
set laststatus=2                              " always show statusline
set scrolloff=999                             " Set 999 lines to the cursor - when moving vertically using j/k
set sidescroll=1                              " scroll 1 character at a time
set sidescrolloff=15                          " scroll within 15 characters
set foldmethod=syntax                         " fold based on syntax
set wildmenu                                  " Turn on the wild menu
set wildmode=list:longest,list:full
set wildignore+=*.o,*~,*.pyc,*.versionsBackup,*target/*,*bin/*,*build/*,tags,Session.vim    " Ignore compiled files
set wildignorecase                            " ignore case in wildmenu
set sessionoptions-=options                   " make sessions work better with plugins
set sessionoptions-=folds
set sessionoptions-=blank
let g:is_posix = 1                            " make vim recognize posix compatible shells
set backupdir=/tmp                            " Better backups
set noswapfile
set foldlevel=99                              " don't fold things by default
set listchars=tab:»\ ,trail:~,extends:>,space:·,eol:$,nbsp:␣ " what to show for whitespace chars
set omnifunc=syntaxcomplete#Complete          " enable omnicompletion
set completeopt+=menuone,noselect,noinsert    " configure popup menu
set concealcursor+=n                          " conceal characters in normal mode
set conceallevel=2                            " conceal characters by default
set autowrite                                 " automatically save before :next, :make, etc
set autoread                                  " automatically reread changed files
set path=.,**                                 " set path to all subdirectories
set signcolumn=no                             " don't have signcolumn on
set fillchars=stl:\ ,stlnc:\ ,vert:│,fold:─,diff:─ " use box chars for folds, etc
set tags=./tags,tags
set spellfile=~/.vim/spell/en.utf-8.add
set modeline
set shortmess+=c
if executable('rg')                           " use ripgrep when available
  set grepprg=rg\ --vimgrep
  set grepformat=%f:%l:%c:%m,%f:%l:%m
elseif executable('ag')                       " use ag when available and ripgrep is not
  set grepprg=ag\ --vimgrep
  set grepformat=%f:%l:%c:%m,%f:%l:%m
endif
if has('gui_running')
  set guifont=DejaVu\ Sans\ Mono\ 10
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
" {{{
call plug#begin('~/.vim/bundle')
Plug 'gerw/vim-HiLinkTrace', { 'on': ['HLT','HLT!'] }
" Plug 'airblade/vim-gitgutter'
Plug 'lifepillar/vim-mucomplete'
Plug 'SirVer/ultisnips'
Plug 'easymotion/vim-easymotion'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
" Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-repeat'
Plug 'tommcdo/vim-lion'
Plug 'romainl/vim-qf'
Plug 'justinmk/vim-dirvish'
Plug 'xtal8/traces.vim'
Plug 'sgur/vim-editorconfig'
if executable('ctags')
  Plug 'ludovicchabant/vim-gutentags'
endif
" language specific plugins
Plug 'justmao945/vim-clang', { 'for': ['c','cpp'] }
Plug 'davidhalter/jedi-vim', { 'for': 'python' }
call plug#end()
runtime macros/matchit.vim
" }}}

""""""""""""""""""""""""""""""""""""""""""""""""
"              KEYBINDINGS
""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
nnoremap ; :
xnoremap ; :
nnoremap 0 ^
nnoremap ^ 0
nnoremap L $
nnoremap H ^

nnoremap Y y$

nnoremap <M-d> :bn<CR>
nnoremap <M-a> :bp<CR>
nnoremap <Esc>d :bn<CR>
nnoremap <Esc>a :bp<CR>
nnoremap <BS> <C-^>
nnoremap <silent> <Space>x :bn\|bd #<CR>

nnoremap <TAB> <C-w>w
nnoremap <S-TAB> <C-w>W

nnoremap <expr> j v:count ? 'j' : 'gj'
nnoremap <expr> k v:count ? 'k' : 'gk'
nnoremap gj j
nnoremap gk k

nnoremap gb :ls<CR>:b<space>
nnoremap <Space>b :buffer *<C-d>
nnoremap <Space>a :argadd **/*
nnoremap <Space>f :find *
nnoremap <Space>e :e <C-r>=fnameescape(expand('%:p:h'))<CR>/*<C-d>
nnoremap <Space>j :tjump /
nnoremap <Space>l :set colorcolumn=
nnoremap <Space>i :ilist /

nnoremap =ow :setlocal <C-R>=functions#ToggleSettings('wrap')<CR><CR>
nnoremap =oc :setlocal <C-R>=functions#ToggleSettings('cursorline')<CR><CR>
nnoremap =oz :setlocal <C-R>=functions#ToggleSettings('list')<CR><CR>
nnoremap =on :setlocal <C-R>=functions#ToggleSettings('number')<CR><CR>
nnoremap =or :setlocal <C-R>=functions#ToggleSettings('relativenumber')<CR><CR>
nnoremap =os :setlocal <C-R>=functions#ToggleSettings('spell')<CR><CR>
nnoremap =ou :setlocal <C-R>=functions#ToggleSettings('cursorcolumn')<CR><CR>
nnoremap =ox :setlocal <C-R>=functions#ToggleSettings(['cursorline','cursorcolumn'])<CR><CR>
nnoremap =og :call functions#ToggleSignColumn()<CR>
nnoremap =oq :call functions#ToggleConceal()<CR>
nnoremap ]q :cnext<CR>
nnoremap [q :cprevious<CR>
nnoremap [Q :cfirst<CR>
nnoremap ]Q :clast<CR>

inoremap jk <Esc>

nnoremap <Space>q :noh<return><esc>

nnoremap <silent> <Space>p p=']
nnoremap <silent> <Space>P P=']
xnoremap <silent> <Space>p p=']
xnoremap <silent> <Space>P P=']
xnoremap <silent> p p:let @+=@0<CR>:let @"=@0<CR>

noremap <silent> <F5> :call functions#VimRefresh()<CR>
nnoremap <silent> <Space>m :silent! make\|cwindow\|redraw!<CR>
cnoremap <expr> <CR> CCR()

nnoremap [I [I:ij!  /\<<C-r><C-w>\><S-Left><Left>
nnoremap ]I ]I:.+1,$ij!  /\<<C-r><C-w>\><S-Left><Left>

nnoremap <C-]> g<C-]>
nnoremap <expr> <C-w><C-]> (len(getwininfo()) > 1 ? "\"ayiw\<C-w>p:tjump \<C-r>a\<CR>" : ":vertical stjump \<C-r>\<C-w>\<CR>")
nnoremap <expr> <C-w>] (len(getwininfo()) > 1 ? "\"ayiw\<C-w>p:tjump \<C-r>a\<CR>" : ":vertical stjump \<C-r>\<C-w>\<CR>")
nnoremap <C-_> :stjump <C-r><C-w><CR>
nnoremap <C-Bslash> :vertical stjump <C-r><C-w><CR>
nnoremap <expr> g<C-_> (len(getwininfo()) > 1 ? "\"ayiw\<C-w>j:tjump \<C-r>a\<CR>" : ":stjump \<C-r>\<C-w>\<CR>")
nnoremap <expr> g<C-Bslash> (len(getwininfo()) > 1 ? "\"ayiw\<C-w>l:tjump \<C-r>a\<CR>" : ":vertical stjump \<C-r>\<C-w>\<CR>")

nnoremap <silent> <expr> <C-w>f len(getwininfo()) > 1
            \? ":let fname=\"\<C-r>\<C-f>\"\|execute \"normal! \\<lt>C-w>p\"\<CR>:find \<C-r>=fname\<CR>\<CR>"
            \: ":if findfile('\<C-r>\<C-f>') !=? ''\|vsplit\|find \<C-r>\<C-f>\|else\|execute 'normal! gf'\|endif\<CR>"
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
  autocmd BufNewFile,BufRead *.md                 set filetype=markdown
  autocmd BufReadPost        *                    if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
  autocmd FileType           *                    set formatoptions-=o       " Don't insert comment when using 'o'
  autocmd User UltiSnipsEnterFirstSnippet         let g:in_snippet = 1
  autocmd User UltiSnipsExitLastSnippet           let g:in_snippet = 0
augroup END

command! TrimWhiteSpace call functions#TrimWhiteSpace()

command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
            \ | wincmd p | diffthis

command! -range=% FormatJSON <line1>,<line2>!python -c
      \"import json, sys, collections; print json.dumps(json.load(sys.stdin,object_pairs_hook=collections.OrderedDict), indent=2)"

command! -range=% AE <line1>,<line2>yank a|silent! call functions#AnsibleEdit()
command! AC call functions#AnsibleEncrypt()

" make list-like commands more intuitive
" including this here to avoid screwing up command mode
function! CCR() abort
  let cmdline = getcmdline()
  if cmdline =~? '\v\C^(ls|files|buffers)' | return "\<CR>:b "
  elseif cmdline =~? '\v\C^(dli|il)' | return "\<CR>:".cmdline[0].'j  '.split(cmdline,' ')[1]."\<S-Left>\<Left>"
  elseif cmdline =~? '\v\C^(cli|lli)' | return "\<CR>:sil ".repeat(cmdline[0], 2)."\<Space>"
  elseif cmdline =~? '\C^old' | return "\<CR>:e #<"
  elseif cmdline =~? '\C^changes' | set nomore | return "\<CR>:set more|norm! g;\<S-Left>"
  elseif cmdline =~? '\C^ju' | set nomore | return "\<CR>:set more|norm! \<C-o>\<S-Left>"
  elseif cmdline =~? '\C^marks' | return "\<CR>:norm! `"
  elseif cmdline =~? '\C^undol' | return "\<CR>:u "
  else | return "\<CR>"
  endif
endfunction

" }}}

""""""""""""""""""""""""""""""""""""""""""""""""
"              STATUSLINE SETUP
""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
" normal statusline setup in $HOME/.vim/after/plugin/statusline.vim
" this statusline only used if --noplugin specified
set statusline=\ %{toupper(mode())}\ %f%m%r%h%w%=[%L][%{&ff}]%y[%p%%][%04l,%04v]
" }}}


""""""""""""""""""""""""""""""""""""""""""""""""
"              PLUGIN SETUP
""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
" most of the configs are in the after/plugin/settings folder
" these are here to prevent plugins from mapping things I don't want mapped
" ultisnips
let g:UltiSnipsExpandTrigger="\<nop>"
let g:UltiSnipsJumpForwardTrigger="\<C-l>"
let g:UltiSnipsJumpBackwardTrigger="\<C-h>"
" mucomplete
let g:mucomplete#enable_auto_at_startup = 1
let g:mucomplete#no_popup_mappings = 1
let g:mucomplete#always_use_completeopt = 1
let g:mucomplete#chains = {
      \ 'default' : ['path', 'omni', 'dict', 'uspl', 'ulti', 'keyn'],
      \ 'vim'     : ['path', 'cmd', 'ulti', 'keyn'],
      \ 'xml'     : ['ulti', 'tags', 'keyn'],
      \ 'sql'     : ['keyn', 'ulti']
      \ }
" jedi
let g:jedi#auto_vim_configuration = 0
let g:jedi#show_call_signatures = 1
let g:jedi#show_call_signatures_delay = 50
" clang
" let g:clang_auto = 0
let g:clang_c_completeopt = 'menuone,preview,noinsert,noselect'
let g:clang_cpp_completeopt = 'menuone,preview,noinsert,noselect'
let g:clang_verbose_pmenu = 1
" tmux-navigator
let g:tmux_navigator_no_mappings = 1
" lion
let g:lion_squeeze_spaces = 1 
" }}}
