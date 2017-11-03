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


hi def link xmlEntity		Statement
hi def link xmlEntityPunct	PreProc
highlight xpathQuote ctermfg=156 cterm=italic
hi def link xpathString String
highlight xpathString ctermfg=10 cterm=italic guifg=#91b859 gui=italic
hi def link xpathFunction Function
highlight xpathFunction ctermfg=12 cterm=italic guifg=#82aaff gui=italic
hi def link xpathNumber Constant
highlight xpathNumber ctermfg=6 cterm=italic guifg=#39adb5 gui=italic
" hi def link xpathParam Identifier
highlight xpathParam ctermfg=11 cterm=italic guifg=#ffcb6b gui=italic
hi def link xpathPunct PreProc
highlight xpathPunct ctermfg=14 cterm=italic guifg=#89ddff gui=italic
hi def link xpathLangVar Type
highlight xpathLangVar ctermfg=3 cterm=italic guifg=#ffb62c gui=italic
highlight xpathReference ctermfg=156 cterm=italic guifg=#afff87 gui=italic
highlight xpathOperator ctermfg=137 cterm=italic guifg=#ab7967 gui=italic
highlight xpathP2 ctermfg=8 cterm=italic guifg=#3e515b gui=italic
highlight xpathSpec ctermfg=1 cterm=italic guifg=#e53935 gui=italic
hi def link xpathNameSpace Primitive
