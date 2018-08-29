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
syn keyword xpathFuncName subsequence count avg max min sum id position last translate text format-dateTime contained
syn keyword xpathFuncName dayTimeDuration contained


" STRINGS
syn region xpathString matchgroup=xpathQuote start=+'+ end=+'+ display

hi def link xmlEntity		Statement
hi def link xmlEntityPunct	PreProc

function! s:hi(group, target) abort
  let l:t_fg = synIDattr(synIDtrans(hlID(a:target)), 'fg', 'cterm')
  let l:t_bg = synIDattr(synIDtrans(hlID(a:target)), 'bg', 'cterm')
  let l:g_fg = synIDattr(synIDtrans(hlID(a:target)), 'fg', 'gui')
  let l:g_bg = synIDattr(synIDtrans(hlID(a:target)), 'bg', 'gui')
  let l:t_fg = l:t_fg ==? '' ? 'NONE' : l:t_fg
  let l:t_bg = l:t_bg ==? '' ? 'NONE' : l:t_bg
  let l:g_fg = l:g_fg ==? '' ? 'NONE' : l:g_fg
  let l:g_bg = l:g_bg ==? '' ? 'NONE' : l:g_bg
  execute 'highlight ' . a:group . ' ctermfg=' . l:t_fg . ' ctermbg=' . l:t_bg .
        \ ' guifg=' . l:g_fg . ' guibg=' . l:g_bg .
        \ ' cterm=italic gui=italic'
endfunction

function! s:xpathHighlight() abort

  " call <SID>hi('xpathFuncError', 'Error')
  " call <SID>hi('xpathQuote',     'StringDelimiter')
  " call <SID>hi('xpathString',    'String')
  " call <SID>hi('xpathFuncName',  'Function')
  " call <SID>hi('xpathNumber',    'Constant')
  " call <SID>hi('xpathParam',     'Builtin')
  " call <SID>hi('xpathPunct',     'Delimiter')
  " call <SID>hi('xpathLangVar',   'Language')
  " call <SID>hi('xpathReference', 'StringDelimiter')
  " call <SID>hi('xpathOperator',  'Operator')
  " call <SID>hi('xpathP2',        'Delimiter')
  " call <SID>hi('xpathSpec',      'Special')
  " call <SID>hi('xpathNameSpace', 'Language')

  call <SID>hi('Xpath',          'String')
  call <SID>hi('xpathFuncError', 'String')
  call <SID>hi('xpathQuote',     'String')
  call <SID>hi('xpathString',    'String')
  call <SID>hi('xpathFuncName',  'String')
  call <SID>hi('xpathNumber',    'String')
  call <SID>hi('xpathParam',     'String')
  call <SID>hi('xpathPunct',     'String')
  call <SID>hi('xpathLangVar',   'String')
  call <SID>hi('xpathReference', 'String')
  call <SID>hi('xpathOperator',  'String')
  call <SID>hi('xpathP2',        'String')
  call <SID>hi('xpathSpec',      'String')
  call <SID>hi('xpathNameSpace', 'String')

endfunction
call s:xpathHighlight()

augroup xpathHighlight
  autocmd!
  autocmd ColorScheme * call s:xpathHighlight()
augroup END

let b:current_syntax = 'xpath'
