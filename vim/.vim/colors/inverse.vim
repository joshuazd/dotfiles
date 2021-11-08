highlight clear
if exists('syntax_on')
    syntax reset
endif

set background=dark

let g:colors_name  = 'inverse'

" Colors

let s:red          = {'term' : '167', 'gui' : '#d75f5f'}
let s:boldred      = {'term' : '131', 'gui' : '#af5f5f'}
let s:pink         = {'term' : '210', 'gui' : '#f07178'}
let s:pink         = {'term' : '174', 'gui' : '#d78787'}
let s:orange       = {'term' : '173', 'gui' : '#d7875f'}
let s:yellow       = {'term' : '222', 'gui' : '#ffd787'}
let s:boldyellow   = {'term' : '215', 'gui' : '#ffaf5f'}
let s:green        = {'term' : '114', 'gui' : '#87d787'}
let s:green        = {'term' : '115', 'gui' : '#87d7af'}
let s:boldgreen    = {'term' : '108', 'gui' : '#87af87'}
let s:blue         = {'term' : '110', 'gui' : '#87afd7'}
let s:boldblue     = {'term' : '67',  'gui' : '#5f87af'}
let s:cyan         = {'term' : '73',  'gui' : '#5fafaf'}
let s:boldcyan     = {'term' : '152', 'gui' : '#afd7d7'}
let s:bluegrey     = {'term' : '248', 'gui' : '#a8a8a8'}
let s:purple       = {'term' : '140', 'gui' : '#af87d7'}
let s:boldpurple   = {'term' : '97',  'gui' : '#875faf'}
let s:boldpurple   = {'term' : '103',  'gui' : '#8787af'}
let s:darkpurple   = {'term' : '53',  'gui' : '#5f005f'}
let s:magenta      = {'term' : '55',  'gui' : '#5f00af'}
let s:blurple      = {'term' : '60',  'gui' : '#5f5f87'}
let s:brown        = {'term' : '137', 'gui' : '#ab7967'}
let s:lightgrey    = {'term' : '246', 'gui' : '#949494'}
let s:mediumgrey   = {'term' : '236', 'gui' : '#303030'}
let s:darkgrey     = {'term' : '234', 'gui' : '#1c1c1c'}
let s:darkdarkgrey = {'term' : '233', 'gui' : '#121212'}
let s:grey         = {'term' : '59',  'gui' : '#56513c'}
let s:grey         = {'term' : '59',  'gui' : '#45403a'}
let s:black        = {'term' : '16',  'gui' : '#000000'}
let s:background   = {'term' : 'NONE','gui' : '#b4af9a'}
let s:white        = {'term' : '251', 'gui' : '#c6c6c6'}
let s:none         = {'term' : 'NONE','gui' : 'NONE'}
let s:darkbg       = {'term' : '101', 'gui' : '#777467'}
let s:bland        = {'term' : '102', 'gui' : '#878787'}
let s:light        = {'term' : '102', 'gui' : '#999483'}

function! s:h(hl, bg, fg, fmt) abort
  exe 'hi! '.a:hl.' ctermfg='.a:fg['term'].' guifg='.a:fg['gui']
        \.' ctermbg='.a:bg['term'].' guibg='.a:bg['gui']
        \.' cterm='.a:fmt.' gui='.a:fmt
endfunction

"----------------------------------------------------------------
"        Syntax group     | Background  | Foreground    | Style |
"----------------------------------------------------------------

call s:h('Normal',          s:background,      s:grey,   'none')
call s:h('LineNr',          s:grey,       s:background,   'none')
call s:h('CursorLine',      s:none,       s:mediumgrey,   'none')
call s:h('CursorLineNR',    s:boldcyan,   s:background,   'none')
call s:h('Cursor',          s:white,      s:none,         'none')

call s:h('CursorColumn',    s:none,       s:mediumgrey,   'none')
call s:h('FoldColumn',      s:none,       s:background,   'none')
call s:h('SignColumn',      s:none,       s:background,   'none')
call s:h('Folded',          s:grey,  s:background,     'none')

call s:h('VertSplit',       s:lightgrey,  s:background,   'none')
call s:h('ColorColumn',     s:light,       s:none,   'none')

call s:h('Directory',       s:blue,       s:grey,   'none')
call s:h('Search',          s:yellow,      s:black,       'bold')
call s:h('IncSearch',       s:yellow,      s:black,       'bold')

call s:h('WildMenu',        s:boldgreen,  s:mediumgrey,   'none')
call s:h('Question',        s:boldgreen,  s:grey,   'none')
call s:h('Title',           s:yellow,     s:grey,   'none')
call s:h('ModeMsg',         s:boldgreen,  s:grey,   'none')
call s:h('MoreMsg',         s:boldgreen,  s:grey,   'none')

call s:h('MatchParen',      s:background,   s:red,   'bold')
call s:h('Visual',          s:darkbg,       s:white,   'none')
call s:h('NonText',         s:light,    s:background,   'none')
call s:h('Todo',            s:green,      s:darkbg,   'bold')
call s:h('Underlined',      s:blue,       s:grey,   'underline')
call s:h('Error',           s:darkpurple, s:boldred,      'underline')
call s:h('ErrorMsg',        s:black,      s:red,          'none')
call s:h('WarningMsg',      s:black,      s:orange,       'none')
call s:h('Ignore',          s:none,       s:background,   'none')
call s:h('SpecialKey',      s:background,    s:light,   'none')

call s:h('Constant',        s:cyan,       s:grey,   'none')
call s:h('String',          s:boldgreen,  s:grey,   'none')
call s:h('StringDelimiter', s:boldgreen,  s:grey,   'none')
call s:h('Character',       s:cyan,       s:grey,   'none')
call s:h('Number',          s:cyan,       s:grey,   'none')
call s:h('Boolean',         s:cyan,       s:grey,   'none')
call s:h('Float',           s:cyan,       s:grey,   'none')
call s:h('Identifier',      s:yellow,     s:grey,   'none')
call s:h('Function',        s:blue,       s:grey,   'none')
call s:h('Primitive',       s:boldyellow, s:grey,   'italic')

call s:h('Statement',       s:purple,     s:grey,   'none')
call s:h('Conditional',     s:purple,     s:grey,   'none')
call s:h('Repeat',          s:purple,     s:grey,   'none')
call s:h('Label',           s:purple,     s:grey,   'none')
call s:h('Operator',        s:background,      s:grey,   'none')
call s:h('Keyword',         s:purple,     s:grey,   'none')
call s:h('Comment',         s:background,       s:darkbg,   'italic')
call s:h('Builtin',         s:orange,     s:grey,   'none')
call s:h('Language',        s:pink,       s:grey,   'none')
call s:h('Special',         s:red,        s:grey,   'none')
call s:h('SpecialChar',     s:cyan,       s:grey,   'bold')
call s:h('Tag',             s:bland,        s:grey,   'none')
call s:h('Delimiter',       s:background,   s:grey,   'none')
call s:h('Coding',          s:red,        s:grey,   'italic')

call s:h('PreProc',         s:boldcyan,   s:grey,   'none')
call s:h('Include',         s:purple,     s:grey,   'none')
call s:h('Type',            s:yellow,     s:grey,   'none')
call s:h('Storage',         s:boldpurple, s:grey,   'none')
call s:h('StorageClass',    s:green,      s:grey,   'none')
call s:h('Structure',       s:boldcyan,   s:grey,   'none')
call s:h('Class',           s:boldblue,   s:background,   'bold')

call s:h('DiffAdd',         s:boldgreen,  s:darkdarkgrey, 'none')
call s:h('DiffChange',      s:yellow,     s:darkdarkgrey, 'none')
call s:h('DiffDelete',      s:red,        s:darkdarkgrey, 'none')
call s:h('DiffText',        s:black,      s:lightgrey,    'none')
call s:h('diffAdded',       s:boldgreen,  s:grey,   'none')

call s:h('Pmenu',           s:grey,      s:background,   'none')
call s:h('PmenuSel',        s:background,      s:grey,   'none')

call s:h('SpellBad',        s:darkpurple, s:boldred,      'none')
call s:h('SpellCap',        s:darkpurple, s:boldblue,     'none')
call s:h('SpellLocal',      s:cyan,       s:boldcyan,     'none')
call s:h('SpellRare',       s:purple,     s:boldpurple,   'none')

call s:h('StatusLine',      s:grey,      s:background,   'none')
call s:h('StatusLineNC',    s:light,      s:darkbg,    'none')

call s:h('TabLine',         s:black,      s:lightgrey,    'none')
call s:h('TabLineFill',     s:black,      s:lightgrey,    'none')
call s:h('TabLineSel',      s:white,      s:mediumgrey,   'bold')

call s:h('Sneak',           s:white,      s:magenta,      'none')
call s:h('SneakLabel',      s:white,      s:magenta,      'none')
call s:h('SneakLabelMask',  s:magenta,    s:magenta,      'none')
