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
if has('pythonx')
  Packadd! ultisnips
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
set wildmode=list:longest,list:full
set wildignorecase
set wildignore+=*.o,*~,*.pyc,*.versionsBackup
set wildignore+=*target/*,*bin/*,*build/*
set wildignore+=tags,Session.vim
set foldmethod=marker
set foldlevelstart=99
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

if exists('&previewpopup')
  set previewpopup=height:10,width:60
  set completeopt+=popup
endif

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
nnoremap <BS> <C-^>g`"
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
nnoremap <Space>ff :find<space>
nnoremap <Space>fs :sfind<space>
nnoremap <Space>fv :vert sfind<space>
nnoremap <Space>e :e <C-r>=fnameescape(expand('%:p:h'))<CR>/<C-z>
nnoremap <Space>t :tjump /

nnoremap <Space>;l :set colorcolumn=
nnoremap <Space>q m":source $MYVIMRC<CR>:doautocmd VimEnter<CR>
nnoremap <Space>;g :g/\v/#<Left><Left>
xnoremap <Space>;g "ay:g/\V<C-r>=escape(@a,'\/')<CR>/#<CR>:
nnoremap <Space>;i :ilist /
nnoremap <Space>;r :%s/<C-r><C-w>//g<Left><Left>
xnoremap <Space>;r "ay:<C-u>%s/\V<C-r>=substitute(escape(@a,'\\/'),'<C-v><C-@>','','')<CR>//g<Left><Left>
nnoremap <Esc>OA <Up>
nnoremap <silent> <nowait> <Esc> :<C-u>nohlsearch<CR>

" vim-unimpaired inspired settings toggles
nnoremap =on :setlocal number!         <Bar>setlocal number?<CR>
nnoremap =or :setlocal relativenumber! <Bar>setlocal relativenumber?<CR>
nnoremap =ow :setlocal wrap!           <Bar>setlocal wrap?<CR>
nnoremap =oz :setlocal list!           <Bar>setlocal list?<CR>
nnoremap =os :setlocal spell!          <Bar>setlocal spell?<CR>
nnoremap =oh :setlocal hlsearch!       <Bar>setlocal hlsearch?<CR>
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

nnoremap <silent> <space>] :call tag#get('<C-r><C-w>')<CR>

nnoremap <silent> <space>gb :GB<CR>
xnoremap <silent> <space>gb :GB<CR>

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
  autocmd User FugitiveBoot               setl signcolumn=auto
  autocmd User FugitiveBoot               let &l:grepprg='git grep -n --no-color'
        \| let &l:grepformat='%f:%l:%c:%m,%f:%l:%m,%m %f match%ts,%f'
  autocmd BufNewFile  */plugin/*.vim      0r ~/.vim/skeleton.vim|call skeleton#replace()|call skeleton#edit()
  if exists('##TextYankPost') && executable('base64')
    autocmd TextYankPost     *            if v:event.operator ==# 'y' | silent! call clip#osc52() | endif
  endif
augroup END

command! TrimWhiteSpace call whitespace#TrimWhiteSpace()
command! -range=% AnsibleEdit <line1>,<line2>yank a|silent! call ansible#AnsibleEdit()
command! AnsibleCrypt call ansible#AnsibleEncrypt()
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
let g:lsc_reference_highlights = 0
let g:lsc_enable_autocomplete = 0
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
let g:lsc_server_commands = {
      \ 'java': {
        \ 'command': 'java-language-server',
        \ 'log_level': 'Warning',
        \ 'response_hooks': {
        \   'textDocument/codeAction': function('<SID>fixEdits'),
        \ }
        \}
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
let g:mucomplete#no_mappings            = 1
let g:mucomplete#no_popup_mappings      = 1
let g:mucomplete#always_use_completeopt = 1
let g:mucomplete#chains                 = {
      \ 'default'   : ['file', 'omni', 'ulti', 'dict', 'uspl', 'c-p', 'tags'],
      \ 'gitcommit' : ['tags', 'c-n'],
      \ 'java'      : ['omni', 'ulti', 'c-p',  'tags', 'file'],
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
let g:netrw_liststyle = 0
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
let g:todo_words = [['TODO', '|', 'DONE'], ['ASSIGNED', 'DEVELOP', 'TESTING', '|', 'READY', 'COMPLETE']]
if executable('python3')
  let g:python_executable = 'python3'
  let g:jedi#force_py_version = 3
endif
" FZF
let g:fzf_files_options = ['--preview', 'fzf_preview {} 2>/dev/null']
let g:fzf_buffers_options = ['--preview', 'fzf_preview {2} 2>/dev/null']

function! s:hl() abort
  hi link lscDiagnosticWarning WarningMsg
endfunction
call <SID>hl()
augroup custom_hi
  autocmd!
  autocmd ColorScheme * call <SID>hl()
augroup END
" }}}

fu s:snr() abort
    return matchstr(expand('<sfile>'), '.*\zs<SNR>\d\+_')
endfu
let s:snr = get(s:, 'snr', s:snr())
let g:fzf_layout = {'window': 'call '.s:snr.'fzf_window(0.9, 0.6, "Comment")'}

inoremap <expr> <c-j> complete#fzf_tags()

fu s:fzf_window(width, height, border_highlight) abort
    let width = float2nr(&columns * a:width)
    let height = float2nr(&lines * a:height)
    let row = float2nr((&lines - height) / 2)
    let col = float2nr((&columns - width) / 2)
    let top = '┌' . repeat('─', width - 2) . '┐'
    let mid = '│' . repeat(' ', width - 2) . '│'
    let bot = '└' . repeat('─', width - 2) . '┘'
    let border = [top] + repeat([mid], height - 2) + [bot]
    let frame = s:create_popup_window(a:border_highlight, {
        \ 'line': row,
        \ 'col': col,
        \ 'width': width,
        \ 'height': height,
        \ 'is_frame': 1,
        \ })
    call setbufline(frame, 1, border)
    call s:create_popup_window('Normal', {
        \ 'line': row + 1,
        \ 'col': col + 2,
        \ 'width': width - 4,
        \ 'height': height - 2,
        \ })
endfu

fu s:create_popup_window(hl, opts) abort
    if has_key(a:opts, 'is_frame')
        let id = popup_create('', {
            \ 'line': a:opts.line,
            \ 'col': a:opts.col,
            \ 'minwidth': a:opts.width,
            \ 'minheight': a:opts.height,
            \ 'zindex': 50,
            \ })
        call setwinvar(id, '&wincolor', a:hl)
        exe 'au BufWipeout * ++once call popup_close('.id.')'
        return winbufnr(id)
    else
        let buf = term_start(&shell, {'hidden': 1})
        call popup_create(buf, {
            \ 'line': a:opts.line,
            \ 'col': a:opts.col,
            \ 'minwidth': a:opts.width,
            \ 'minheight': a:opts.height,
            \ 'zindex': 51,
            \ })
        exe 'au BufWipeout * ++once bw! '.buf
    endif
endfu

