syn match xmlFunction 'makefault\|template\( \|>\)\@=\|validate' contained
syn match xmlLog 'call-template\|log' contained
syn match xmlDb 'dblookup\|dbreport\|class\|payloadFactory\|arg \|http[ >]\@=' contained
syn match xmlFilter '\<\(filter\|then\|else\|on-fail\|drop\|respond\|store\|choose\|when\|otherwise\)\>' contained
syn match xmlSend '\<\(send\|call\(>\)\@=\)' contained
syn match xmlProperty '\<\(property\|address\|header\|endpoint\|attribute\|reason\|detail\|code\)\( \|>\)\@=' contained
syn match xmlSequence '\<sequence\>' contained
syn match xmlParam 'parameter\|result\|dsName\|target\|format\|source \@=\|param\( \|>\)\@=' contained
syn match xmlLogParam 'with-param' contained
syn match xmlConnection 'connection\|statement\|resource\( \|>\)\@=\|stylesheet' contained
syn match xmlArgs 'args' contained
syn match xmlEnrich 'enrich\|xslt\|value-of\|schema\|datamapper' contained
syn match xmlSqlTag '\<\(sql\|script\)\>' contained
syn keyword xmlInSequence inSequence outSequence faultSequence contained

" let s:cur_syntax = b:current_syntax
" unlet! b:current_syntax
" syn include @xmlSQL syntax/sql.vim
" syn region xmlSqlRegion
"     \ start=+\%(<sql>\)+
"     \ keepend
"     \ end=+\%(</sql>\)+
"     \ contained
"     \ contains=xmlTag,,xmlEndTag,@xmlSQL
" let b:current_syntax = s:cur_syntax

" let s:cur_syntax = b:current_syntax
" unlet! b:current_syntax
" syn include @xmlJson syntax/json.vim
" syn region xmlJsonRegion
"             \ start=+\%(<format>\)+
"             \ keepend
"             \ end=+</format>+
"             \ contained
"             \ contains=xmlFormatTag,xmlFormatEndTag,@xmlJson
" syn region xmlPayloadArgsRegion
"             \ start=+\%(<args>\)+
"             \ keepend
"             \ end=+</args>+
"             \ contained
"             \ contains=xmlArgTag,xmlTag,xmlEndTag,xmlRegion
" syn region xmlPayloadRegion
"             \ start=+\%(<payloadFactory media-type="json">\)+
"             \ keepend
"             \ end=+</payloadFactory>+
"             \ contained
"             \ contains=xmlJsonRegion,xmlPayloadTag,xmlPayloadEndTag,xmlPayloadArgsRegion,xmlPayloadArgsTag
" let b:current_syntax = s:cur_syntax

" let s:cur_syntax = b:current_syntax
" unlet! b:current_syntax
" syn include @xmlJavaScript syntax/javascript.vim
" syn region xmlJavaScriptRegion
"     \ start=+<script language="js">+
"     \ keepend
"     \ end=+</script>+
"     \ contained
"     \ contains=xmlScriptTag,xmlEndScriptTag,xmlCdataStart,xmlCdataEnd,@xmlJavaScript
" let b:current_syntax = s:cur_syntax

" let s:cur_syntax = b:current_syntax
" unlet! b:current_syntax
" syn include @xmlGroovy syntax/groovy.vim
" syn region xmlGroovyRegion
"     \ start=+<script language="groovy">+
"     \ keepend
"     \ end=+</script>+
"     \ contained
"     \ contains=xmlScriptTag,xmlEndScriptTag,xmlCdataStart,xmlCdataEnd,@xmlGroovy
" let b:current_syntax = s:cur_syntax

" syn match xmlScriptTag +<script[^/!?<>]*>+ contains=xmlTag,xmlTagName,xmlAttrib,xmlEqual,xmlOperator,xmlString,xmlNamespace,xmlAttribPunct,@xmlStartTagHook
" syn match xmlEndScriptTag +</script>+ contains=xmlTag,xmlEndTag,xmlTagName,xmlNamespace,xmlAttribPunct,@xmlTagHook
" syn match xmlFormatTag +<format[^/!?<>]*>+ contains=xmlTag,xmlTagName,xmlAttrib,xmlEqual,xmlOperator,xmlString,xmlNamespace,xmlAttribPunct,@xmlStartTagHook
" syn match xmlFormatEndTag +</format>+ contains=xmlTag,xmlEndTag,xmlTagName,xmlNamespace,xmlAttribPunct,@xmlTagHook
" syn match xmlPayloadTag +<payloadFactory[^/!?<>]*>+ contains=xmlTag,xmlTagName,xmlAttrib,xmlEqual,xmlOperator,xmlString,xmlNamespace,xmlAttribPunct,@xmlStartTagHook
" syn match xmlPayloadEndTag +</payloadFactory>+ contains=xmlTag,xmlEndTag,xmlTagName,xmlNamespace,xmlAttribPunct,@xmlTagHook
" syn match xmlPayloadArgsTag +<args/>+ contains=xmlTag,xmlTagName,@xmlTagHook
" syn match xmlArgTag +<arg [^/]/>+ contains=@xmlTagHook
" syn match    xmlCdataStart +<!\[CDATA\[+  contained contains=xmlCdataCdata
" syn keyword  xmlCdataCdata CDATA          contained
" syn match    xmlCdataEnd   +]]>+          contained

" let s:cur_syntax = b:current_syntax
" unlet! b:current_syntax
" syn include @xmlXpath $HOME/.vim/after/syntax/xpath.vim
" syn region xmlXpathRegion
"     \ matchgroup=xmlQuote start=+\(select=\| source=\|when test=\|xpath=\|if test=\|expression=\)\@<="+
"     \ keepend
"     \ end=+"+
"     \ contained
"     \ contains=xmlAttrib,@xmlXpath
" let b:current_syntax = s:cur_syntax
" syn region xmlXpathRegion
"     \ matchgroup=xmlQuote start=+"{+
"     \ keepend
"     \ end=+}"+
"     \ contained
"     \ contains=xmlAttrib,@xmlXpath
" let b:current_syntax = s:cur_syntax
" if $SSH_CLIENT ==? ''
"     highlight! xmlXpathRegion cterm=italic
" else
"     highlight! xmlXpathRegion cterm=italic
" endif

syn keyword xmlExpression expression regex contained
syn keyword xmlValue value contained
syn keyword xmlSelect select contained
syn keyword xmlName name contained
syn match xmlUrl "\(url-mapping\|uri-template\|uri\)" contained

syn keyword xmlNs ns0 contained
syn keyword xmlXsl xsl contained

syn cluster xmlTagHook add=callTemplate,xmlDb,xmlFilter,xmlProperty,xmlSequence,xmlConnection,xmlParam,xmlFunction,xmlArgs,xmlEnrich,xmlSqlTag,xmlSend,xmlLog,xmlLogParam,xmlInSequence
syn cluster xmlNamespaceHook add=xmlNs,xmlXsl
syn cluster xmlAttribHook add=xmlExpression,xmlValue,xmlSelect,xmlName,xmlUrl

highlight link xmlNs Identifier
highlight xmlXsl ctermfg=1 guifg=#ff5370

hi xmlExpression ctermfg=203 guifg=#ff5f5f cterm=italic gui=italic
hi def link xmlValue xmlExpression
hi xmlSelect ctermfg=221 guifg=#ffcb6b cterm=italic gui=italic
hi xmlName ctermfg=152 guifg=#afd7d7
hi xmlUrl ctermfg=36 guifg=#00af87 cterm=italic gui=italic

hi def link xmlInSequence Identifier
hi def link xmlEnrich Operator
hi def link xmlArgs Primitive
highlight xmlArgs ctermfg=3 guifg=#ffb62c
hi def link xmlFunction Function
hi def link xmlSend Function
hi def link xmlParam StringDelimiter
highlight xmlConnection ctermfg=13 guifg=#945eb8
highlight xmlLog ctermfg=245 guifg=#bbbbbb
highlight link xmlProperty Constant
hi def link xmlSequence StringDelimiter
hi def link xmlScriptTag xmlTag
hi def link xmlEndScriptTag xmlTag
highlight link xmlDb Identifier
highlight link xmlFilter Keyword
highlight xmlSqlTag ctermfg=208 guifg=#ff5f00
highlight xmlLogParam ctermfg=243 guifg=#8a8a8a
