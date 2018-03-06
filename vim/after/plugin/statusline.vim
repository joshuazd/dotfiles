let g:in_snippet = 0
let g:modemap = {
      \ 'n' : ['N',       'NormalMode'],  'no': ['NO',    'NormalMode'],  'v' : ['V',       'VisualMode'],
      \ 'V' : ['V',       'VisualMode'],  '': ['V',     'VisualMode'],  's' : ['S',       'VisualMode'],
      \ 'S' : ['S',       'VisualMode'],  '': ['S',     'VisualMode'],  'i' : ['I',       'InsertMode'],
      \ 'ic': ['COMPL',   'InsertMode'],  'ix': ['X',     'InsertMode'],  'R' : ['R',       'ReplaceMode'],
      \ 'Rc': ['RCOMPL',  'ReplaceMode'], 'Rv': ['R',     'ReplaceMode'], 'Rx': ['RX',      'ReplaceMode'],
      \ 'c' : ['C',       'CommandMode'], 'cv': ['VIMEX', 'CommandMode'], 'ce': ['EX',      'CommandMode'],
      \ 'r' : ['P',       'CommandMode'], 'rm': ['MORE',  'CommandMode'], 'r?': ['CONFIRM', 'CommandMode'],
      \ '!' : ['SH',      'CommandMode'], 't' : ['TERM',  'CommandMode']}

function! GetModeIndicator() abort
  if &filetype ==# 'help'        | return ['Help']
  elseif &filetype ==# 'netrw'   | return ['netrw']
  elseif &filetype ==# 'dirvish' | return ['dirvish']
  else                           | return g:modemap[mode()]
  endif
endfunction

let g:mode_hi = {
      \'NormalMode'  : ' ctermfg=68  guifg=#6182b8 ctermbg=235 guibg=#262626',
      \'InsertMode'  : ' ctermfg=221 guifg=#ffcb6b ctermbg=235 guibg=#262626',
      \'VisualMode'  : ' ctermfg=107 guifg=#91b859 ctermbg=235 guibg=#262626',
      \'ReplaceMode' : ' ctermfg=167 guifg=#d75f5f ctermbg=235 guibg=#262626',
      \'CommandMode' : ' ctermfg=176 guifg=#c792ea ctermbg=235 guibg=#262626'}

function! s:updateStatusLineHighlight(nr,newMode) abort
  execute 'hi! CurrMode ' . g:mode_hi[get(g:modemap, a:newMode, ['', a:newMode])[1]] . ' cterm=bold gui=bold'
  execute 'hi! ModeNoBold '.g:mode_hi[get(g:modemap, a:newMode, ['', a:newMode])[1]] . ' cterm=none gui=none'
  return 1
endfunction

function! StatusLineColors() abort
  highlight StlDim       ctermbg=235 guibg=#262626 ctermfg=242 guifg=#6c6c6c cterm=NONE gui=NONE
  highlight StlDimNC     ctermbg=242 guibg=#6c6c6c ctermfg=235 guifg=#262626 cterm=NONE gui=NONE
  highlight ReadOnlyStl  ctermbg=235 guibg=#262626 ctermfg=167 guifg=#d75f5f cterm=NONE gui=NONE
  highlight StatusLine   ctermbg=235 guibg=#262626 ctermfg=252 guifg=#d0d0d0 cterm=NONE gui=NONE
  highlight StatusLineNC ctermbg=242 guibg=#6c6c6c ctermfg=234 guifg=#1c1c1c cterm=NONE gui=NONE
  highlight StlLinter    ctermbg=1   guibg=#e53935 ctermfg=234 guifg=#1c1c1c cterm=NONE gui=NONE
  call s:updateStatusLineHighlight(winnr(),mode())
endfunction

call StatusLineColors()

augroup statusline
  autocmd!
  autocmd ColorScheme * call StatusLineColors()
augroup END

function! TagsStatusLine() abort
  return (!exists('*gutentags#statusline') ? '' : gutentags#statusline())
endfunction

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

function! BuildStatusLine(nr, extra) abort
  return '%{SetupStatusLine('.a:nr.')}
        \%#CurrMode#%{w:["lf_active"] ? "  " . GetModeIndicator()[0] . (&paste ? " PASTE " : " ") : ""}
        \%0* %f%m
        \%#ReadOnlyStl#%{&readonly && w:["lf_active"] ? " RO" : ""}%0*
        \%=
        \%{g:in_snippet > 0 ? "snippet" : ""} %{w:["lf_active"] ? TagsStatusLine() != "" ? " ".TagsStatusLine()." " : " " : " "}
        \%#StlDim#%{&syntax == "" ? "" : w:["lf_active"] ? " ".&syntax." " : ""}
        \%#StlDimNC#%{&syntax == "" ? "" : w:["lf_active"] ? "" : " ".&syntax." "}
        \%#ModeNoBold#%{w:["lf_active"] ? " ".printf("%3d",line(".")).":".printf("%02d",virtcol("."))." " : ""}
        \%0*%{w:["lf_active"] ? "" : " ".printf("%3d",line(".")).":".printf("%02d",virtcol("."))." "}
        \%0*' . a:extra
endfunction

set statusline=%!BuildStatusLine(winnr(),'')
