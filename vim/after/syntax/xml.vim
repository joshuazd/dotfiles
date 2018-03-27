" XML Tag Names
syn keyword xmlFunction   makefault template validate                                               contained
syn keyword xmlLog        log                                                                       contained
syn match   xmlLog        '\<call-template\>'                                               display contained
syn keyword xmlDb         dblookup dbreport class payloadFactory arg http                           contained
syn keyword xmlFilter     filter then else drop respond store if sort choose when otherwise         contained
syn match   xmlFilter     '\<on-fail\>'                                                     display contained
syn keyword xmlSend       send call                                                                 contained
syn keyword xmlProperty   property address header endpoint attribute reason detail code             contained
syn keyword xmlSequence   sequence                                                                  contained
syn keyword xmlParam      parameter result dsName target format source param                        contained
syn match   xmlLogParam   '\<with-param\>'                                                  display contained
syn keyword xmlConnection connection statement resource stylesheet                                  contained
syn keyword xmlArgs       args                                                                      contained
syn keyword xmlEnrich     enrich xslt schema datamapper fastxslt                                    contained
syn match   xmlEnrich     '\<value-of\>'                                                    display contained
syn keyword xmlSqlTag     sql script                                                                contained
syn keyword xmlInSequence inSequence outSequence faultSequence                                      contained
syn match   xsltStatement '\<for-each\>'                                                    display contained

" XML Strings
syn match   xmlFile '\k\+_\(Logger\|XSLT\|EP\|DM\|outputSchema\|OutputSchema\|inputSchema\|InputSchema\)' display contained

" XML Attributes
" syn match   xmlUrl '\(url-mapping\|uri-template\)' display contained

syn keyword xmlName   expression value regex name action select source    contained

syn keyword xmlNs  ns0 contained
syn keyword xmlXsl xsl contained

syn cluster xmlTagHook       add=callTemplate,xmlDb,xmlFilter,xmlProperty,xmlSequence
syn cluster xmlTagHook       add=xmlConnection,xmlParam,xmlFunction,xmlArgs,xmlEnrich
syn cluster xmlTagHook       add=xmlSqlTag,xmlSend,xmlLog,xmlLogParam,xmlInSequence
syn cluster xmlTagHook       add=xsltStatement
syn cluster xmlNamespaceHook add=xmlNs,xmlXsl
syn cluster xmlAttribHook    add=xmlExpression,xmlValue,xmlSelect,xmlName,xmlUrl
syn cluster xmlStringHook    add=xmlFile

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
" highlight xmlUrl        ctermfg=66  guifg=#00af87 cterm=italic gui=italic
highlight xmlName       ctermfg=152 guifg=#afd7d7
highlight xmlLog        ctermfg=245 guifg=#bbbbbb
highlight xmlSqlTag     ctermfg=209 guifg=#ff5f00
highlight xmlLogParam   ctermfg=243 guifg=#8a8a8a
" highlight xmlFile       ctermfg=103 guifg=#8787af cterm=bold   gui=bold

hi def link xmlArgs         Primitive
hi def link xmlConnection   StorageClass
hi def link xmlSqlTag       Builtin
hi def link xmlValue        xmlExpression
hi def link xmlFile         Tag
hi def link xmlInSequence   Normal
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
