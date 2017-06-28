if exists("b:current_syntax")
    finish
endif


syn match xpathParam "\w\+"
syn match xpathReference "\$\@<=\w[a-zA-Z0-9\-_]*"
syn match xpathOperator "\$"
syn keyword xpathLangVar body ctx trp
syn match xpathPunct "[,/\[\]()]"
syn match xpathP2 "[:\.]"
syn match xpathOperator "[=\*@+]"
syn keyword xpathOperator or and xor
syn match xpathOperator "!="
syn match xpathNumber "\<[0-9]\+\>"

syn match xpathSpec "fn"

syn match xpathFunction "\(substring\|string\-join\|string\-length\|upper\-case\|lower\-case\|escape\-uri\|starts\-with\|ends\-with\)(\@="
syn match xpathFunction "\(substring\-before\|substring\-after\|index\-of\|get\-property\|json\-eval\|contains\)(\@="
syn match xpathFunction "\(number\|abs\|ceiling\|floor\|round\|string\|compare\|concat\)(\@="
syn match xpathFunction "\(matches\|replace\|boolean\|not\|true\|false\|dateTime\|name\|root\|remove\|empty\|exists\|reverse\)(\@="
syn match xpathFunction "\(subsequence\|count\|avg\|max\|min\|sum\|id\|position\|last\|translate\|text\)(\@="

" STRINGS
syn region xpathString matchgroup=xpathQuote start=+'+ end=+'+


highlight xpathQuote ctermfg=156 cterm=italic
hi def link xpathString String
highlight xpathString ctermfg=10 cterm=italic
hi def link xpathFunction Function
highlight xpathFunction ctermfg=12 cterm=italic
hi def link xpathNumber Constant
highlight xpathNumber ctermfg=6 cterm=italic
" hi def link xpathParam Identifier
highlight xpathParam ctermfg=11 cterm=italic
hi def link xpathPunct PreProc
highlight xpathPunct ctermfg=14 cterm=italic
hi def link xpathLangVar Type
highlight xpathLangVar ctermfg=3 cterm=italic
highlight xpathReference ctermfg=156 cterm=italic
highlight xpathOperator ctermfg=137 cterm=italic
highlight xpathP2 ctermfg=8 cterm=italic
highlight xpathSpec ctermfg=1 cterm=italic
