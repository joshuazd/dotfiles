let g:loaded_statusline = 1
if exists('g:loaded_statusline')
  finish
endif
let g:loaded_statusline = 1

let s:save_cpo = &cpo
set cpo&vim

if exists('+statusline')
  let in_snippet = 0
  let stl_snippet = ['', 'snippet']

  set statusline=%f\ %m%r%w%q%h%=
  set statusline+=%<%-20{stl_snippet[in_snippet]}
  if exists('*WebDevIconsGetFileTypeSymbol')
    set statusline+=%-20{WebDevIconsGetFileTypeSymbol()}
  else
    set statusline+=%-20{&filetype}
  endif
  set statusline+=%-15(%l,%c%V%)%P
endif

let g:in_snippet = 0
let stl_snippet = ['', 'snippet']

function! StatusLineColors() abort
  highlight StlDim       ctermbg=236 guibg=#303030 ctermfg=243 guifg=#767676 cterm=NONE gui=NONE
  highlight ReadOnlyStl  ctermbg=236 guibg=#303030 ctermfg=167 guifg=#d75f5f cterm=NONE gui=NONE
  highlight StatusLine   ctermbg=236 guibg=#303030 ctermfg=250 guifg=#bcbcbc cterm=NONE gui=NONE
  highlight StatusLineNC ctermbg=242 guibg=#6c6c6c ctermfg=234 guifg=#1c1c1c cterm=NONE gui=NONE
  highlight StlSection   ctermbg=236 guibg=#303030 ctermfg=75  guifg=#5fafff cterm=NONE gui=NONE
  highlight StlSectionInv ctermfg=236 guifg=#303030 ctermbg=75  guibg=#5fafff cterm=NONE gui=NONE
endfunction

augroup statusline
  autocmd!
  autocmd ColorScheme * call StatusLineColors()
augroup END
call StatusLineColors()

function! SetupStatusLine(nr) abort
  return get(extend(w:, { 'active' : winnr() == a:nr }), '', '') 
endfunction

function! BuildStatusLine(nr, extra) abort
  return '%{SetupStatusLine('.a:nr.')}'
        \.'%#StlSectionInv# %f %m%r%w%q%h%#StlSection#'
        \.'%0*%='
        \.'%<%-20{stl_snippet[in_snippet]}'
        \.'%-20{WebDevIconsGetFileTypeSymbol()}'
        \.'%#StlSection#%#StlSectionInv#%-10(%l,%c%V%) %P'
        " \.'%#StlDim#%{&syntax == "" ? "" : w:["active"] ? " ".&syntax." " : ""}'
        " \.'%#StatusLineNC#%{&syntax == "" ? "" : w:["active"] ? "" : " ".&syntax." "}'
        " \.'%#StlMode#%{w:["active"] ? " ".printf("%3d",line(".")).":".printf("%02d",virtcol("."))." " : ""}'
        " \.'%0*%{w:["active"] ? "" : " ".printf("%3d",line(".")).":".printf("%02d",virtcol("."))." "}'
        " \.'%0*' . a:extra . '%#Normal#'
endfunction

if exists('+statusline')
  set statusline=%!BuildStatusLine(winnr(),'')
endif

let &cpo = s:save_cpo
unlet s:save_cpo
