if exists("b:current_syntax")
    finish
endif


syn match xpathParam "\w\+"
syn match xpathReference "\$\@<=\w[a-zA-Z0-9\-_]*"
syn match xpathOperator "\$"
syn keyword xpathLangVar body ctx trp
syn match xpathPunct "[,:/\.\[\]()]"
syn match xpathOperator "[=\*@+]"
syn keyword xpathOperator or and xor
syn match xpathOperator "!="
syn match xpathNumber "\<[0-9]\+\>"

syn match xpathFunction "\(substring\|string\-join\|string\-length\|upper\-case\|lower\-case\|escape\-uri\|starts\-with\|ends\-with\)(\@="
syn match xpathFunction "\(substring\-before\|index\-of\|get\-property\|json\-eval\|contains\)(\@="
syn match xpathFunction "\(number\|abs\|ceiling\|floor\|round\|string\|compare\|concat\)(\@="
syn match xpathFunction "\(matches\|replace\|boolean\|not\|true\|false\|dateTime\|name\|root\|remove\|empty\|exists\|reverse\)(\@="
syn match xpathFunction "\(subsequence\|count\|avg\|max\|min\|sum\|id\|position\|last\|translate\|text\)(\@="

" STRINGS
syn region xpathString matchgroup=xpathQuote start=+'+ end=+'+



highlight xpathQuote ctermfg=156
hi def link xpathString String
hi def link xpathFunction Function
hi def link xpathNumber Constant
hi def link xpathParam Identifier
hi def link xpathPunct PreProc
hi def link xpathLangVar Type
highlight xpathReference ctermfg=156
highlight xpathOperator ctermfg=137
