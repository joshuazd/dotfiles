" Vim syntax file
" Language:	JavaScript
" Maintainer:	Claudio Fleiner <claudio@fleiner.com>
" Updaters:	Scott Shattuck (ss) <ss@technicalpursuit.com>
" URL:		http://www.fleiner.com/vim/syntax/javascript.vim
" Changes:	(ss) added keywords, reserved words, and other identifiers
"		(ss) repaired several quoting and grouping glitches
"		(ss) fixed regex parsing issue with multiple qualifiers [gi]
"		(ss) additional factoring of keywords, globals, and members
" Last Change:	2012 Oct 05
" 		2013 Jun 12: adjusted javaScriptRegexpString (Kevin Locke)

" tuning parameters:
" unlet javaScript_fold

if !exists('main_syntax')
  " quit when a syntax file was already loaded
  if exists('b:current_syntax')
    finish
  endif
  let main_syntax = 'javascript'
elseif exists('b:current_syntax') && b:current_syntax ==# 'javascript'
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

syn match javaScriptParenError "(\|)"
syn region javaScriptParens start="(" end=")"
syn match javaScriptOperator            "+\|\*\|==\|=\|-\|/\|!=\|||\|&&\|>\|<\|!"

syn keyword javaScriptCommentTodo      TODO FIXME XXX TBD contained
syn match   javaScriptLineComment      "\/\/.*" contains=@Spell,javaScriptCommentTodo display
syn match   javaScriptCommentSkip      "^[ \t]*\*\($\|[ \t]\+\)"
syn region  javaScriptComment	       start="/\*"  end="\*/" contains=@Spell,javaScriptCommentTodo
syn match   javaScriptSpecial	       "\\\d\d\d\|\\." display
syn region  javaScriptStringD	    matchgroup=StringDelimiter start=+"+  skip=+\\\\\|\\"+  end=+"\|$+	contains=javaScriptSpecial,@htmlPreproc
syn region  javaScriptStringS	    matchgroup=StringDelimiter start=+'+  skip=+\\\\\|\\'+  end=+'\|$+	contains=javaScriptSpecial,@htmlPreproc

syn match  javaScriptTemplateDelim    "\${\|}" contained
syn region javaScriptTemplateVar      matchgroup=Delimiter start=+${+ end=+}+                        contains=javaScriptTemplateDelim keepend
syn region javaScriptTemplateString   matchgroup=StringDelimiter start=+`+  skip=+\\\(`\|$\)+  end=+`+     contains=javaScriptTemplateVar,javaScriptSpecial keepend

syn match javaScriptPunct ",\|;" display

syn match javaScriptDeref "\." display

syn match javaScriptFuncName "\h\w*(\@=" nextgroup=javaScriptFuncParams display
syn region javaScriptFuncParams contained matchgroup=javaScriptBraces start="\s*(" end=")" contains=javaScriptFuncParam
syn match javaScriptFuncParam contained "[^)]*" contains=javaScriptComment,javaScriptLineComment,javaScriptOperator,javaScriptDeref,javaScriptBraces,javaScriptItemAccess,javaScriptFuncName,javaScriptPunct,javaScriptTemplateString,javaScriptStringD,javaScriptStringS,javaScriptNumber,javaScriptNull,javaScriptField,javaScriptParens,javaScriptIn,javaScriptReserved skipwhite

syn region javaScriptParams contained matchgroup=javaScriptBraces start="(" end=")" contains=javaScriptParam
syn match javaScriptParam contained "[^)]*" contains=javaScriptOperator,javaScriptDeref,javaScriptBraces,javaScriptIn,javaScriptItemAccess,javaScriptFuncName,javaScriptPunct,javaScriptStringD,javaScriptStringS,javaScriptNull,javaScriptField,javaScriptIdentifier skipwhite

syn match   javaScriptSpecialCharacter "'\\.'" display
syn match   javaScriptNumber	       "-\=\<\d\+L\=\>\|0[xX][0-9a-fA-F]\+\>" display
syn region  javaScriptRegexpString     start=+/[^/*]+me=e-1 skip=+\\\\\|\\/+ end=+/[gim]\{0,2\}\s*$+ end=+/[gim]\{0,2\}\s*[;.,)\]}]+me=e-1 contains=@htmlPreproc oneline display

syn keyword javaScriptConditional	else switch
syn keyword javaScriptConditional       if switch nextgroup=javaScriptFuncParams
syn keyword javaScriptRepeat		while for do nextgroup=javaScriptParams
syn keyword javaScriptIn                in
syn keyword javaScriptBranch		break continue
syn keyword javaScriptOperator		instanceof typeof delete
syn keyword javaScriptType		Array Boolean Date Function Number Object String RegExp nextgroup=javaScriptFuncParams
syn keyword javaScriptStatement		return with
syn keyword javaScriptBoolean		true false
syn keyword javaScriptNull		null undefined
syn keyword javaScriptIdentifier	arguments this var let
syn keyword javaScriptLabel		case default
syn keyword javaScriptException		try catch finally throw
syn keyword javaScriptMessage		alert confirm prompt status
syn keyword javaScriptGlobal		self window top parent
syn keyword javaScriptMember		document event location
syn keyword javaScriptDeprecated	escape unescape
syn keyword javaScriptReserved		new abstract boolean byte char class const debugger double enum export extends final float goto implements import int interface long native package private protected public short static super synchronized throws transient volatile

syn match javaScriptColon "\(\(case\|default\|\)[^:]*\)\@<=:" display

syn match javaScriptItemAccess "\h\w*\[\@=" display
" syn match javaScriptField "\(\.\)\@<=\h\w*\([^\.a-zA-Z0-9(\[]\|$\)\@="
" syn match javaScriptField "\.\@<=\h\w*\(\.\h\w*[(\[]\)\@="

if exists('javaScript_fold')
    syn match	javaScriptFunction	"\<function\>" display
    syn match   javaScriptFunction      "\<function\>" nextgroup=javaScriptFuncParams display
    syn region	javaScriptFunctionFold	start="\<function\>.*[^};]$" end="^\z1}.*$" transparent fold keepend

    syn sync match javaScriptSync	grouphere javaScriptFunctionFold "\<function\>"
    syn sync match javaScriptSync	grouphere NONE "^}"

    setlocal foldmethod=syntax
    setlocal foldtext=getline(v:foldstart)
else
    syn keyword javaScriptFunction	function
    syn keyword javaScriptFunction	function nextgroup=javaScriptFuncParams
    syn match	javaScriptBraces	   "[{}\[\]]" display
    syn match	javaScriptParens	   "[()]" display
endif

" syn sync fromstart
syn sync maxlines=100

if main_syntax ==# 'javascript'
  syn sync ccomment javaScriptComment
endif

" Define the default highlighting.
" Only when an item doesn't have highlighting yet
hi def link javaScriptComment		Comment
hi def link javaScriptLineComment	Comment
hi def link javaScriptCommentTodo	Todo
hi def link javaScriptSpecial		Special
hi def link javaScriptTemplateDelim     Delimiter
hi def link javaScriptTemplateVar       Special
hi def link javaScriptTemplateString    String
hi def link javaScriptStringS		String
hi def link javaScriptStringD		String
hi def link javaScriptCharacter		Character
hi def link javaScriptSpecialCharacter	javaScriptSpecial
hi def link javaScriptNumber		Constant
hi def link javaScriptConditional	Conditional
hi def link javaScriptRepeat		Repeat
hi def link javaScriptBranch		Conditional
hi def link javaScriptOperator		Operator
hi def link javaScriptIn                Operator
hi def link javaScriptType		StringDelimiter
hi def link javaScriptStatement		Statement
hi def link javaScriptFunction		Function
hi def link javaScriptBraces		Delimiter
hi def link javaScriptColon		Delimiter
hi def link javaScriptError		Error
hi def link javaScrParenError		javaScriptError
hi def link javaScriptNull		Constant
hi def link javaScriptBoolean		Boolean
hi def link javaScriptRegexpString	String
hi def link javaScriptParens	        Delimiter
hi def link javaScriptParenError        Error

hi def link javaScriptIdentifier	Type
hi def link javaScriptLabel		Label
hi def link javaScriptException		Exception
hi def link javaScriptMessage		Keyword
hi def link javaScriptGlobal		Keyword
hi def link javaScriptMember		Keyword
hi def link javaScriptDeprecated	Exception
hi def link javaScriptReserved		Keyword
hi def link javaScriptDebug		Debug
hi def link javaScriptConstant		Label
hi def link javaScriptFuncName          Function
hi def link javaScriptPunct             Delimiter
hi def link javaScriptDeref             Delimiter
hi def link javaScriptItemAccess        Special
" augroup javaScriptHighlight
"   autocmd!
"   autocmd ColorScheme * highlight javaScriptField ctermfg=245 guifg=#8a8a8a
" augroup END
" highlight javaScriptField ctermfg=245 guifg=#8a8a8a


let b:current_syntax = 'javascript'
if main_syntax ==# 'javascript'
  unlet main_syntax
endif
let &cpo = s:cpo_save
unlet s:cpo_save

" vim: ts=8
