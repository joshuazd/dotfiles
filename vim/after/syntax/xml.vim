syn match xmlFunction   '\<\(makefault\|template\|validate\)\>'                                                        display contained
syn match xmlLog        '\<\(call-template\|log\)\>'                                                                   display contained
syn match xmlDb         '\<\(dblookup\|dbreport\|class\|payloadFactory\|arg\|http\)\>'                                 display contained
syn match xmlFilter     '\<\(filter\|then\|else\|on-fail\|drop\|respond\|store\|if\|sort\|choose\|when\|otherwise\)\>' display contained
syn match xmlSend       '\<\(send\|call>\@=\)'                                                                         display contained
syn match xmlProperty   '\<\(property\|address\|header\|endpoint\|attribute\|reason\|detail\|code\)\>'                 display contained
syn match xmlSequence   '\<sequence\>'                                                                                 display contained
syn match xmlParam      '\<\(parameter\|result\|dsName\|target\|format\|source\|param\)\>'                             display contained
syn match xmlLogParam   '\<with-param\>'                                                                               display contained
syn match xmlConnection '\<\(connection\|statement\|resource\|stylesheet\)\>'                                          display contained
syn match xmlArgs       '\<args\>'                                                                                     display contained
syn match xmlEnrich     '\<\(enrich\|xslt\|value-of\|schema\|datamapper\)\>'                                           display contained
syn match xmlSqlTag     '\<\(sql\|script\)\>'                                                                          display contained
syn match xmlInSequence '\<\(inSequence\|outSequence\|faultSequence\)\>'                                               display contained
syn match xsltStatement '\<for-each\>'                                                                                 display contained
syn match xmlFile       '\k\+_\(Logger\|XSLT\|EP\|DM\|outputSchema\|OutputSchema\|inputSchema\|InputSchema\)'          display contained
syn match xmlUrl        '\(url-mapping\|uri-template\)'                                                                display contained

syn keyword xmlMethod GET POST PUT PATCH DELETE get post put patch delete contained
syn keyword xmlName   expression value regex name action select source    contained

syn keyword xmlNs  ns0 contained
syn keyword xmlXsl xsl contained

syn cluster xmlTagHook       add=callTemplate,xmlDb,xmlFilter,xmlProperty,xmlSequence
syn cluster xmlTagHook       add=xmlConnection,xmlParam,xmlFunction,xmlArgs,xmlEnrich
syn cluster xmlTagHook       add=xmlSqlTag,xmlSend,xmlLog,xmlLogParam,xmlInSequence
syn cluster xmlTagHook       add=xsltStatement
syn cluster xmlNamespaceHook add=xmlNs,xmlXsl
syn cluster xmlAttribHook    add=xmlExpression,xmlValue,xmlSelect,xmlName,xmlUrl
syn cluster xmlStringHook    add=xmlFile,xmlMethod

let s:cur_syntax = b:current_syntax
unlet! b:current_syntax
syn include @xmlXpath syntax/xpath.vim
syn region Xpath
    \ matchgroup=xmlQuote start=+\(when test=\|select=\|xpath=\|source=\|expression=\)\@<="+
    \ keepend
    \ end=+"+
    \ contained
    \ contains=@xmlXpath
    \ display
let b:current_syntax = s:cur_syntax

hi def link xmlNs           Identifier
highlight xmlXsl        ctermfg=1   guifg=#ff5370

highlight xmlExpression ctermfg=203 guifg=#ff5f5f cterm=italic gui=italic
highlight xmlSelect     ctermfg=221 guifg=#ffcb6b cterm=italic gui=italic
highlight xmlUrl        ctermfg=36  guifg=#00af87 cterm=italic gui=italic
highlight xmlName       ctermfg=152 guifg=#afd7d7
highlight xmlLog        ctermfg=245 guifg=#bbbbbb
highlight xmlSqlTag     ctermfg=208 guifg=#ff5f00
highlight xmlLogParam   ctermfg=243 guifg=#8a8a8a
highlight xmlFile       ctermfg=103 guifg=#8787af cterm=bold   gui=bold
highlight xmlMethod     ctermfg=203 guifg=#ff5f5f cterm=bold   gui=bold

hi def link xmlArgs         Primitive
hi def link xmlConnection   StorageClass
hi def link xmlValue        xmlExpression
hi def link xmlFile         diffAdded
hi def link xmlInSequence   Identifier
hi def link xmlEnrich       Operator
hi def link xmlFunction     Function
hi def link xmlSend         Function
hi def link xmlParam        StringDelimiter
hi def link xmlProperty     Constant
hi def link xmlSequence     StringDelimiter
hi def link xmlScriptTag    xmlTag
hi def link xmlEndScriptTag xmlTag
hi def link xmlDb           Identifier
hi def link xmlFilter       Keyword
hi def link xsltStatement   Statement
