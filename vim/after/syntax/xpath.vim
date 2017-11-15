if exists("b:current_syntax")
    finish
endif


syn match xpathParam "\w\+"
syn match xpathReference "\$\@<=\w[a-zA-Z0-9\-_]*"
syn match xpathOperator "\$"
syn keyword xpathLangVar body ctx trp
syn match xpathNameSpace '\w\+:\@='
syn match xpathPunct "[,/\[\]()]"
syn match xpathP2 "[:\.]"
syn match xpathOperator "[=\*@+]"
syn keyword xpathOperator or and xor
syn match xpathOperator "[!=\>\<]\+"
syn match xpathNumber "\<[0-9]\+\>"

syn match xpathSpec "fn"

syn match   xmlEntity                 "&[^; \t]*;" contains=xmlEntityPunct
syn match   xmlEntityPunct  contained "[&.;]"

syn match xpathFunction "\(substring\|string\-join\|string\-length\|upper\-case\|lower\-case\|escape\-uri\|starts\-with\|ends\-with\)(\@="
syn match xpathFunction "\(substring\-before\|substring\-after\|index\-of\|get\-property\|json\-eval\|contains\)(\@="
syn match xpathFunction "\(number\|abs\|ceiling\|floor\|round\|string\|compare\|concat\|adjust-dateTime-to-timezone\)(\@="
syn match xpathFunction "\(matches\|replace\|boolean\|not\|true\|false\|dateTime\|name\|root\|remove\|empty\|exists\|reverse\)(\@="
syn match xpathFunction "\(subsequence\|count\|avg\|max\|min\|sum\|id\|position\|last\|translate\|text\|format-dateTime\)(\@="
syn match xpathFunction "\(dayTimeDuration\)"

" STRINGS
syn region xpathString matchgroup=xpathQuote start=+'+ end=+'+

if $SSH_CLIENT ==? ""
    let format='italic'
else
    let format='NONE'
endif

hi def link xmlEntity		Statement
hi def link xmlEntityPunct	PreProc
exe "highlight xpathQuote ctermfg=156 cterm=" .format
" hi def link xpathString String
exe "highlight xpathString ctermfg=10 cterm=" .format ." guifg=#91b859 gui=" .format
" hi def link xpathFunction Function
exe "highlight xpathFunction ctermfg=12 cterm=" .format ." guifg=#82aaff gui=" .format
" hi def link xpathNumber Constant
exe "highlight xpathNumber ctermfg=6 cterm=" .format ." guifg=#39adb5 gui=" .format
" hi def link xpathParam Identifier
exe "highlight xpathParam ctermfg=11 cterm=" .format ." guifg=#ffcb6b gui=" .format
"hi def link xpathPunct PreProc
exe "highlight xpathPunct ctermfg=14 cterm=" .format ." guifg=#89ddff gui=" .format
" hi def link xpathLangVar Type
exe "highlight xpathLangVar ctermfg=3 cterm=" .format ." guifg=#ffb62c gui=" .format
exe "highlight xpathReference ctermfg=156 cterm=" .format ." guifg=#afff87 gui=" .format
exe "highlight xpathOperator ctermfg=137 cterm=" .format ." guifg=#ab7967 gui=" .format
exe "highlight xpathP2 ctermfg=8 cterm=" .format ." guifg=#3e515b gui=" .format
exe "highlight xpathSpec ctermfg=1 cterm=" .format ." guifg=#e53935 gui=" .format
hi def link xpathNameSpace Primitive
