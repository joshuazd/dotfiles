" vim: ft=vim:fdm=marker

"" Enable pymode syntax for python files
"call pymode#default('g:pymode', 1)
"call pymode#default('g:pymode_syntax', g:pymode)
"
"" DESC: Disable script loading
"if !g:pymode || !g:pymode_syntax || pymode#default('b:current_syntax', 'pymode')
"    finish
"endif
"
"" OPTIONS: {{{
"
"" Highlight all by default
"call pymode#default('g:pymode_syntax_all', 1)
"
"" Highlight 'print' as function
"call pymode#default("g:pymode_syntax_print_as_function", 0)
""
"" Highlight 'async/await' keywords
"call pymode#default("g:pymode_syntax_highlight_async_await", g:pymode_syntax_all)
"
"" Highlight '=' operator
"call pymode#default('g:pymode_syntax_highlight_equal_operator', g:pymode_syntax_all)
"
"" Highlight '*' operator
"call pymode#default('g:pymode_syntax_highlight_stars_operator', g:pymode_syntax_all)
"
"" Highlight 'self' keyword
"call pymode#default('g:pymode_syntax_highlight_self', g:pymode_syntax_all)
"
"" Highlight indent's errors
"call pymode#default('g:pymode_syntax_indent_errors', g:pymode_syntax_all)
"
"" Highlight space's errors
"call pymode#default('g:pymode_syntax_space_errors', g:pymode_syntax_all)
"
"" Highlight string formatting
"call pymode#default('g:pymode_syntax_string_formatting', g:pymode_syntax_all)
"call pymode#default('g:pymode_syntax_string_format', g:pymode_syntax_all)
"call pymode#default('g:pymode_syntax_string_templates', g:pymode_syntax_all)
"call pymode#default('g:pymode_syntax_doctests', g:pymode_syntax_all)
"
"" Support docstrings in syntax highlighting
"call pymode#default('g:pymode_syntax_docstrings', 1)
"
"" Highlight builtin objects (True, False, ...)
"call pymode#default('g:pymode_syntax_builtin_objs', g:pymode_syntax_all)
"
"" Highlight builtin types (str, list, ...)
"call pymode#default('g:pymode_syntax_builtin_types', g:pymode_syntax_all)
"
"" Highlight builtin types (div, eval, ...)
"call pymode#default('g:pymode_syntax_builtin_funcs', g:pymode_syntax_all)
"
"" Highlight exceptions (TypeError, ValueError, ...)
"call pymode#default('g:pymode_syntax_highlight_exceptions', g:pymode_syntax_all)
"
"" More slow synchronizing. Disable on the slow machine, but code in docstrings
"" could be broken.
"call pymode#default('g:pymode_syntax_slow_sync', 1)

" }}}

if exists("b:current_syntax")
  finish
endif

" For version 5.x: Clear all syntax items
if version < 600
    syntax clear
endif

" Keywords {{{
" ============

    syn keyword pythonKeyword break continue del
    syn keyword pythonKeyword exec return
    syn keyword pythonKeyword pass raise
    syn keyword pythonKeyword global nonlocal assert
    syn keyword pythonKeyword yield
    syn keyword pythonLambdaExpr lambda
    syn keyword pythonStatement with as

    syn match pythonIdentifier "\h\w*" contained
    syn region pythonGroup matchgroup=pythonBrackets start="(" end=")" contains=pythonGroupParam
    syn match pythonGroupParam "[^)]*" contained contains=pythonIdentifier,pythonKeyword,pythonPunct,pythonOperator,pythonExtraOperator,pythonLambdaExpr,pythonBuiltinObj,pythonBuiltinType,pythonConstant,pythonGroup,pythonString,pythonFunctionCall,pythonNumber,pythonSelf,pythonDot,pythonComment,pythonField,pythonList,pythonGroup skipwhite

    syn keyword pythonCoding def skipwhite
    syn match pythonMagic "__\(abs\|add\|aenter\|aexit\|aiter\|anext\|await\|and\|call\|cmp\|coerce\|complex\|contains\|del\|delattr\|delete\|delitem\|delslice\|div\|divmod\|enter\|eq\|exit\|float\|floordiv\|ge\|get\|getattr\|getattribute\|getitem\|getslice\|gt\|hash\|hex\|iadd\|iand\|idiv\|ifloordiv\|ilshift\|imod\|imul\|init\|int\|invert\|ior\|ipow\|irshift\|isub\|iter\|itruediv\|ixor\|le\|len\|long\|lshift\|lt\|mod\|mul\|ne\|neg\|new\|nonzero\|oct\|or\|pos\|pow\|radd\|rand\|rdiv\|rdivmod\|repr\|rfloordiv\|rlshift\|rmod\|rmul\|ror\|rpow\|rrshift\|rshift\|rsub\|rtruediv\|rxor\|set\|setattr\|setitem\|setslice\|str\|sub\|truediv\|unicode\|xor\)__" contained

    syn match pythonFunctionCall "\h\(\w\)*(\@=" contains=@pythonBuiltinFuncC nextgroup=pythonFuncParams
    syn cluster pythonBuiltinFuncC add=pythonBuiltinFunc,pythonPrint,pythonMagic
    syn region pythonFuncParams matchgroup=pythonBrackets start="(" end=")" contained contains=pythonFuncParam,pythonPunct
    syn match pythonFuncParam "[^,)]*" contained contains=pythonList,pythonBrackets,pythonItemAccess,pythonKeyword,pythonPunct,pythonOperator,pythonExtraOperator,pythonLambdaExpr,pythonBuiltinObj,pythonBuiltinType,pythonConstant,pythonGroup,pythonString,pythonNumber,pythonSelf,pythonDot,pythonComment,pythonField,pythonFunctionCall,pythonIdentifier,pythonGroup skipwhite


    syn match pythonFunction "\(\(def\s\|@\)\s*\)\@<=\h\(\w\|\.\)*" contains=@pythonFuncC nextgroup=pythonVars
    syn cluster pythonFuncC add=pythonMagic
    syn region pythonVars matchgroup=pythonBrackets start="(" skip=+\(".*"\|'.*'\)+ end=")" contained contains=pythonParameters,pythonPunct keepend
    syn match pythonParameters "[^,]*" contained contains=pythonParam skipwhite
    syn match pythonParam "[^,]*" contained contains=pythonPunct,pythonExtraOperator,pythonLambdaExpr,pythonBuiltinObj,pythonBuiltinType,pythonItemAccess,pythonConstant,pythonString,pythonNumber,pythonSelf,pythonDot,pythonComment,pythonField skipwhite

    syn match pythonBrackets "{[(|)]}" contained skipwhite
    syn match pythonBrackets "{\|}" contained skipwhite

    syn keyword pythonSelf class nextgroup=pythonClass skipwhite
    syn match pythonClass "\%(\%(class\s\)\s*\)\@<=\h\%(\w\|\.\)*" contained nextgroup=pythonClassVars
    syn region pythonClassVars matchgroup=pythonBrackets start="(" end=")" contained contains=pythonClassParameters transparent keepend
    syn match pythonClassParameters "[^,\*]*" contained contains=pythonBuiltinObj,pythonBuiltinType,pythonExtraOperator,pythonStatement,pythonBrackets,pythonString,pythonComment skipwhite

    syn keyword pythonKeyword   for while
    syn keyword pythonKeyword   if elif else
    syn keyword pythonKeyword   import from
    syn keyword pythonKeyword   try except finally
    syn keyword pythonOperator      and in is not or

    syn match pythonExtraOperator "\%([~!^&|/%+-]\|\%(class\s*\)\@<!<<\|<=>\|<=\|\%(<\|\<class\s\+\u\w*\s*\)\@<!<[^<]\@=\|===\|==\|=\~\|>>\|>=\|=\@<!>\|\.\.\.\|\.\.\|::\)"
    syn match pythonExtraPseudoOperator "\%(-=\|/=\|\*\*=\|\*=\|&&=\|&=\|&&\|||=\||=\|||\|%=\|+=\|!\~\|!=\)"


    " item access
    syn region pythonAccess matchgroup=pythonBrackets start="\[" end="\]" contained contains=pythonAccessParam
    syn match pythonAccessParam "[^\]]*" contained contains=pythonItemAccess,pythonKeyword,pythonPunct,pythonOperator,pythonExtraOperator,pythonLambdaExpr,pythonBuiltinObj,pythonBuiltinType,pythonConstant,pythonGroup,pythonString,pythonNumber,pythonSelf,pythonDot,pythonComment,pythonField,pythonFunctionCall,pythonIdentifier,pythonGroup,pythonList skipwhite
    syn match pythonItemAccess "\h\(\w\)*\[\@=" nextgroup=pythonAccess

    syn region pythonList matchgroup=pythonBrackets start="\[" end="\]" contains=pythonListParam
    syn match pythonListParam "[^\]]*" contained contains=pythonItemAccess,pythonKeyword,pythonPunct,pythonOperator,pythonExtraOperator,pythonLambdaExpr,pythonBuiltinObj,pythonBuiltinType,pythonConstant,pythonGroup,pythonString,pythonFunctionCall,pythonNumber,pythonSelf,pythonDot,pythonComment,pythonField,pythonList,pythonGroup skipwhite

    syn match pythonPunct ":"
    syn match pythonPunct ","

    " if !g:pymode_syntax_print_as_function
        " syn keyword pythonFunction print
    " endif

    " if g:pymode_syntax_highlight_async_await
        syn keyword pythonStatement async await
        syn match pythonStatement "\<async\s\+def\>" nextgroup=pythonFunction skipwhite
        syn match pythonStatement "\<async\s\+with\>" display
        syn match pythonStatement "\<async\s\+for\>" nextgroup=pythonRepeat skipwhite
    " endif

    " if g:pymode_syntax_highlight_equal_operator
        syn match pythonExtraOperator "\%(=\)"
    " endif

    " if g:pymode_syntax_highlight_stars_operator
        syn match pythonExtraOperator "\%(\*\|\*\*\)"
    " endif

    " if g:pymode_syntax_highlight_self
        syn keyword pythonSelf self cls
    " endif
    syn match pythonField "\(\.\)\@<=\h\w*\([^\.a-zA-Z0-9(\[]\|$\)\@="
    syn match pythonField "\(\.\)\@<=\h\w*\(\.\h\w*[(\[]\)\@="

" }}}


" Decorators {{{
" ==============

    syn match   pythonDecorator "@" display nextgroup=pythonDottedName skipwhite
    syn match   pythonDottedName "[a-zA-Z_][a-zA-Z0-9_]*\(\.[a-zA-Z_][a-zA-Z0-9_]*\)*" display contained
    syn match   pythonDot        "\." display containedin=pythonDottedName

" }}}


" Comments {{{
" ============

    syn match   pythonComment   "#.*$" display contains=pythonTodo,@Spell
    syn match   pythonRun       "\%^#!.*$"
    syn match   pythonCoding    "\%^.*\(\n.*\)\?#.*coding[:=]\s*[0-9A-Za-z-_.]\+.*$"
    syn keyword pythonTodo      TODO FIXME XXX contained

" }}}


" Errors {{{
" ==========

    syn match pythonError       "\<\d\+\D\+\>" display
    syn match pythonError       "[$?]" display
    syn match pythonError       "[&|]\{2,}" display
    syn match pythonError       "[=]\{3,}" display

    " Indent errors (mix space and tabs)
    " if g:pymode_syntax_indent_errors
        syn match pythonIndentError "^\s*\( \t\|\t \)\s*\S"me=e-1 display
    " endif

    " Trailing space errors
    " if g:pymode_syntax_space_errors
    "    syn match pythonSpaceError  "\s\+$" display
    " endif

" }}}

" Strings {{{
" ===========

    syn region pythonString  matchgroup=pythonStringPunc   start=+[bB]\='+ skip=+\\\\\|\\'\|\\$+ excludenl end=+'+ end=+$+ keepend contains=pythonEscape,pythonEscapeError,@Spell
    syn region pythonString  matchgroup=pythonStringPunc   start=+[bB]\="+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end=+$+ keepend contains=pythonEscape,pythonEscapeError,@Spell
    syn region pythonString  matchgroup=pythonStringPunc   start=+[bB]\="""+ end=+"""+ keepend contains=pythonEscape,pythonEscapeError,pythonDocTest2,pythonSpaceError,@Spell
    syn region pythonString  matchgroup=pythonStringPunc   start=+[bB]\='''+ end=+'''+ keepend contains=pythonEscape,pythonEscapeError,pythonDocTest,pythonSpaceError,@Spell

    syn match  pythonEscape     +\\[abfnrtv'"\\]+ display contained
    syn match  pythonEscape     "\\\o\o\=\o\=" display contained
    syn match  pythonEscapeError    "\\\o\{,2}[89]" display contained
    syn match  pythonEscape     "\\x\x\{2}" display contained
    syn match  pythonEscapeError    "\\x\x\=\X" display contained
    syn match  pythonEscape     "\\$"

    " Unicode
    syn region pythonUniString matchgroup=pythonStringPunc start=+[uU]'+ skip=+\\\\\|\\'\|\\$+ excludenl end=+'+ end=+$+ keepend contains=pythonEscape,pythonUniEscape,pythonEscapeError,pythonUniEscapeError,@Spell
    syn region pythonUniString matchgroup=pythonStringPunc start=+[uU]"+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end=+$+ keepend contains=pythonEscape,pythonUniEscape,pythonEscapeError,pythonUniEscapeError,@Spell
    syn region pythonUniString matchgroup=pythonStringPunc start=+[uU]"""+ end=+"""+ keepend contains=pythonEscape,pythonUniEscape,pythonEscapeError,pythonUniEscapeError,pythonDocTest2,pythonSpaceError,@Spell
    syn region pythonUniString matchgroup=pythonStringPunc start=+[uU]'''+ end=+'''+ keepend contains=pythonEscape,pythonUniEscape,pythonEscapeError,pythonUniEscapeError,pythonDocTest,pythonSpaceError,@Spell

    syn match  pythonUniEscape          "\\u\x\{4}" display contained
    syn match  pythonUniEscapeError     "\\u\x\{,3}\X" display contained
    syn match  pythonUniEscape          "\\U\x\{8}" display contained
    syn match  pythonUniEscapeError     "\\U\x\{,7}\X" display contained
    syn match  pythonUniEscape          "\\N{[A-Z ]\+}" display contained
    syn match  pythonUniEscapeError "\\N{[^A-Z ]\+}" display contained

    " Raw strings
    syn region pythonRawString matchgroup=pythonStringPunc start=+[rR]'+ skip=+\\\\\|\\'\|\\$+ excludenl end=+'+ end=+$+ keepend contains=pythonRawEscape,@Spell
    syn region pythonRawString matchgroup=pythonStringPunc start=+[rR]"+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end=+$+ keepend contains=pythonRawEscape,@Spell
    syn region pythonRawString matchgroup=pythonStringPunc start=+[rR]"""+ end=+"""+ keepend contains=pythonDocTest2,pythonSpaceError,@Spell
    syn region pythonRawString matchgroup=pythonStringPunc start=+[rR]'''+ end=+'''+ keepend contains=pythonDocTest,pythonSpaceError,@Spell

    syn match pythonRawEscape           +\\['"]+ display transparent contained

    " Unicode raw strings
    syn region pythonUniRawString matchgroup=pythonStringPunc start=+[uU][rR]'+ skip=+\\\\\|\\'\|\\$+ excludenl end=+'+ end=+$+ keepend contains=pythonRawEscape,pythonUniRawEscape,pythonUniRawEscapeError,@Spell
    syn region pythonUniRawString matchgroup=pythonStringPunc start=+[uU][rR]"+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end=+$+ keepend contains=pythonRawEscape,pythonUniRawEscape,pythonUniRawEscapeError,@Spell
    syn region pythonUniRawString matchgroup=pythonStringPunc start=+[uU][rR]"""+ end=+"""+ keepend contains=pythonUniRawEscape,pythonUniRawEscapeError,pythonDocTest2,pythonSpaceError,@Spell
    syn region pythonUniRawString matchgroup=pythonStringPunc start=+[uU][rR]'''+ end=+'''+ keepend contains=pythonUniRawEscape,pythonUniRawEscapeError,pythonDocTest,pythonSpaceError,@Spell

    syn match  pythonUniRawEscape   "\([^\\]\(\\\\\)*\)\@<=\\u\x\{4}" display contained
    syn match  pythonUniRawEscapeError  "\([^\\]\(\\\\\)*\)\@<=\\u\x\{,3}\X" display contained

    " String formatting
    " if g:pymode_syntax_string_formatting
        syn match pythonStrFormatting   "%\(([^)]\+)\)\=[-#0 +]*\d*\(\.\d\+\)\=[hlL]\=[diouxXeEfFgGcrs%]" contained containedin=pythonString,pythonUniString,pythonRawString,pythonUniRawString
        syn match pythonStrFormatting   "%[-#0 +]*\(\*\|\d\+\)\=\(\.\(\*\|\d\+\)\)\=[hlL]\=[diouxXeEfFgGcrs%]" contained containedin=pythonString,pythonUniString,pythonRawString,pythonUniRawString
    " endif

    " Str.format syntax
    " if g:pymode_syntax_string_format
        syn match pythonStrFormat "{{\|}}" contained containedin=pythonString,pythonUniString,pythonRawString,pythonUniRawString
        syn match pythonStrFormat "{\([a-zA-Z0-9_]*\|\d\+\)\(\.[a-zA-Z_][a-zA-Z0-9_]*\|\[\(\d\+\|[^!:\}]\+\)\]\)*\(![rs]\)\=\(:\({\([a-zA-Z_][a-zA-Z0-9_]*\|\d\+\)}\|\([^}]\=[<>=^]\)\=[ +-]\=#\=0\=\d*\(\.\d\+\)\=[bcdeEfFgGnoxX%]\=\)\=\)\=}" contained containedin=pythonString,pythonUniString,pythonRawString,pythonUniRawString
    " endif

    " String templates
    " if g:pymode_syntax_string_templates
        syn match pythonStrTemplate "\$\$" contained containedin=pythonString,pythonUniString,pythonRawString,pythonUniRawString
        syn match pythonStrTemplate "\${[a-zA-Z_][a-zA-Z0-9_]*}" contained containedin=pythonString,pythonUniString,pythonRawString,pythonUniRawString
        syn match pythonStrTemplate "\$[a-zA-Z_][a-zA-Z0-9_]*" contained containedin=pythonString,pythonUniString,pythonRawString,pythonUniRawString
    " endif

    " DocTests
    " if g:pymode_syntax_doctests
        syn region pythonDocTest    start="^\s*>>>" end=+'''+he=s-1 end="^\s*$" contained
        syn region pythonDocTest2   start="^\s*>>>" end=+"""+he=s-1 end="^\s*$" contained
    " endif

    " DocStrings
    " if g:pymode_syntax_docstrings
        syn region pythonDocstring  start=+^\s*[uU]\?[rR]\?"""+ end=+"""+ keepend excludenl contains=pythonEscape,@Spell,pythonDoctest,pythonDocTest2,pythonSpaceError
        syn region pythonDocstring  start=+^\s*[uU]\?[rR]\?'''+ end=+'''+ keepend excludenl contains=pythonEscape,@Spell,pythonDoctest,pythonDocTest2,pythonSpaceError
    " endif


" }}}

" Numbers {{{
" ===========

    syn match   pythonHexError  "\<0[xX]\x*[g-zG-Z]\x*[lL]\=\>" display
    syn match   pythonHexNumber "\<0[xX]\x\+[lL]\=\>" display
    syn match   pythonOctNumber "\<0[oO]\o\+[lL]\=\>" display
    syn match   pythonBinNumber "\<0[bB][01]\+[lL]\=\>" display
    syn match   pythonNumber    "\<\d\+[lLjJ]\=\>" display
    syn match   pythonFloat "\.\d\+\([eE][+-]\=\d\+\)\=[jJ]\=\>" display
    syn match   pythonFloat "\<\d\+[eE][+-]\=\d\+[jJ]\=\>" display
    syn match   pythonFloat "\<\d\+\.\d*\([eE][+-]\=\d\+\)\=[jJ]\=" display
    syn match   pythonOctError  "\<0[oO]\=\o*[8-9]\d*[lL]\=\>" display
    syn match   pythonBinError  "\<0[bB][01]*[2-9]\d*[lL]\=\>" display

" }}}

" Builtins {{{
" ============

    " Builtin objects and types
    " if g:pymode_syntax_builtin_objs
        syn keyword pythonConstant True False Ellipsis None NotImplemented
        syn match pythonConstant '\<[A-Z_][A-Z_0-9]\+\>'
        syn keyword pythonBuiltinObj __debug__ __doc__ __file__ __name__ __package__
    " endif

    " if g:pymode_syntax_builtin_types
        syn keyword pythonBuiltinType type object
        syn keyword pythonBuiltinType str basestring unicode buffer bytearray bytes chr unichr
        syn keyword pythonBuiltinType dict int long bool float complex set frozenset list tuple
        syn keyword pythonBuiltinType file super
    " endif

    " Builtin functions
    " if g:pymode_syntax_builtin_funcs
        syn keyword pythonBuiltinFunc contained   __import__ abs all any apply
        syn keyword pythonBuiltinFunc contained   bin callable classmethod cmp coerce compile
        syn keyword pythonBuiltinFunc contained   delattr dir divmod enumerate eval execfile filter
        syn keyword pythonBuiltinFunc contained   format getattr globals locals hasattr hash help hex id
        syn keyword pythonBuiltinFunc contained   input intern isinstance issubclass iter len map max min
        syn keyword pythonBuiltinFunc contained   next oct open ord pow property range xrange
        syn keyword pythonBuiltinFunc contained   raw_input reduce reload repr reversed round setattr
        syn keyword pythonBuiltinFunc contained   slice sorted staticmethod sum vars zip len

        " if g:pymode_syntax_print_as_function
            syn keyword pythonPrint contained  print
        " endif

    " endif


    " Builtin exceptions and warnings
    " if g:pymode_syntax_highlight_exceptions
        syn keyword pythonExClass   BaseException
        syn keyword pythonExClass   Exception StandardError ArithmeticError
        syn keyword pythonExClass   LookupError EnvironmentError
        syn keyword pythonExClass   AssertionError AttributeError BufferError EOFError
        syn keyword pythonExClass   FloatingPointError GeneratorExit IOError
        syn keyword pythonExClass   ImportError IndexError KeyError
        syn keyword pythonExClass   KeyboardInterrupt MemoryError NameError
        syn keyword pythonExClass   NotImplementedError OSError OverflowError
        syn keyword pythonExClass   ReferenceError RuntimeError StopIteration
        syn keyword pythonExClass   SyntaxError IndentationError TabError
        syn keyword pythonExClass   SystemError SystemExit TypeError
        syn keyword pythonExClass   UnboundLocalError UnicodeError
        syn keyword pythonExClass   UnicodeEncodeError UnicodeDecodeError
        syn keyword pythonExClass   UnicodeTranslateError ValueError VMSError
        syn keyword pythonExClass   WindowsError ZeroDivisionError
        syn keyword pythonExClass   Warning UserWarning BytesWarning DeprecationWarning
        syn keyword pythonExClass   PendingDepricationWarning SyntaxWarning
        syn keyword pythonExClass   RuntimeWarning FutureWarning
        syn keyword pythonExClass   ImportWarning UnicodeWarning
    " endif

    syn region pythonJedi matchgroup=Type start="?!?" end="?!?"

" }}}


" if g:pymode_syntax_slow_sync
 "   syn sync minlines=2000
"else
    " This is fast but code inside triple quoted strings screws it up. It
    " is impossible to fix because the only way to know if you are inside a
    " triple quoted string is to start from the beginning of the file.
    syn sync match pythonSync grouphere NONE "):$"
    syn sync maxlines=200
"endif

" Highlight {{{
" =============

    hi link  pythonStatement    Statement
    hi link  pythonKeyword      Keyword
    hi link  pythonLambdaExpr   Statement
    hi link  pythonInclude      Include
    hi link  pythonConstant     Constant
    hi link  pythonFunction     Function
    hi link  pythonFunctionCall Function
    hi link  pythonClass        Function
    highlight pythonClass ctermfg=4 guifg=#82aaff cterm=bold gui=bold
    hi link  pythonParameters   Normal
    hi link  pythonParam        Identifier
    hi link  pythonBrackets     PreProc
    hi link  pythonClassParameters Normal
    hi link  pythonSelf         Identifier
    highlight pythonSelf ctermfg=3 guifg=#ffb62c cterm=italic gui=italic

    hi link  pythonMagic        Language

    hi link  pythonConditional  Conditional
    hi link  pythonRepeat       Repeat
    hi link  pythonException    Exception
    hi link  pythonOperator     Operator
    hi link  pythonExtraOperator        pythonOperator
    hi link  pythonExtraPseudoOperator  pythonOperator

    hi link  pythonDecorator    Define
    hi link  pythonDottedName   Function
    hi link  pythonDot          PreProc

    hi link  pythonComment      Comment
    hi! link  pythonCoding       Special
    highlight pythonCoding ctermfg=1 guifg=#e53935 cterm=italic gui=italic
    hi link  pythonRun          Special
    hi link  pythonTodo         Todo

    hi link  pythonError        Error
    hi link  pythonIndentError  Error
    hi link  pythonSpaceError   Error

    hi link  pythonString       String
    hi link  pythonStringPunc   StringPunct
    hi link  pythonDocstring    Comment
    hi link  pythonUniString    String
    hi link  pythonRawString    String
    hi link  pythonUniRawString String

    hi link  pythonEscape       PreProc
    highlight pythonEscape ctermfg=14 cterm=bold
    hi link  pythonEscapeError  Error
    hi link  pythonUniEscape    PreProc
    hi link  pythonUniEscapeError Error
    hi link  pythonUniRawEscape PreProc
    hi link  pythonUniRawEscapeError Error

    hi link  pythonStrFormatting PreProc
    hi link  pythonStrFormat    PreProc
    hi link  pythonStrTemplate  PreProc

    hi link  pythonDocTest      Special
    hi link  pythonDocTest2     Special

    hi link  pythonNumber       Number
    hi link  pythonHexNumber    Number
    hi link  pythonOctNumber    Number
    hi link  pythonBinNumber    Number
    hi link  pythonFloat        Float
    hi link  pythonOctError     Error
    hi link  pythonHexError     Error
    hi link  pythonBinError     Error

    hi link  pythonBuiltinType  Type
    highlight pythonBuiltinType ctermfg=156
    hi link  pythonBuiltinObj   Structure
    hi link  pythonBuiltinFunc  Function
    highlight pythonBuiltinFunc ctermfg=202

    hi link  pythonPreProc      PreProc
    hi link  pythonItemAccess   Special
    highlight pythonField ctermfg=250 guifg=#bcbcbc

    hi link  pythonExClass      Structure
    hi link  pythonJedi         Type
    hi link  pythonPunct        PreProc
    hi link  pythonIdentifier   Identifier
    hi link  pythonPrint        Keyword

let b:current_syntax = "python"

" }}}
