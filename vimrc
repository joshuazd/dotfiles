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
set incsearch                                 " Makes search act like search in modern browsers
set lazyredraw                                " Don't redraw while executing macros
set showmatch                                 " Show matching brackets when text indicator is over them
set matchtime=2                               " How many tenths of a second to blink when matching brackets
set timeoutlen=500                            " shorter timeout
set ttimeoutlen=100                           " shorter timeout
set splitbelow                                " Make splits behave better
set splitright
set clipboard^=unnamed                        " make clipboard work better
set softtabstop=4                             " number of spaces when inserting/backspacing
set shiftwidth=4                              " shift 4 spaces for indentation
set expandtab                                 " expand tabs into spaces
set smarttab                                  " use shiftwidth with <TAB>
set autoindent                                " use the previous lines indentation level
set noshowmode                                " don't show mode in the commandline
set nowrap                                    " don't wrap lines by default
set linebreak                                 " wrap lines at words
set laststatus=2                              " always show statusline
set scrolloff=999                             " Set 999 lines to the cursor - when moving vertically
set sidescroll=1                              " scroll 1 character at a time
set sidescrolloff=15                          " scroll within 15 characters - when moving horizontally
set foldmethod=marker                         " fold based on syntax
set formatoptions-=o                          " Don't insert comment leader on `o`
set wildmenu                                  " Turn on the wild menu
set wildmode=list:longest,list:full           " setup wildmenu
set wildignore+=*.o,*~,*.pyc,*.versionsBackup " Ignore compiled files
set wildignore+=*target/*,*bin/*,*build/*     " Ignore build artifacts
set wildignore+=tags,Session.vim              " Ignore tags and session files
set wildignorecase                            " ignore case in wildmenu
set sessionoptions-=options                   " make sessions work better with plugins
set sessionoptions-=blank
set noswapfile                                " do not create swap files
set foldlevel=4                               " don't fold things by default
set listchars=tab:»\ ,trail:~,extends:>,space:·,eol:¬,nbsp:␣ " what to show for whitespace chars
set display+=lastline                         " show as much of the last line as possible
set omnifunc=syntaxcomplete#Complete          " enable omnicompletion
set completeopt+=menuone,noselect,noinsert    " configure popup menu
set virtualedit+=block                        " allow virtual editing in v-block mode
set concealcursor+=n                          " conceal characters in normal mode
set conceallevel=2                            " conceal characters by default
set autowrite                                 " automatically save before :next, :make, etc
set autoread                                  " automatically reread changed files
set path=.,**                                 " set path to all subdirectories
set signcolumn=no                             " don't have signcolumn on
set tags=./tags,tags                          " where to find tag files
set spellfile=~/.vim/spell/en.utf-8.add       " keep list of good/bad words
set modeline                                  " read modelines
set shortmess+=c                              " don't show completion errors
set winminheight=0                            " minimum window size 0x0
set winminwidth=0
set foldtext=functions#MyFoldText()           " Set a nicer foldtext function
colorscheme material                          " material color scheme
if executable('rg')                           " use ripgrep when available
  set grepprg=rg\ --vimgrep
  set grepformat=%f:%l:%c:%m,%f:%l:%m
elseif executable('ag')                       " use ag when available and ripgrep is not
  set grepprg=ag\ --vimgrep
  set grepformat=%f:%l:%c:%m,%f:%l:%m
endif
if has('gui_running')
  set guifont=Ubuntu\ Mono\ 11
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
Plug 'lifepillar/vim-mucomplete'
Plug 'SirVer/ultisnips'
Plug 'justinmk/vim-sneak'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'
Plug 'tommcdo/vim-lion'
Plug 'romainl/vim-qf'
Plug 'romainl/vim-qlist'
Plug 'justinmk/vim-dirvish'
Plug 'xtal8/traces.vim'
Plug 'sgur/vim-editorconfig'
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-indent'
if executable('ctags')
  Plug 'ludovicchabant/vim-gutentags'
endif
" language specific plugins
Plug 'davidhalter/jedi-vim', { 'for': 'python' }
call plug#end()
runtime macros/matchit.vim
" }}}

""""""""""""""""""""""""""""""""""""""""""""""""
"              KEYBINDINGS
""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
" for convenience
nnoremap L $
nnoremap H ^
xnoremap L $
xnoremap H ^

" set hlsearch and nohlsearch dynamically-ish
nnoremap <expr> n &hlsearch ? 'n' : ':set hlsearch<CR>'
nnoremap <expr> N &hlsearch ? 'N' : ':set hlsearch<CR>'
nnoremap <Space>q :nohlsearch<CR>:setlocal nohlsearch<CR>

" map Y behave like D and C
nnoremap Y y$

" buffer navigation
nnoremap <M-d> :bn<CR>
nnoremap <M-a> :bp<CR>
nnoremap <Esc>d :bn<CR>
nnoremap <Esc>a :bp<CR>
nnoremap <BS> <C-^>
nnoremap <silent> <Space>x :bn\|bd #<CR>

" make j and k smarter
nnoremap <expr> j v:count ? 'j' : 'gj'
nnoremap <expr> k v:count ? 'k' : 'gk'
nnoremap gj j
nnoremap gk k

xnoremap <Space>e :yank\|vnew\|silent! put\|set bt=nofile bh=wipe ft= \|normal! gg=G<S-Left><S-Left><Left>

" file/buffer search and management
nnoremap gb :ls<CR>:b<space>
nnoremap <Space>a :argadd **/*
nnoremap <Space>f :find<space>
nnoremap <Space>e :e <C-r>=fnameescape(expand('%:p:h'))<CR>/<C-d>
nnoremap <Space>j :tjump /
nnoremap <Space>l :set colorcolumn=
nnoremap <Space>i :ilist /

" settings toggles
nnoremap =ow :setlocal <C-R>=(&wrap           ? 'nowrap'           : 'wrap')<CR><CR>
nnoremap =oc :setlocal <C-R>=(&cursorline     ? 'nocursorline'     : 'cursorline')<CR><CR>
nnoremap =oz :setlocal <C-R>=(&list           ? 'nolist'           : 'list')<CR><CR>
nnoremap =on :setlocal <C-R>=(&number         ? 'nonumber'         : 'number')<CR><CR>
nnoremap =or :setlocal <C-R>=(&relativenumber ? 'norelativenumber' : 'relativenumber')<CR><CR>
nnoremap =os :setlocal <C-R>=(&spell          ? 'nospell'          : 'spell')<CR><CR>
nnoremap =ou :setlocal <C-R>=(&cursorcolumn   ? 'nocursorcolumn'   : 'cursorcolumn')<CR><CR>
nnoremap =oh :setlocal <C-R>=(&hlsearch       ? 'nohlsearch'       : 'hlsearch')<CR><CR>
nnoremap =og :setlocal signcolumn=<C-R>=(&signcolumn ==? 'no' ? 'yes' : 'no')<CR><CR>
nnoremap =oq :setlocal conceallevel=<C-R>=(&conceallevel == 0 ? '2' : '0')<CR><CR>
nnoremap ]q :cnext<CR>
nnoremap [q :cprevious<CR>
nnoremap [Q :cfirst<CR>
nnoremap ]Q :clast<CR>

" easier to exit insert mode
inoremap jk <Esc>

" smarter pasting
nnoremap <silent> <Space>p p=']
nnoremap <silent> <Space>P P=']
xnoremap <silent> <Space>p p=']
xnoremap <silent> <Space>P P=']
xnoremap <silent> p p:let @+=@0<CR>:let @"=@0<CR>

" misc functions
noremap <silent> <F5> :call functions#VimRefresh()<CR>
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

" better file jumping
nnoremap <silent> <expr> <C-w>f winnr('$') > 1
      \? ":let fname=\"\<C-r>\<C-f>\"\|execute \"normal! \\<lt>C-w>p\"\<CR>:find \<C-r>=fname\<CR>\<CR>"
      \: ":if findfile('\<C-r>\<C-f>') !=? ''\|vsplit\|find \<C-r>\<C-f>\|else\|execute 'normal! gf'\|endif\<CR>"
" }}}

""""""""""""""""""""""""""""""""""""""""""""""""
"              (AUTO)COMMANDS
""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
augroup EditVim
  autocmd!
  autocmd BufNewFile,BufRead *.zsh-theme  set filetype=zsh
  autocmd BufNewFile,BufRead *.dbs        set filetype=xml
  autocmd BufNewFile,BufRead *.dmc        set filetype=javascript
  autocmd BufReadPost        *            if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
  autocmd User UltiSnipsEnterFirstSnippet let g:in_snippet = 1
  autocmd User UltiSnipsExitLastSnippet   let g:in_snippet = 0
augroup END

command! TrimWhiteSpace call functions#TrimWhiteSpace()

command! -range=% FormatJSON <line1>,<line2>!python2 -c
      \"import json, sys, collections; print json.dumps(json.load(sys.stdin,object_pairs_hook=collections.OrderedDict), indent=2)"

command! -range=% AE <line1>,<line2>yank a|silent! call functions#AnsibleEdit()
command! AC call functions#AnsibleEncrypt()

" }}}

""""""""""""""""""""""""""""""""""""""""""""""""
"              PLUGIN SETUP
""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
" Plugin mappings are specified in the after/plugin/settings folder
" ultisnips
let g:UltiSnipsExpandTrigger       = "\<nop>"
let g:UltiSnipsJumpForwardTrigger  = "\<C-l>"
let g:UltiSnipsJumpBackwardTrigger = "\<C-h>"
" mucomplete
let g:mucomplete#enable_auto_at_startup = 1
let g:mucomplete#no_popup_mappings      = 1
let g:mucomplete#always_use_completeopt = 1
let g:mucomplete#chains                 = {
      \ 'default' : ['path', 'omni', 'dict', 'uspl', 'ulti', 'c-n', 'tags'],
      \ 'vim'     : ['path', 'cmd', 'ulti', 'c-n', 'tags'],
      \ 'xml'     : ['ulti', 'tags', 'c-n'],
      \ 'sql'     : ['c-n', 'ulti', 'tags']
      \ }
" jedi
let g:jedi#auto_vim_configuration     = 0
let g:jedi#show_call_signatures       = 2
let g:jedi#show_call_signatures_delay = 50
let g:jedi#force_py_version           = 3
" lion
let g:lion_squeeze_spaces = 1 
" sneak
let g:sneak#label      = 1
let g:sneak#s_next     = 1
let g:sneak#use_ic_scs = 1
" netrw
let g:loaded_netrw       = 1
let g:loaded_netrwPlugin = 1
" markdown
let g:markdown_fenced_languages = ['python', 'ruby', 'bash=sh', 'xml']
" }}}

""""""""""""""""""""""""""""""""""""""""""""""""
"              STATUSLINE SETUP
""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
let g:in_snippet = 0
let g:modemap = {
      \ 'n' : ['N',     'Normal'],  'no': ['NO',   'Normal'],  'v' : ['V',    'Visual'],
      \ 'V' : ['V',     'Visual'],  '': ['V',    'Visual'],  's' : ['S',    'Visual'],
      \ 'S' : ['S',     'Visual'],  '': ['S',    'Visual'],  'i' : ['I',    'Insert'],
      \ 'ic': ['COMP',  'Insert'],  'ix': ['X',    'Insert'],  'R' : ['R',    'Replace'],
      \ 'Rc': ['RCOMP', 'Replace'], 'Rv': ['R',    'Replace'], 'Rx': ['RX',   'Replace'],
      \ 'c' : ['C',     'Command'], 'cv': ['VEX',  'Command'], 'ce': ['EX',   'Command'],
      \ 'r' : ['P',     'Command'], 'rm': ['MORE', 'Command'], 'r?': ['CONF', 'Command'],
      \ '!' : ['SH',    'Command'], 't' : ['TERM', 'Command']}

let g:mode_hi = {
      \'Normal'  : 'ctermfg=68  guifg=#6182b8 ctermbg=236 guibg=#303030',
      \'Insert'  : 'ctermfg=221 guifg=#ffcb6b ctermbg=236 guibg=#303030',
      \'Visual'  : 'ctermfg=107 guifg=#91b859 ctermbg=236 guibg=#303030',
      \'Replace' : 'ctermfg=167 guifg=#d75f5f ctermbg=236 guibg=#303030',
      \'Command' : 'ctermfg=176 guifg=#c792ea ctermbg=236 guibg=#303030'}

function! s:updateStatusLineHighlight(mode) abort
  execute 'hi! CurrMode ' . g:mode_hi[g:modemap[a:mode][1]] . ' cterm=bold gui=bold'
  execute 'hi! ModeNoBold '.g:mode_hi[g:modemap[a:mode][1]] . ' cterm=none gui=none'
  return 1
endfunction

function! StatusLineColors() abort
  highlight StlDim       ctermbg=236 guibg=#303030 ctermfg=243 guifg=#767676 cterm=NONE gui=NONE
  highlight StlDimNC     ctermbg=242 guibg=#6c6c6c ctermfg=234 guifg=#1c1c1c cterm=NONE gui=NONE
  highlight ReadOnlyStl  ctermbg=236 guibg=#303030 ctermfg=167 guifg=#d75f5f cterm=NONE gui=NONE
  highlight StatusLine   ctermbg=236 guibg=#303030 ctermfg=250 guifg=#bcbcbc cterm=NONE gui=NONE
  highlight StatusLineNC ctermbg=242 guibg=#6c6c6c ctermfg=234 guifg=#1c1c1c cterm=NONE gui=NONE
  call s:updateStatusLineHighlight(mode())
endfunction

call StatusLineColors()

augroup statusline
  autocmd!
  autocmd ColorScheme * call StatusLineColors()
augroup END

function! SetupStatusLine(nr) abort
  return get(extend(w:, {
        \ 'active': winnr() != a:nr
        \ ? 0 : (mode(1) ==# get(g:, 'cached_mode', '')
            \ ? 1 : s:updateStatusLineHighlight(get(extend(g:,
                    \ { 'cached_mode': mode(1) }), 'cached_mode')))}), '', '')
endfunction

function! BuildStatusLine(nr, extra) abort
  return '%{SetupStatusLine('.a:nr.')}'
        \.'%#CurrMode#%{w:["active"] ? "  " . g:modemap[mode()][0] . (&paste ? " PASTE " : " ") : ""}'
        \.'%0* %f%m'
        \.'%#ReadOnlyStl#%{&readonly && w:["active"] ? "  RO" : ""}%0*'
        \.'%='
        \.'%{g:in_snippet > 0 ? "snippet " : ""}'
        \.'%#StlDim#%{&syntax == "" ? "" : w:["active"] ? " ".&syntax." " : ""}'
        \.'%#StlDimNC#%{&syntax == "" ? "" : w:["active"] ? "" : " ".&syntax." "}'
        \.'%#ModeNoBold#%{w:["active"] ? " ".printf("%3d",line(".")).":".printf("%02d",virtcol("."))." " : ""}'
        \.'%0*%{w:["active"] ? "" : " ".printf("%3d",line(".")).":".printf("%02d",virtcol("."))." "}'
        \.'%0*' . a:extra . '%#Normal#'
endfunction

set statusline=%!BuildStatusLine(winnr(),'')
" }}}

""""""""""""""""""""""""""""""""""""""""""""""""
"              EXTENDING VIM
""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
" make list-like commands more intuitive
" including this here to avoid screwing up command mode
function! CCR() abort
  let cmdline = getcmdline()
  if cmdline =~? '\v\C^(ls|files|buffers)' | return "\<CR>:b "
  elseif cmdline =~? '\v\C^(dli|il)'       | return "\<CR>:".cmdline[0].'j  '.split(cmdline,' ')[1]."\<S-Left>\<Left>"
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
