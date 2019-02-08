if exists('b:current_syntax')
    finish
endif

syn iskeyword @,48-57,192-255,_,-

syn match xpathParam     "\w\+"                     display
syn match xpathReference "\$\@1<=\w[a-zA-Z0-9\-_]*" display
syn match xpathOperator  "\$"                       display
syn match xpathNameSpace '\w\+:\@='                 display
syn match xpathPunct     "[,/\[\]()]"               display
syn match xpathP2        "[:\.]"                    display
syn match xpathOperator  "[=\*@+-]"                  display
syn match xpathNumber    "[0-9]\+\>"                display
syn match xpathOperator  "[!=\>\<]\+"               display
syn keyword xpathOperator or and xor
syn keyword xpathLangVar body ctx trp

syn match xpathSpec "fn"

syn match   xmlEntity                 "&[^; \t]*;" contains=xmlEntityPunct display
syn match   xmlEntityPunct  contained "[&.;]" display

syn match xpathFuncError "\k\+" contained

syn match xpathFunction "\k\+(\@=" contains=xpathFuncName,xpathFuncError display

syn keyword xpathFuncName substring string-join string-length upper-case lower-case escape-uri starts-with ends-with contained
syn keyword xpathFuncName substring-before substring-after index-of get-property json-eval contained
syn match xpathFuncName "\<contains\>" contained display
syn keyword xpathFuncName number abs ceiling floor round string compare concat adjust-dateTime-to-timezone contained
syn keyword xpathFuncName matches replce boolean not true false dateTime name root remove empty exists reverse contained
syn keyword xpathFuncName subsequence count avg max min sum id node position last translate text format-dateTime contained
syn keyword xpathFuncName dayTimeDuration contained


" STRINGS
syn region xpathString matchgroup=xpathQuote start=+'+ end=+'+ display

hi def link xmlEntity		Statement
hi def link xmlEntityPunct	PreProc

function! s:hi(group, target) abort
  if &t_Co >= 256 || has('gui_running')
    let italic = 1
  else
    let italic = 0
  endif
  let t_fg = synIDattr(synIDtrans(hlID(a:target)), 'fg', 'cterm')
  let t_bg = synIDattr(synIDtrans(hlID(a:target)), 'bg', 'cterm')
  let t_fmt = synIDattr(synIDtrans(hlID(a:target)), 'reverse', 'cterm') ? 'reverse,' : ''
  let g_fg = synIDattr(synIDtrans(hlID(a:target)), 'fg', 'gui')
  let g_bg = synIDattr(synIDtrans(hlID(a:target)), 'bg', 'gui')
  let g_fmt = synIDattr(synIDtrans(hlID(a:target)), 'reverse', 'gui') ? 'reverse,' : ''
  let t_fg = t_fg ==? '' ? 'NONE' : t_fg
  let t_bg = t_bg ==? '' ? 'NONE' : t_bg
  let g_fg = g_fg ==? '' ? 'NONE' : g_fg
  let g_bg = g_bg ==? '' ? 'NONE' : g_bg
  execute 'highlight ' . a:group . ' ctermfg=' . t_fg . ' ctermbg=' . t_bg .
        \ ' guifg=' . g_fg . ' guibg=' . g_bg .
        \ (italic ? ' cterm=' . t_fmt . 'italic gui=' . g_fmt . 'italic' : '')
endfunction

function! s:xpathHighlight() abort

  call <SID>hi('xpathFuncError', 'Error')
  call <SID>hi('xpathQuote',     'StringDelimiter')
  call <SID>hi('xpathString',    'String')
  call <SID>hi('xpathFuncName',  'Function')
  call <SID>hi('xpathNumber',    'Constant')
  call <SID>hi('xpathParam',     'Builtin')
  call <SID>hi('xpathPunct',     'Delimiter')
  call <SID>hi('xpathLangVar',   'Language')
  call <SID>hi('xpathReference', 'StringDelimiter')
  call <SID>hi('xpathOperator',  'Operator')
  call <SID>hi('xpathP2',        'Delimiter')
  call <SID>hi('xpathSpec',      'Special')
  call <SID>hi('xpathNameSpace', 'Language')

  " call <SID>hi('Xpath',          'String')
  " call <SID>hi('xpathFuncError', 'String')
  " call <SID>hi('xpathQuote',     'String')
  " call <SID>hi('xpathString',    'String')
  " call <SID>hi('xpathFuncName',  'String')
  " call <SID>hi('xpathNumber',    'String')
  " call <SID>hi('xpathParam',     'String')
  " call <SID>hi('xpathPunct',     'String')
  " call <SID>hi('xpathLangVar',   'String')
  " call <SID>hi('xpathReference', 'String')
  " call <SID>hi('xpathOperator',  'String')
  " call <SID>hi('xpathP2',        'String')
  " call <SID>hi('xpathSpec',      'String')
  " call <SID>hi('xpathNameSpace', 'String')

endfunction
call s:xpathHighlight()

augroup xpathHighlight
  autocmd!
  autocmd ColorScheme * call s:xpathHighlight()
augroup END

let b:current_syntax = 'xpath'
