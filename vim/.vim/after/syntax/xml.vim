" XML Tag Names
syn keyword xmlFunction   makefault template validate                                               contained
syn keyword xmlLog        log                                                                       contained
syn match   xmlLog        '\<call-template\>'                                               display contained
syn keyword xmlDb         dblookup dbreport class payloadFactory arg http                           contained
syn keyword xmlFilter     filter then else drop respond store if sort choose when otherwise         contained
syn keyword xmlFilter     switch case                                                               contained
syn match   xmlFilter     '\<on-fail\>'                                                     display contained
syn keyword xmlSend       send call loopback                                                        contained
syn keyword xmlConstant   address header endpoint attribute reason detail code                      contained
syn keyword xmlProperty   property address header endpoint attribute reason detail code             contained
syn keyword xmlSequence   sequence                                                                  contained
syn keyword xmlParam      parameter result dsName target format source param                        contained
syn match   xmlLogParam   '\<with-param\>'                                                  display contained
syn keyword xmlConnection connection statement stylesheet                                           contained
syn keyword xmlArgs       args                                                                      contained
syn keyword xmlEnrich     enrich xslt schema datamapper fastxslt                                    contained
syn match   xmlEnrich     '\<value-of\>'                                                    display contained
syn keyword xmlSqlTag     sql script                                                                contained
syn keyword xmlInSequence inSequence outSequence faultSequence                                      contained
syn match   xsltStatement '\<for-each\>'                                                    display contained

syn match    xmlPropName '\%(name="\)\@6<=[^"]*"\@=' display contained
syn region   xmlPropString contained keepend matchgroup=xmlQuote start=+"+ end=+"+ contains=xmlEntity,@Spell,@xmlPropStringHook display
syn cluster  xmlPropStringHook add=xmlPropName
syn region   xmlPropertyTag
      \ matchgroup=xmlTagPunct start=+<\%(property\s\+\)\@=+
      \ matchgroup=xmlTagPunct end=+>+
      \ contains=xmlError,Xpath,xmlTagName,xmlPropString,xmlAttrib,xmlAttribPunct,xmlEqual,xmlOperator,xmlProperty

" XML Strings
syn match   xmlFile '\k\+_\?\(Logger\|XSLT\|EP\|MP\|FailOverMP\|MS\|FailOverMS\|DM\|outputSchema\|OutputSchema\|inputSchema\|InputSchema\)\>' display contained

" syn keyword xmlName   expression value regex name action select source    contained

syn keyword xmlNs  ns0 contained
syn keyword xmlXsl xsl contained

syn cluster xmlTagHook       add=callTemplate,xmlDb,xmlFilter,xmlConstant,xmlProperty,xmlSequence
syn cluster xmlTagHook       add=xmlConnection,xmlParam,xmlFunction,xmlArgs,xmlEnrich
syn cluster xmlTagHook       add=xmlSqlTag,xmlSend,xmlLog,xmlLogParam,xmlInSequence
syn cluster xmlTagHook       add=xsltStatement
syn cluster xmlNamespaceHook add=xmlNs,xmlXsl
syn cluster xmlAttribHook    add=xmlExpression,xmlValue,xmlSelect,xmlName
syn cluster xmlStringHook    add=xmlFile

let s:cur_syntax = b:current_syntax
unlet! b:current_syntax
syn include @xmlXpath syntax/xpath.vim

syn region Xpath
    \ matchgroup=xmlQuote
    \ start=+\%(when test=\|select=\|xpath=\|source=\|expression=\)\@11<="+
    \ keepend
    \ end=+"+
    \ contained
    \ contains=@xmlXpath

let b:current_syntax = s:cur_syntax

hi def link xmlNs           Identifier
function! XmlAfterHighlight() abort
  if &t_Co >= 256 || has('gui_running')
    highlight xmlXsl        ctermfg=1   guifg=#ff5370
    highlight xmlExpression ctermfg=203 guifg=#ff5f5f cterm=italic gui=italic
    highlight xmlSelect     ctermfg=222 guifg=#ffd787 cterm=italic gui=italic
    highlight xmlName       ctermfg=152 guifg=#afd7d7
    highlight xmlLog        ctermfg=67  guifg=#5f87af
    highlight xmlSqlTag     ctermfg=209 guifg=#ff875f
    highlight xmlLogParam   ctermfg=243 guifg=#767676
  else
    highlight xmlXsl        ctermfg=red
    highlight xmlExpression ctermfg=red
    highlight xmlSelect     ctermfg=yellow
    highlight xmlName       ctermfg=grey
    highlight xmlLog        ctermfg=darkblue
    highlight xmlSqlTag     ctermfg=darkyellow
    highlight xmlLogParam   ctermfg=darkgrey
  endif
endfunction

function! s:hi(group, target) abort
  if &t_Co >= 256 || has('gui_running')
    let italic = 1
  else
    let italic = 0
  endif
  let target_id = synIDtrans(hlID(a:target))
  let t_fg = synIDattr(target_id, 'fg', 'cterm')
  let t_bg = synIDattr(synIDtrans(hlID('String')), 'fg', 'cterm')
  let t_fmt = ''
  let t_fmt.= synIDattr(target_id, 'bold', 'cterm') ? 'bold,' : ''
  let t_fmt.= synIDattr(target_id, 'italic', 'cterm') ? 'italic' : ''
  let g_fg = synIDattr(target_id, 'fg', 'gui')
  let g_bg = synIDattr(synIDtrans(hlID('String')), 'fg', 'gui')
  let g_fmt = ''
  let g_fmt.= synIDattr(target_id, 'bold', 'gui') ? 'bold,' : ''
  let g_fmt.= synIDattr(target_id, 'italic', 'gui') ? 'italic' : ''
  let Syn = { x -> len(x) ? x : 'NONE' }
  let Trim = { x -> x[-1] ==# ',' ? x[:-2] : x }
  let Attr = { x -> Trim(Syn(x)) }
  execute 'highlight ' . a:group . ' ctermfg=' . Syn(t_fg) . ' ctermbg=' . Syn(t_bg) .
        \ ' guifg=' . Syn(g_fg) . ' guibg=' . Syn(g_bg) .
        \ ' cterm=' . Attr(t_fmt) . ' gui=' . Attr(g_fmt)
endfunction

function! XmlNier() abort
  call <SID>hi('xmlFile', 'PreProc')
  call <SID>hi('xmlPropName', 'Todo')
  hi xmlPropName guifg=#d75f5f cterm=bold gui=none
endfunction

function! XmlNord() abort

  hi link xmlLog Function
  hi link xmlLogParam xmlAttrib
  hi link xmlSqlTag Builtin
  if &t_Co >= 256 || has('gui_running')
    highlight xmlXsl        ctermfg=1   guifg=#bf616a
  else
    highlight xmlXsl        ctermfg=red
  endif
endfunction

augroup xmlAfterHighlight
  autocmd!
  autocmd ColorScheme material call XmlAfterHighlight()
  autocmd ColorScheme nier call XmlNier()
  autocmd ColorScheme nord call XmlNord()
augroup END
if get(g:, 'colors_name', '') ==# 'material'
  call XmlAfterHighlight()
endif
if get(g:, 'colors_name', '') ==# 'nier'
  call XmlNier()
endif
if get(g:, 'colors_name', '') ==# 'nord'
  call XmlNord()
endif

hi def link xmlArgs         Primitive
hi def link xmlConnection   Storage
hi def link xmlSqlTag       Builtin
" hi def link xmlValue        xmlExpression
hi def link xmlFile         PreProc
hi def link xmlInSequence   Normal
hi def link xmlEnrich       Operator
hi def link xmlFunction     Function
hi def link xmlSend         Function
hi def link xmlParam        StorageClass
hi def link xmlProperty     Constant
hi def link xmlConstant     Constant
hi def link xmlSequence     StorageClass
hi def link xmlScriptTag    xmlTag
hi def link xmlEndScriptTag xmlTag
hi def link xmlDb           StorageClass
hi def link xmlFilter       Keyword
hi def link xsltStatement   Statement
hi def link xmlPropString   xmlString
hi def link xmlPropName     Identifier
hi def link Xpath           String
" hi def link xmlPropName Todo
