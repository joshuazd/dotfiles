if exists('b:current_syntax')
    finish
endif

syn iskeyword @,48-57,192-255,_,-

syn match xpathParam "\w\+" display
syn match xpathReference "\$\@<=\w[a-zA-Z0-9\-_]*" display
syn match xpathOperator "\$" display
syn keyword xpathLangVar body ctx trp
syn match xpathNameSpace '\w\+:\@=' display
syn match xpathPunct "[,/\[\]()]" display
syn match xpathP2 "[:\.]" display
syn match xpathOperator "[=\*@+]" display
syn keyword xpathOperator or and xor
syn match xpathOperator "[!=\>\<]\+" display
syn match xpathNumber "\<[0-9]\+\>" display

syn match xpathSpec "fn"

syn match   xmlEntity                 "&[^; \t]*;" contains=xmlEntityPunct display
syn match   xmlEntityPunct  contained "[&.;]" display

syn match xpathFunction "\k\+(\@=" contains=xpathFuncName,xpathFuncError display

syn keyword xpathFuncName substring string-join string-length upper-case lower-case escape-uri starts-with ends-with contained
syn keyword xpathFuncName substring-before substring-after index-of get-property json-eval contained
syn match xpathFuncName "\<contains\>" contained
syn keyword xpathFuncName number abs ceiling floor round string compare concat adjust-dateTime-to-timezone contained
syn keyword xpathFuncName matches replce boolean not true false dateTime name root remove empty exists reverse contained
syn keyword xpathFuncName subsequence count avg max min sum id position last translate text format-dateTime contained
syn keyword xpathFuncName dayTimeDuration contained

syn match xpathFuncError "\k\+" contained

" STRINGS
syn region xpathString matchgroup=xpathQuote start=+'+ end=+'+ display

hi def link xmlEntity		Statement
hi def link xmlEntityPunct	PreProc

hi def link xpathFuncError Error

highlight xpathQuote ctermfg=156 cterm=italic
" hi def link xpathString String
highlight xpathString ctermfg=10 cterm=italic guifg=#91b859 gui=italic
" hi def link xpathFunction Function
highlight xpathFuncName ctermfg=12 cterm=italic guifg=#82aaff gui=italic
" hi def link xpathNumber Constant
highlight xpathNumber ctermfg=6 cterm=italic guifg=#39adb5 gui=italic
" hi def link xpathParam Identifier
highlight xpathParam ctermfg=11 cterm=italic guifg=#ffcb6b gui=italic
"hi def link xpathPunct PreProc
highlight xpathPunct ctermfg=14 cterm=italic guifg=#89ddff gui=italic
" hi def link xpathLangVar Type
highlight xpathLangVar ctermfg=3 cterm=italic guifg=#ffb62c gui=italic
highlight xpathReference ctermfg=156 cterm=italic guifg=#afff87 gui=italic
highlight xpathOperator ctermfg=137 cterm=italic guifg=#ab7967 gui=italic
highlight xpathP2 ctermfg=8 cterm=italic guifg=#3e515b gui=italic
highlight xpathSpec ctermfg=1 cterm=italic guifg=#e53935 gui=italic
hi def link xpathNameSpace Primitive
