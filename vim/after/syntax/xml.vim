syn match xmlFunction   '\<\(makefault\|template\|validate\)\>'                                                        contained
syn match xmlLog        '\<\(call-template\|log\)\>'                                                                   contained
syn match xmlDb         '\<\(dblookup\|dbreport\|class\|payloadFactory\|arg\|http\)\>'                                 contained
syn match xmlFilter     '\<\(filter\|then\|else\|on-fail\|drop\|respond\|store\|if\|sort\|choose\|when\|otherwise\)\>' contained
syn match xmlSend       '\<\(send\|call>\@=\)'                                                                         contained
syn match xmlProperty   '\<\(property\|address\|header\|endpoint\|attribute\|reason\|detail\|code\)\>'                 contained
syn match xmlSequence   '\<sequence\>'                                                                                 contained
syn match xmlParam      '\<\(parameter\|result\|dsName\|target\|format\|source\|param\)\>'                             contained
syn match xmlLogParam   '\<with-param\>'                                                                               contained
syn match xmlConnection '\<\(connection\|statement\|resource\|stylesheet\)\>'                                          contained
syn match xmlArgs       '\<args\>'                                                                                     contained
syn match xmlEnrich     '\<\(enrich\|xslt\|value-of\|schema\|datamapper\)\>'                                           contained
syn match xmlSqlTag     '\<\(sql\|script\)\>'                                                                          contained
syn match xmlInSequence '\<\(inSequence\|outSequence\|faultSequence\)\>'                                               contained
syn match xsltStatement '\<for-each\>'                                                                                 contained

syn match xmlFile       '\k\+_\(Logger\|XSLT\|EP\|DM\|outputSchema\|OutputSchema\|inputSchema\|InputSchema\)'          contained

syn keyword xmlExpression expression regex contained
syn keyword xmlValue      value action     contained
syn keyword xmlSelect     select           contained
syn keyword xmlName       name             contained
syn match xmlUrl "\(url-mapping\|uri-template\|uri\)" contained

syn keyword xmlNs  ns0 contained
syn keyword xmlXsl xsl contained

syn cluster xmlTagHook       add=callTemplate,xmlDb,xmlFilter,xmlProperty,xmlSequence
syn cluster xmlTagHook       add=xmlConnection,xmlParam,xmlFunction,xmlArgs,xmlEnrich
syn cluster xmlTagHook       add=xmlSqlTag,xmlSend,xmlLog,xmlLogParam,xmlInSequence
syn cluster xmlTagHook       add=xsltStatement
syn cluster xmlNamespaceHook add=xmlNs,xmlXsl
syn cluster xmlAttribHook    add=xmlExpression,xmlValue,xmlSelect,xmlName,xmlUrl
syn cluster xmlStringHook    add=xmlFile

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
