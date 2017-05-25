syn match xmlFunction 'call-template\|makefault\|template\( \|>\)\@=\|log'
syn match db 'dblookup\|dbreport\|class\|payloadFactory'
syn match filter '\(filter\|then\|send\|else\|drop\|call\(>\)\@=\|respond\|store\|choose\|when\|otherwise\)'
syn match property '\(property\|address\|header\|endpoint\|attribute\|reason\)\( \|>\)\@='
syn match sequence '\(</\?\)\@<=sequence'
syn match param 'parameter\|result\|dsName\|target\|with-param\|format\|source\|param'
syn match connection 'connection\|statement\|resource\|stylesheet'
syn match xmlType 'args'
syn match xmlEnrich 'enrich\|xslt\|value-of'
syn match xmlSqlTag '\<\(sql\|script\)\>'

let cur_syntax = b:current_syntax
unlet! b:current_syntax
syn include @xmlSQL syntax/sql.vim
syn region xmlSqlRegion
    \ start=+\(<sql>\)\@<=+
    \ keepend
    \ end=+\(</sql>\)\@=+
    \ contained
    \ contains=@xmlSQL
let b:current_syntax = cur_syntax

let cur_syntax = b:current_syntax
unlet! b:current_syntax
syn include @xmlJavaScript syntax/javascript.vim
syn region xmlJavaScriptRegion
    \ matchgroup=xmlQuote start=+\(<script language="js">\)\@<=<!\[CDATA\[+
    \ keepend
    \ end=+\]\]>\(</script>\)\@=+
    \ contained
    \ contains=@xmlJavaScript
let b:current_syntax = cur_syntax

let cur_syntax = b:current_syntax
unlet! b:current_syntax
syn include @xmlXpath $HOME/.vim/after/syntax/xpath.vim
syn region xmlXpathRegion
    \ matchgroup=xmlQuote start=+\(select=\|source=\|when test=\|xpath=\|expression=\)\@<="+
    \ keepend
    \ end=+"+
    \ contained
    \ contains=xmlAttrib,@xmlXpath
let b:current_syntax = cur_syntax

syn keyword xmlNs ns0
syn keyword xmlXsl xsl

syn cluster xmlTagHook add=callTemplate,db,filter,property,sequence,connection,param,xmlFunction,xmlType,xmlEnrich,xmlSqlTag
syn cluster xmlNamespaceHook add=xmlNs,xmlXsl

highlight link xmlNs Identifier
highlight xmlXsl ctermfg=1

hi def link xmlEnrich Operator
hi def link xmlType Type
hi def link xmlFunction Function
highlight param ctermfg=10
highlight connection ctermfg=13
highlight link property Constant
highlight sequence ctermfg=10
highlight link db Identifier
highlight link filter Keyword
highlight xmlAttrib ctermfg=152
highlight xmlSqlTag ctermfg=202
