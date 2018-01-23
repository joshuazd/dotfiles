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
    if !exists('*GitGutterGetHunkSummary')
        return ''
    endif
    let l:githunks = GitGutterGetHunkSummary()
    let l:returnval = ' '
    let l:returnval .= (l:githunks[0] != 0 ? ' ' . l:githunks[0] . '+' : '')
    let l:returnval .= (l:githunks[1] != 0 ? ' ' . l:githunks[1] . '~' : '')
    let l:returnval .= (l:githunks[2] != 0 ? ' ' . l:githunks[2] . '-' : '')
    return l:returnval ==# ' ' ? '' : l:returnval
endfunction
function! GitStatusLine() abort
    if !exists('*fugitive#head')
        return ''
    endif
    let l:gitstatus = (fugitive#head() !=# '' ? ' ' . fugitive#head() : '')
    let l:githunks = GitHunks()
    let l:gitline = ''
    let l:gitline .= (l:githunks !=# '' ? l:githunks : '')
    let l:gitline .= (l:gitstatus !=# '' ? (l:gitline ==# '' ? ' ' : '') . l:gitstatus : '')
    let l:gitline .= (l:gitline !=# '' ? ' ' : '')
    return l:gitline
endfunction
function! ObsessionStatusLine() abort
    if !exists('*ObsessionStatus')
        return ''
    else
        return ObsessionStatus('$')
    endif
endfunction
function! TagsStatusLine() abort
    if !exists('*gutentags#statusline')
        return ''
    else
        return gutentags#statusline()
    endif
endfunction
function! QfList() abort
    if !exists('*qf#GetList')
        return ''
    endif
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
function! BuildStatusLine(nr) abort
  return '%{SetupStatusLine('.a:nr.')}
        \%#CurrMode#%{w:["lf_active"] ? "  " . GetModeIndicator()[0] . (&paste ? " PASTE " : " ") : ""}
        \%#StlGit#%{w:["lf_active"] ? GitStatusLine() : ""}
        \%#MainStl# %f%m
        \%#ReadOnlyStl# %{&readonly ? "RO" : ""}%#MainStl#
        \%=
        \%{ObsessionStatusLine()}%{w:["lf_active"] ? TagsStatusLine() != "" ? " ".TagsStatusLine()." " : " " : " "}
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
