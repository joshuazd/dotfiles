"===============================================
"                 PLUGINS
"===============================================
" {{{
" Set up vim to work in windows(+cygwin) or linux environments
let vimdir = '~/.vim'
if has('win32')
  let vimdir = '~/dotfiles/vim'
  set rtp^=~/dotfiles/vim
endif

if !empty(glob(vimdir . '/autoload/plug.vim'))
  call plug#begin(vimdir . '/bundle/')
  Plug 'lifepillar/vim-mucomplete'
  Plug 'justinmk/vim-sneak'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-obsession'
  Plug 'tpope/vim-repeat'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-endwise'
  Plug 'tommcdo/vim-lion'
  Plug 'romainl/vim-qf'
  Plug 'romainl/vim-qlist'
  Plug 'xtal8/traces.vim'
  Plug 'sgur/vim-editorconfig'
  if !has('win32')
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
    Plug 'junegunn/fzf.vim'
  endif
  if executable('ctags')
    Plug 'ludovicchabant/vim-gutentags'
  endif
  if has('python') || has('python3')
    Plug 'SirVer/ultisnips'
    Plug 'davidhalter/jedi-vim', { 'for': 'python' }
  endif
  call plug#end()
else
  syntax enable
  filetype plugin indent on
endif
runtime macros/matchit.vim
" }}}

"===============================================
"              GENERAL OPTIONS
"===============================================
" {{{
set encoding=utf-8                            " set file encoding to utf-8
set hidden                                    " A buffer becomes hidden when it is abandoned
set backspace=eol,start,indent                " Configure backspace so it acts as it should act
set whichwrap+=<,>                            " arrow keys move to the next line
set showcmd                                   " show keystrokes
set breakindent                               " Indent wrapped lines
set breakindentopt+=shift:2                   " shift wrapped lines by 2 spaces
set ignorecase                                " Ignore case when searching
set smartcase                                 " When searching try to be smart about cases
set incsearch                                 " Makes search act like search in modern browsers
set lazyredraw                                " Don't redraw while executing macros
set showmatch                                 " Show matching brackets when text indicator is over them
set matchtime=2                               " How many tenths of a second to blink when matching brackets
set timeoutlen=500                            " shorter timeout
set ttimeoutlen=100                           " shorter timeout
set splitbelow                                " Split horizontally below by default
set splitright                                " Split vertically to the right by default
set softtabstop=4                             " number of spaces when inserting/backspacing
set shiftwidth=4                              " shift 4 spaces for indentation
set expandtab                                 " expand tabs into spaces
set smarttab                                  " use shiftwidth with <TAB>
set autoindent                                " use the previous lines indentation level
set noshowmode                                " don't show mode in the commandline
set nowrap                                    " don't wrap lines by default
set linebreak                                 " wrap lines at words
set laststatus=2                              " always show statusline
set scrolloff=10                              " Set 999 lines to the cursor - when moving vertically
set sidescroll=1                              " scroll 1 character at a time
set sidescrolloff=15                          " scroll within 15 characters - when moving horizontally
set formatoptions-=o                          " Don't insert comment leader on `o`
set sessionoptions-=options                   " make sessions work better with plugins
set sessionoptions-=blank                     " don't save black buffers in sessions
set noswapfile                                " do not create swap files
set display+=lastline                         " show as much of the last line as possible
set autoread                                  " automatically reread changed files
set path=.,**                                 " set path to all subdirectories
set tags=./tags,tags                          " where to find tag files
set modeline                                  " read modelines
set shortmess+=cmrw                           " don't show completion errors
set wildmenu                                  " Turn on the wild menu
set wildmode=list:longest,list:full           " setup wildmenu
set wildignorecase                            " ignore case in wildmenu
set wildignore+=*.o,*~,*.pyc,*.versionsBackup " Ignore compiled files
set wildignore+=*target/*,*bin/*,*build/*     " Ignore build artifacts
set wildignore+=tags,Session.vim              " Ignore tags and session files
set foldmethod=marker                         " fold based on marker by default
set foldlevelstart=4                          " don't fold things by default
set omnifunc=syntaxcomplete#Complete          " enable omnicompletion
set concealcursor+=n                          " conceal characters in normal mode
set conceallevel=2                            " conceal characters by default
set spellfile=~/.vim/spell/en.utf-8.add       " keep list of good/bad words
set winminheight=0                            " minimum window height
set winminwidth=0                             " minimum window width
set foldtext=functions#MyFoldText()           " Set a nicer foldtext function
set virtualedit+=block                        " allow virtual editing in v-block mode
set fillchars=vert:│,diff:─                   " set characters for vert splits and diffs
set completeopt+=menuone                      " configure popup menu
if has('patch-7.4.784')
  set completeopt+=noselect,noinsert
endif
set listchars=tab:│\ ,trail:─,extends:>,nbsp:␣ " what to show for whitespace chars
set list
if exists('+clipboard')
  set clipboard^=unnamed,unnamedplus          " make clipboard work better
endif
if exists('+signcolumn')
  set signcolumn=no                           " don't have signcolumn on
endif
if has('termguicolors')
  set termguicolors                           " use gui colors in terminal vim
endif
try
  colorscheme material                        " material color scheme
catch
endtry
if executable('rg')                           " use ripgrep when available
  set grepprg=rg\ --vimgrep
  set grepformat=%f:%l:%c:%m,%f:%l:%m
elseif executable('ag')                       " use ag when available and ripgrep is not
  set grepprg=ag\ --vimgrep
  set grepformat=%f:%l:%c:%m,%f:%l:%m
endif
if has('gui_running')
  if has('win32')
    set guifont=Consolas:h10:cANSI:qDRAFT
  else
    set guifont=DejaVu\ Sans\ Mono\ 10
  endif
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
let maplocalleader = ','
" map Y behave like D and C
nnoremap Y y$

" buffer navigation
nnoremap [b :bprevious<CR>
nnoremap ]b :bnext<CR>
nnoremap <BS> <C-^>
nnoremap <silent> <Space>x :bn\|bd #<CR>

" line navigation
nnoremap <expr> j v:count ? 'j' : 'gj'
nnoremap <expr> k v:count ? 'k' : 'gk'
nnoremap gj j
nnoremap gk k
nnoremap ' `

" edit embedded scripts
xnoremap <Space>e :yank\|vnew\|silent! put\|set bt=nofile bh=wipe ft= \|normal! gg=G<S-Left><S-Left><Left>s
" redraw
nnoremap <C-w>a :redraw!<CR>
" select column
xnoremap ,c :<C-u>execute "normal! vip\<lt>C-v>" . col("'>") . "\|O" . col("'<") . "\|"<CR>
onoremap ,c :normal v,c<CR>

" file/buffer search and management
nnoremap gb :ls<CR>:b<space>
nnoremap <Space>a :argadd **/*
nnoremap <Space>f :find<space>
nnoremap <Space>s :sfind<space>
nnoremap <Space>v :vert sfind<space>
nnoremap <Space>e :e <C-r>=fnameescape(expand('%:p:h'))<CR>/<C-d>
nnoremap <Space>j :tjump /
nnoremap <Space>l :set colorcolumn=
nnoremap <Space>i :ilist /
nnoremap <Space>r :%s/<C-r><C-w>//g<Left><Left>
xnoremap <Space>r "ay:<C-u>%s/<C-r>a//g<Left><Left>

" settings toggles
nnoremap =ow :setlocal wrap!           \|setlocal wrap?<CR>
nnoremap =oc :setlocal cursorline!     \|setlocal cursorline?<CR>
nnoremap =oz :setlocal list!           \|setlocal list?<CR>
nnoremap =on :setlocal number!         \|setlocal number?<CR>
nnoremap =or :setlocal relativenumber! \|setlocal relativenumber?<CR>
nnoremap =os :setlocal spell!          \|setlocal spell?<CR>
nnoremap =ou :setlocal cursorcolumn!   \|setlocal cursorcolumn?<CR>
nnoremap =oh :setlocal hlsearch!       \|setlocal hlsearch?<CR>
nnoremap =og :setlocal signcolumn=<C-R>=(&signcolumn ==? 'no' ? 'yes' : 'no')<CR>\|setlocal signcolumn?<CR>
nnoremap =ol :setlocal conceallevel=<C-R>=(&conceallevel == 0 ? '2' : '0')<CR>\|setlocal conceallevel?<CR>
nnoremap =oy :if exists('g:syntax_on') \| syntax off \| else \| syntax enable \| endif<CR>

" quickfix maps
nnoremap ]q :cnext<CR>
nnoremap [q :cprevious<CR>
nnoremap [Q :cfirst<CR>
nnoremap ]Q :clast<CR>
nnoremap =q :cclose<CR>

" easier to exit insert mode
inoremap jk <Esc>

" smarter pasting
nnoremap <silent> <Space>p p=']
nnoremap <silent> <Space>P P=']
xnoremap <silent> <Space>p p=']
xnoremap <silent> <Space>P P=']
xnoremap <silent> p p:let @+=@0<CR>:let @"=@0<CR>:let @*=@0<CR>
nnoremap <silent> zp :set opfunc=functions#PutOp<CR>g@
nmap <silent> zpp Vp

" misc functions
nnoremap <silent> <F5> :call functions#VimRefresh()<CR>
nnoremap <silent> <F11> :call functions#Focus()<CR>
nnoremap <silent> <Space>m :silent! make\|cwindow\|redraw!<CR>
cnoremap <expr> <CR> CCR()

" better tag jumping
nnoremap <C-]> g<C-]>
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
inoremap (<CR> (<CR>)<C-o>O
inoremap [<CR> [<CR>]<C-o>O
inoremap {; {<CR>};<C-o>O
inoremap (; (<CR>);<C-o>O
inoremap [; [<CR>];<C-o>O

" select function
onoremap am :<C-u>normal [mV]M<CR>
xnoremap am :<C-u>normal [mV]M<CR>

" better file jumping
nnoremap <silent> <expr> <C-w>f winnr('$') > 1
      \? ":let fname=\"\<C-r>\<C-f>\"\|wincmd p\<CR>:find \<C-r>=fname\<CR>\<CR>"
      \: ":if findfile('\<C-r>\<C-f>') !=? ''\|vsplit\|find \<C-r>\<C-f>\|else\|execute 'normal! gf'\|endif\<CR>"
" }}}

"===============================================
"              (AUTO)COMMANDS
"===============================================
" {{{
augroup EditVim
  autocmd!
  autocmd BufNewFile,BufRead *.zsh-theme  set filetype=zsh
  autocmd BufNewFile,BufRead *.dbs        set filetype=xml
  autocmd BufNewFile,BufRead *.dmc        set filetype=javascript
  autocmd BufReadPost        *            if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
  autocmd User UltiSnipsEnterFirstSnippet let g:in_snippet = 1
  autocmd User UltiSnipsExitLastSnippet   let g:in_snippet = 0
  autocmd InsertEnter        *            set listchars-=trail:─
  autocmd InsertLeave        *            set listchars+=trail:─
augroup END

command! TrimWhiteSpace call functions#TrimWhiteSpace()

command! -range=% FormatJSON <line1>,<line2>!python2 -c
      \"import json, sys, collections; print json.dumps(json.load(sys.stdin,object_pairs_hook=collections.OrderedDict), indent=2)"

command! -range=% AE <line1>,<line2>yank a|silent! call functions#AnsibleEdit()
command! AC call functions#AnsibleEncrypt()
command! -nargs=1 Tabs setlocal tabstop=<args> softtabstop=<args> shiftwidth=<args>

command! Focus call functions#Focus()

command! -nargs=1 -complete=color Theme colo <args>|!theme <args>

" }}}

"===============================================
"              PLUGIN SETUP
"===============================================
" {{{
" Plugin mappings are specified in the after/plugin/settings folder
" ultisnips
let g:UltiSnipsExpandTrigger       = "\<nop>"
let g:UltiSnipsListSnippets        = '<C-@>'
let g:UltiSnipsJumpForwardTrigger  = "\<C-l>"
let g:UltiSnipsJumpBackwardTrigger = "\<C-h>"
" mucomplete
let g:mucomplete#enable_auto_at_startup = 1
let g:mucomplete#no_popup_mappings      = 1
let g:mucomplete#always_use_completeopt = 1
let g:mucomplete#chains                 = {
      \ 'default' : ['file', 'omni', 'dict', 'uspl', 'ulti', 'c-n', 'tags'],
      \ 'vim'     : ['file', 'cmd', 'ulti', 'c-n', 'tags'],
      \ 'xml'     : ['ulti', 'tags', 'c-n'],
      \ 'sql'     : ['c-n', 'ulti', 'tags']
      \ }
let mucomplete#can_complete = { }
if has('+lambda')
  let mucomplete#can_complete.default = { 'omni' : { t -> t =~ '\m\%(\k\k\|\.\)$' } }
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
let g:markdown_fenced_languages = ['python', 'ruby', 'bash=sh', 'xml', 'sql']
" }}}

"===============================================
"              STATUSLINE SETUP
"===============================================
" {{{
if exists('+statusline')
  let g:in_snippet = 0
  let g:stl_snippet = ['', 'snippet ']
  let g:findfunc = {'vim'   : ['^\s*fun\%[ction]', '^\s*endf\%[unction]',  '^\s*fun\%[ction]!\?\s\+\zs[a-z][[:alnum:]#_]*\ze('],
                   \'xml'   : ['^\s*<resource', '<\/resource>', '\%(ur[il]-\(mapping\|template\)="\)\@<=[^"]*"\@='],
                   \'python': ['^\s*\(class\|def\|async def\)\>', '\S\n\=\zs\n*\(^\s*\(class\|def\|async def\)\|^\S\)', '^\s*\(class\|def\|async def\)\s\+\zs\h\w*\ze('],
                   \'java'  : ['^\(\t\| \{&shiftwidth}\)\S\+.*\(\n^.*\)\={', '^\(\t\| \{&shiftwidth}\)}', '\h\w*\ze(']}
  let g:modemap = {
        \ 'n' :'NORMAL', 'no':'NORMOP', 'v' :'VISUAL', 'V' :'V-LINE',
        \ '':'VBLOCK', 's' :'SELECT', 'S' :'S-LINE', '':'SBLOCK',
        \ 'i' :'INSERT', 'ic':'COMPLT', 'ix':'XCOMPL', 'R' :'REPLCE',
        \ 'Rc':'RCOMPL', 'Rv':'VREPLC', 'Rx':'RXCOMP', 'c' :'COMMND',
        \ 'cv':'VIM-EX', 'ce':'  EX  ', 'r' :'PROMPT', 'rm':' MORE ',
        \ 'r?':'CONFRM', '!' :' SHELL', 't' :' TERM '}

  set statusline=\ %{g:modemap[mode()]}
  set statusline+=\ %<%f%m%r
  set statusline+=\ %w%q%=
  if !empty(glob('~/.vim/autoload/findfunc.vim'))
    set statusline+=%{findfunc#FindFunc()}
  endif
  set statusline+=\ %{g:stl_snippet[g:in_snippet]}
  set statusline+=%{&filetype}
  set statusline+=\ %03l:%02c\ 
endif
" }}}

"===============================================
"              EXTENDING VIM
"===============================================
" {{{
" make list-like commands more intuitive
" including this here to avoid screwing up command mode
function! CCR() abort
  let cmdline = getcmdline()
  if getcmdtype() !=? ':' | return "\<CR>" | endif
  if cmdline =~? '\v\C^(ls|files|buffers)' | return "\<CR>:b "
  elseif cmdline =~? '\v\C^(dli|il)' && len(split(cmdline,' ')) > 1 | return "\<CR>:".cmdline[0].'j  '.split(cmdline,' ')[1]."\<S-Left>\<Left>"
  elseif cmdline =~? '\v\C^(cli|lli)'      | return "\<CR>:sil ".repeat(cmdline[0], 2)."\<Space>"
  elseif cmdline =~? '\C^old'              | return "\<CR>:e #<"
  elseif cmdline =~? '\C^changes'          | set nomore | return "\<CR>:set more|norm! g;\<S-Left>"
  elseif cmdline =~? '\C^ju'               | set nomore | return "\<CR>:set more|norm! \<C-o>\<S-Left>"
  elseif cmdline =~? '\C^marks'            | return "\<CR>:norm! `"
  elseif cmdline =~? '\C^undol'            | return "\<CR>:u "
  else                                     | return "\<CR>"
  endif
endfunction

" lots of new text objects
for char in [ '_', '.', ':', ',', ';', '<bar>', '/', '<bslash>', '*', '+', '%', '`' ]
  execute 'xnoremap i' . char . ' :<C-u>normal! T' . char . 'vt' . char . '<CR>'
  execute 'onoremap i' . char . ' :normal vi' . char . '<CR>'
  execute 'xnoremap a' . char . ' :<C-u>normal! F' . char . 'vf' . char . '<CR>'
  execute 'onoremap a' . char . ' :normal va' . char . '<CR>'
endfor
" }}}
