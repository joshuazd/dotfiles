set nocompatible

" Plugins {{{
" filetype off
call plug#begin('~/.vim/bundle')

Plug 'w0rp/ale'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'vim-scripts/c.vim'
Plug 'junegunn/goyo.vim'
Plug 'davidhalter/jedi-vim'
Plug 'wting/gitsessions.vim'
Plug 'luochen1990/rainbow'
Plug 'gerw/vim-HiLinkTrace'
Plug 'vim-airline/vim-airline'
Plug 'easymotion/vim-easymotion'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'tmux-plugins/vim-tmux'
Plug 'vim-airline/vim-airline-themes'
Plug 'Shougo/neosnippet'
Plug 'Shougo/neosnippet-snippets'
Plug 'justmao945/vim-clang'
Plug 'shougo/neocomplete.vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'godlygeek/tabular'
Plug 'tpope/vim-sleuth'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-commentary'
Plug 'Konfekt/FastFold'
Plug 'ehamberg/vim-cute-python'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
if has("win32unix") || $USER ==? "vagrant"
    Plug 'pearofducks/ansible-vim'
endif

call plug#end()
runtime macros/matchit.vim
" }}}

""""""""""""""""""""""""""""""""""""""""""""""""
"              GENERAL OPTIONS
""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
set ruler                       " Always show current position
set cmdheight=1                 " Height of the command bar
set hidden                      " A buffer becomes hidden when it is abandoned
set backspace=eol,start,indent  " Configure backspace so it acts as it should act
set whichwrap+=<,>,h,l          " arrow keys and h,l move to the next line
set breakindent                 " Indent wrapped lines by 2
set breakindentopt=shift:2
set ignorecase                  " Ignore case when searching
set smartcase                   " When searching try to be smart about cases
set hlsearch                    " Highlight search results
set incsearch                   " Makes search act like search in modern browsers
set lazyredraw                  " Don't redraw while executing macros (good performance config)
set magic                       " For regular expressions turn magic on
set showmatch                   " Show matching brackets when text indicator is over them
set mat=2                       " How many tenths of a second to blink when matching brackets
set noerrorbells                " No annoying sound on errors
set novisualbell
set t_vb=
set tm=500
set splitbelow                  " Make splits behave better
set splitright
set background=dark             " dark background
syntax on                       " turn syntax on
colorscheme hybrid_material     " material color scheme
set number                      " show line numbers
set relativenumber              " show relative line numbers
set numberwidth=1               " set min number column width
set clipboard=unnamed           " make clipboard work better
set tabstop=4                   " <TAB>s are 4 spaces
set softtabstop=4               " number of spaces when inserting/backspacing
set shiftwidth=4                " shift 4 spaces for indentation
set expandtab                   " expand tabs into spaces
set autoindent                  " use the previous lines indentation level
set noshowmode                  " don't show mode in the statusline
set nowrap                      " don't wrap lines by default
set laststatus=2                " always show statusline
set cindent                     " better indentation
set cinkeys-=0#
set indentkeys-=0#
set so=999                      " Set 999 lines to the cursor - when moving vertically using j/k
set sidescroll=1                " scroll 1 character at a time
set sidescrolloff=15            " scroll within 15 characters
set foldmethod=syntax           " fold based on syntax
set foldnestmax=2               " no nesting folds
set wildmenu                    " Turn on the WiLd menu
set wildmode=longest,list
set wildignore+=*.o,*~,*.pyc,*.versionsBackup,*/target/*,*/bin/* " Ignore compiled files
au FileType * set fo-=o         " Don't insert comment when using 'o'
set sessionoptions-=options     " make sessions work better with plugins
set sessionoptions-=folds
let g:is_posix = 1
set backupdir=/tmp              " Better backups
set noswapfile
set foldlevel=12                " don't fold most things
set listchars=tab:>-,trail:~,extends:>,space:.,eol:$ " what to show for whitespace chars
set term=xterm-256color
set omnifunc=syntaxcomplete#Complete    " enable omnicompletion
" set completeopt+=longest
set completeopt+=menuone
set concealcursor+=n            " conceal characters in normal mode
set conceallevel=2              " conceal characters by default
set autowrite                   " automatically save before :next, :make, etc
set autoread                    " automatically reread changed files
if has("gui_running")
    set guifont=Literation\ Mono\ Powerline\ 14
    set guioptions-=T
    set guioptions+=e
    set guioptions-=m
    set guioptions-=r
    set guioptions-=L
    set guitablabel=%M\ %t
    set lines=35 columns=120
endif
let g:hybrid_custom_term_colors=1
let g:xml_syntax_folding=1 " enable xml folding
" }}}

""""""""""""""""""""""""""""""""""""""""""""""""
"              KEYBINDINGS
""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
let mapleader = "\<Space>" " make leader a more sane keybinding
let maplocalleader = "," " remap localleader
" make 0 work better
nnoremap 0 ^
nnoremap ^ 0
" Make moving around splits easier
nnoremap <silent> <Leader>v :vs\|bn<CR>
nnoremap <silent> <Leader>s :sp\|bn<CR>
" Make <Leader>q clear highlighting from searches
nnoremap <silent> <Leader>q :noh<return><esc>
" make it easier to use buffers
if has("gui_running")
    nnoremap <M-d> :bn<CR>
    nnoremap <M-a> :bp<CR>
else
    nnoremap <Esc>d :bn<CR>
    nnoremap <Esc>a :bp<CR>
endif
nnoremap <silent> <Leader><Leader> :b#<CR>
" more standard 'close tab' behavior
nnoremap <silent> <C-x> :bn\|bd #<CR>
" treat wrapped lines as different lines
noremap j gj
noremap k gk
noremap gj j
noremap gk k
" easier to go to end/beginning of lines
noremap L $
noremap H ^
" Buffer keymappings
nnoremap <silent> <Leader>1 :1b<CR>
nnoremap <silent> <Leader>2 :2b<CR>
nnoremap <silent> <Leader>3 :3b<CR>
nnoremap <silent> <Leader>4 :4b<CR>
nnoremap <silent> <Leader>5 :5b<CR>
nnoremap <silent> <Leader>6 :6b<CR>
nnoremap <silent> <Leader>7 :7b<CR>
nnoremap <silent> <Leader>8 :8b<CR>
nnoremap <silent> <Leader>9 :9b<CR>
nnoremap <silent> <Leader>0 :10b<CR>

if has("gui_running")
    nnoremap <silent> <M-1> :1b<CR>
    nnoremap <silent> <M-2> :2b<CR>
    nnoremap <silent> <M-3> :3b<CR>
    nnoremap <silent> <M-4> :4b<CR>
    nnoremap <silent> <M-5> :5b<CR>
    nnoremap <silent> <M-6> :6b<CR>
    nnoremap <silent> <M-7> :7b<CR>
    nnoremap <silent> <M-8> :8b<CR>
    nnoremap <silent> <M-9> :9b<CR>
    nnoremap <silent> <M-0> :10b<CR>
else
    nnoremap <silent> <Esc>1 :1b<CR>
    nnoremap <silent> <Esc>2 :2b<CR>
    nnoremap <silent> <Esc>3 :3b<CR>
    nnoremap <silent> <Esc>4 :4b<CR>
    nnoremap <silent> <Esc>5 :5b<CR>
    nnoremap <silent> <Esc>6 :6b<CR>
    nnoremap <silent> <Esc>7 :7b<CR>
    nnoremap <silent> <Esc>8 :8b<CR>
    nnoremap <silent> <Esc>9 :9b<CR>
    nnoremap <silent> <Esc>0 :10b<CR>
endif
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
noremap <silent> <C-f> :CtrlPLine<CR>
" paste and format
nnoremap <silent> <Leader>p p=']
nnoremap <silent> <Leader>P P=']
noremap <silent> <F5> :call VimRefresh()<CR>
function! VimRefresh()
    CtrlPClearAllCaches
    AirlineRefresh
    ALEToggle
    ALEToggle
    GitGutterToggle
    GitGutterToggle
    NeoCompleteClean
    NeoCompleteBufferMakeCache
    NeoCompleteMemberMakeCache
endfunction
" }}}

""""""""""""""""""""""""""""""""""""""""""""""""
"              AUTOCOMMANDS
""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
augroup EditVim
    autocmd!
    autocmd InsertLeave * if pumvisible() == 0|pclose|endif " Close preview window when leaving insert mode
    autocmd FileType xml call XmlSetup()
    autocmd BufNewFile,BufRead *.zsh-theme set filetype=zsh
    autocmd BufNewFile,BufRead *.dbs set filetype=xml
    autocmd BufNewFile,BufRead *.dmc set filetype=javascript
    autocmd FileType python setlocal foldmethod=indent
    autocmd FileType vim setlocal foldmethod=marker foldlevel=0
    "make folding work better with insert mode
    " autocmd InsertEnter * if !exists('w:last_fdm') | let w:last_fdm=&foldmethod | setlocal foldmethod=manual | endif
    " autocmd InsertLeave,WinLeave * if exists('w:last_fdm') | let &l:foldmethod=w:last_fdm | unlet w:last_fdm | endif
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
augroup END

function! TrimWhiteSpace()
    %s/\s\+$//e
    ''
endfunction
command! TrimWhiteSpace call TrimWhiteSpace()

function! ToggleConceal()
    if &conceallevel == 0
        set conceallevel=2
    else
        set conceallevel=0
    endif
endfunction

function! XmlSetup()
    setlocal shiftwidth=2
    setlocal tabstop=2
    setlocal softtabstop=2
    setlocal noexpandtab
    setlocal foldmethod=syntax
    setlocal smarttab
    inoremap <expr> </ pumvisible() ? "\</\<C-x>\<C-o>\<C-y>" : "\</\<C-x>\<C-o>"
    command! Tabs setlocal shiftwidth=2 tabstop=2 softtabstop=2 noexpandtab foldmethod=syntax smarttab
endfunction
" }}}


""""""""""""""""""""""""""""""""""""""""""""""""
"              PLUGIN SETUP
""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
" netrw setup {{{
    let g:netrw_winsize = -28
    let g:netrw_banner = 0
    let g:netrw_liststyle = 3
    let g:netrw_browse_split = 4
" }}}

" neocomplete setup {{{
    let g:neocomplete#enable_at_startup = 1
    let g:neocomplete#enable_smart_case = 1
    let g:neocomplete#enable_auto_select = 1
    " let g:neocomplete#enable_refresh_always = 1
    let g:neocomplete#auto_complete_delay = 0
    imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
                \ "\<Plug>(neosnippet_expand_or_jump)"
                \: pumvisible() ? "\<CR>" : "\<TAB>"
    smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
                \ "\<Plug>(neosnippet_expand_or_jump)"
                \: "\<TAB>"
    imap <expr><CR> neosnippet#expandable() ?
                \ "\<Plug>(neosnippet_expand)" : "\<CR>\<Plug>AutoPairsReturn"
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
        autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
        let g:neocomplete#keyword_patterns.xml =
                    \'</\?\%([[:alnum:]_:-]\+\s*\)\?\%(/\?>\)\?\|&\h\%(\w*;\)\?'.
                    \'\|\h\w*'
        let g:neocomplete#force_omni_input_patterns.xml = '</\?' "'\|\s[A-Za-z0-9=\-]*'
        call neocomplete#custom#source('omni', 'rank', 1000)
    " }}}

    " python setup {{{
        autocmd FileType python setlocal omnifunc=jedi#completions
        let g:jedi#completions_enabled = 0
        let g:jedi#auto_vim_configuration = 0
        let g:jedi#smart_auto_mappings = 0
        let g:neocomplete#force_omni_input_patterns.python = '\%([^. \t]\.\|^\s*@\|^\s*from\s.\+import \|^\s*from \|^\s*import \)\w*'
    " }}}

    " clang setup {{{
        let g:clang_auto = 0 " disable auto completion for vim-clang
        let g:clang_c_completeopt = 'longest,menuone,preview' " default 'longest' can not work with neocomplete
        let g:clang_cpp_completeopt = 'longest,menuone,preview'
        autocmd FileType c setlocal omnifunc=ClangComplete
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
" }}}

" Ansible setup {{{
    let g:ansible_unindent_after_newline = 1
    let g:ansible_attribute_highlight = "a"
    let g:ansible_extra_keywords_highlight = 1
" }}}

" ALE setup {{{
    nmap <silent> ]e <Plug>(ale_next_wrap)
    nmap <silent> [e <Plug>(ale_previous_wrap)
    let g:ale_python_flake8_options = '--max-line-length 99'
    let g:ale_virtualenv_dir_names = []
    let g:ale_lint_on_text_changed = 'normal'

    let g:ale_fixers = {
                \   'python': [
                \       'autopep8',
                \       'yapf'
                \   ]
                \}
    nnoremap <F12> :ALEFix<CR>
" }}}

" Jedi setup {{{
    let g:jedi#show_call_signatures = 2
" }}}

" Goyo setup {{{
    function! s:goyo_enter()
        set showmode
    endfunction

    function! s:goyo_leave()
        set noshowmode
    endfunction

    autocmd! User GoyoEnter nested call <SID>goyo_enter()
    autocmd! User GoyoLeave nested call <SID>goyo_leave()
" }}}

" Easymotion setup {{{
    map <Leader> <Plug>(easymotion-prefix)
"    nmap s <Plug>(easymotion-overwin-f)
    map / <Plug>(easymotion-sn)
    omap / <Plug><easymotion-tn)
    let g:EasyMotion_startofline = 0
" }}}

" ctrlP setup {{{
set runtimepath^=~/.vim/bundle/ctrlp.vim
let g:ctrlp_open_multiple_files = 'ri'
let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_cmd = 'CtrlP'

let g:ctrlp_by_filename = 1
let g:ctrlp_switch_buffer = 'et'
" }}}

" AutoPairs setup {{{
    let g:AutoPairsMapCR = 0
" }}}

" rainbow parens {{{
let g:rainbow_active = 1

let g:rainbow_conf = {
            \ 'ctermfgs': [14, 11, 2, 9, 6, 5],
            \ 'separately': {
            \   'xml': 0,
            \   'vim': 0,
            \   'python': 0,
            \   'sh': 0,
            \   'c': 0,
            \   'javascript': 0
            \  }
            \}
" }}}

" Airline setup {{{
    let g:airline#extensions#tabline#enabled = 1
    let g:airline#extensions#tabline#buffer_nr_show = 1
    let g:airline#extensions#tabline#formatter = 'unique_tail'
    let g:airline#extensions#tabline#buffer_min_count = 2
    let g:airline_section_c = '%t'
    let g:airline_section_x = ''
    let g:airline_section_y = '%y %{&ff}'
    " let g:airline_section_z = '%3l:%2c'
    let g:airline_section_z = '%2c'
    "let g:airline_section_error = ''
    "let g:airline_section_warning = ''
    let g:airline#extensions#hunks#non_zero_only = 1


    let g:airline_mode_map = {
                \ '__' : '-',
                \ 'n'  : 'N',
                \ 'i'  : 'I',
                \ 'R'  : 'R',
                \ 'c'  : 'C',
                \ 'v'  : 'V',
                \ 'V'  : 'V',
                \ '' : 'V',
                \ 's'  : 'S',
                \ 'S'  : 'S',
                \ '' : 'S',
                \ }

    let g:airline#extensions#default#section_truncate_width = {
           \ 'b': 59,
           \ 'x': 79,
           \ 'y': 69,
           \ 'z': 39,
           \ 'warning': 69,
           \ 'error': 69,
           \ }

    let g:airline_powerline_fonts = 1

    if !exists('g:airline_symbols')
        let g:airline_symbols = {}
    endif
    let g:airline_skip_empty_sections = 1
    let g:airline_theme='material'

    if has("gui_running")
        " unicode symbols
        " let g:airline_left_sep = '»'
        "let g:airline_left_sep = '▶'
        " let g:airline_right_sep = '«'
        "let g:airline_right_sep = '◀'
        " let g:airline_symbols.crypt = '🔒'
        " let g:airline_symbols.linenr = '␊'
        " let g:airline_symbols.linenr = '␤'
        let g:airline_symbols.linenr = '¶'
        let g:airline_symbols.maxlinenr = '☰'
        " let g:airline_symbols.maxlinenr = ''
        " let g:airline_symbols.branch = '⎇'
        let g:airline_symbols.branch = ''
        " let g:airline_symbols.paste = 'ρ'
        let g:airline_symbols.paste = 'Þ'
        " let g:airline_symbols.paste = '∥'
        let g:airline_symbols.spell = 'Ꞩ'
        let g:airline_symbols.notexists = '∄'
        let g:airline_symbols.whitespace = 'Ξ'
    else
        "let g:airline_right_sep = ''
        "let g:airline_left_sep = ''
        let g:airline_symbols.linenr = '¶'
        let g:airline_symbols.maxlinenr = '☰'
        " let g:airline_symbols.maxlinenr = ''
        " let g:airline_symbols.branch = '⎇'
        " let g:airline_symbols.branch = ''
        let g:airline_symbols.branch = ''
        "let g:airline_symbols.branch = '⌥'
        " let g:airline_symbols.paste = 'ρ'
        let g:airline_symbols.paste = 'Þ'
        " let g:airline_symbols.paste = '∥'
        let g:airline_symbols.spell = 'Ꞩ'
        let g:airline_symbols.notexists = '∄'
        let g:airline_symbols.whitespace = 'Ξ'
    endif
" }}}
" }}}
