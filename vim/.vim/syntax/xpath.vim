if exists('b:current_syntax')
    finish
endif

syn iskeyword @,48-57,192-255,_,-

syn match xpathParam     "\w\+"                     display
syn match xpathReference "\$\@1<=\w[a-zA-Z0-9\-_]*" display
syn match xpathOperator  "\$"                       display
syn match xpathNameSpace '\w\+:\@='                 display
syn match xpathPunct     "[,/\[\]()]"               display
syn match xpathP2        "[:\.]"                    display
syn match xpathOperator  "[=\*@+-]"                  display
syn match xpathNumber    "[0-9]\+\>"                display
syn match xpathOperator  "[!=\>\<]\+"               display
syn keyword xpathOperator or and xor
syn keyword xpathLangVar body ctx trp

syn match xpathSpec "fn"

syn match   xmlEntity                 "&[^; \t]*;" contains=xmlEntityPunct display
syn match   xmlEntityPunct  contained "[&.;]" display

syn match xpathFuncError "\k\+" contained

syn match xpathFunction "\k\+(\@=" contains=xpathFuncName,xpathFuncError display

syn keyword xpathFuncName substring string-join string-length upper-case lower-case escape-uri starts-with ends-with contained
syn keyword xpathFuncName substring-before substring-after index-of get-property json-eval contained
syn match xpathFuncName "\<contains\>" contained display
syn keyword xpathFuncName number abs ceiling floor round string compare concat adjust-dateTime-to-timezone contained
syn keyword xpathFuncName matches replce boolean not true false dateTime name root remove empty exists reverse contained
syn keyword xpathFuncName subsequence count avg max min sum id node position last translate text format-dateTime contained
syn keyword xpathFuncName dayTimeDuration contained


" STRINGS
syn region xpathString matchgroup=xpathQuote start=+'+ end=+'+ display

hi def link xmlEntity		Statement
hi def link xmlEntityPunct	PreProc

function! s:hi(group, target) abort
  if &t_Co >= 256 || has('gui_running')
    let italic = 1
  else
    let italic = 0
  endif
  let target_id = synIDtrans(hlID(a:target))
  let t_fg = synIDattr(target_id, 'fg', 'cterm')
  let t_bg = synIDattr(target_id, 'bg', 'cterm')
  let t_fmt = synIDattr(target_id, 'reverse', 'cterm') ? 'reverse,' : ''
  let g_fg = synIDattr(target_id, 'fg', 'gui')
  let g_bg = synIDattr(target_id, 'bg', 'gui')
  let g_fmt = synIDattr(target_id, 'reverse', 'gui') ? 'reverse,' : ''
  let Syn = {x -> len(x) ? x : 'NONE'}
  execute 'highlight ' . a:group . ' ctermfg=' . Syn(t_fg) . ' ctermbg=' . Syn(t_bg) .
        \ ' guifg=' . Syn(g_fg) . ' guibg=' . Syn(g_bg) .
        \ (italic ? ' cterm=' . t_fmt . 'italic gui=' . g_fmt . 'italic' : '')
endfunction

function! s:xpathHighlight() abort

  if get(g:, 'colors_name', '') ==# 'material' || get(g:, 'colors_name', '') ==# 'nord'
    call <SID>hi('xpathFuncError', 'Error')
    call <SID>hi('xpathQuote',     'StringDelimiter')
    call <SID>hi('xpathString',    'String')
    call <SID>hi('xpathFuncName',  'Function')
    call <SID>hi('xpathNumber',    'Constant')
    call <SID>hi('xpathParam',     'Builtin')
    call <SID>hi('xpathPunct',     'Delimiter')
    call <SID>hi('xpathLangVar',   'Language')
    call <SID>hi('xpathReference', 'StringDelimiter')
    call <SID>hi('xpathOperator',  'Operator')
    call <SID>hi('xpathP2',        'Delimiter')
    call <SID>hi('xpathSpec',      'Special')
    call <SID>hi('xpathNameSpace', 'Language')
  else
    call <SID>hi('xpathFuncError', 'String')
    call <SID>hi('xpathQuote',     'String')
    call <SID>hi('xpathString',    'String')
    call <SID>hi('xpathFuncName',  'String')
    call <SID>hi('xpathNumber',    'String')
    call <SID>hi('xpathParam',     'String')
    call <SID>hi('xpathPunct',     'String')
    call <SID>hi('xpathLangVar',   'String')
    call <SID>hi('xpathReference', 'String')
    call <SID>hi('xpathOperator',  'String')
    call <SID>hi('xpathP2',        'String')
    call <SID>hi('xpathSpec',      'String')
    call <SID>hi('xpathNameSpace', 'String')
  endif

endfunction
call s:xpathHighlight()

augroup xpathHighlight
  autocmd!
  autocmd ColorScheme material call s:xpathHighlight()
augroup END

let b:current_syntax = 'xpath'
