highlight clear
if exists('syntax_on')
    syntax reset
endif

set background=dark

let g:colors_name = 'important'

" Colors

let s:red        = {'term' : '131', 'gui' : '#ff5f5f'}
let s:boldred    = {'term' : '167', 'gui' : '#d75f5f'}
let s:pink       = {'term' : '210', 'gui' : '#f07178'}
let s:orange     = {'term' : '209', 'gui' : '#f76d47'}
let s:yellow     = {'term' : '222', 'gui' : '#ffcb6b'}
let s:boldyellow = {'term' : '215', 'gui' : '#ffb62c'}
let s:green      = {'term' : '109', 'gui' : '#87afaf'}
let s:boldgreen  = {'term' : '108', 'gui' : '#87af87'}
let s:blue       = {'term' : '67',  'gui' : '#5f87af'}
let s:boldblue   = {'term' : '67',  'gui' : '#5f87af'}
let s:cyan       = {'term' : '73',  'gui' : '#5fafaf'}
let s:boldcyan   = {'term' : '116', 'gui' : '#87d7d7'}
let s:bluegrey   = {'term' : '59',  'gui' : '#5f5f5f'}
let s:purple     = {'term' : '139', 'gui' : '#af87d7'}
let s:boldpurple = {'term' : '97',  'gui' : '#945eb8'}
let s:darkpurple = {'term' : '53',  'gui' : '#5f005f'}
let s:magenta    = {'term' : '55',  'gui' : '#5f00af'}
let s:blurple    = {'term' : '60',  'gui' : '#5f5f87'}
let s:brown      = {'term' : '95',  'gui' : '#ab7967'}
let s:background = {'term' : 'NONE','gui' : '#262626'}
let s:white      = {'term' : '250', 'gui' : '#bbbbbb'}
let s:black      = {'term' : '16',  'gui' : '#000000'}
let s:grey0      = {'term' : '232', 'gui' : '#080808'}
let s:grey1      = {'term' : '233', 'gui' : '#121212'}
let s:grey2      = {'term' : '234', 'gui' : '#1c1c1c'}
let s:grey3      = {'term' : '235', 'gui' : '#262626'}
let s:grey4      = {'term' : '236', 'gui' : '#303030'}
let s:grey5      = {'term' : '237', 'gui' : '#3a3a3a'}
let s:grey6      = {'term' : '238', 'gui' : '#444444'}
let s:grey7      = {'term' : '239', 'gui' : '#4e4e4e'}
let s:grey8      = {'term' : '240', 'gui' : '#585858'}
let s:grey9      = {'term' : '241', 'gui' : '#626262'}
let s:grey10     = {'term' : '242', 'gui' : '#6c6c6c'}
let s:grey11     = {'term' : '243', 'gui' : '#767676'}
let s:grey12     = {'term' : '244', 'gui' : '#808080'}
let s:grey13     = {'term' : '245', 'gui' : '#8a8a8a'}
let s:grey14     = {'term' : '246', 'gui' : '#949494'}
let s:grey15     = {'term' : '247', 'gui' : '#9e9e9e'}
let s:grey16     = {'term' : '248', 'gui' : '#a8a8a8'}
let s:grey17     = {'term' : '249', 'gui' : '#b2b2b2'}
let s:grey18     = {'term' : '250', 'gui' : '#bcbcbc'}
let s:grey19     = {'term' : '251', 'gui' : '#c6c6c6'}
let s:grey20     = {'term' : '252', 'gui' : '#d0d0d0'}
let s:grey21     = {'term' : '253', 'gui' : '#dadada'}
let s:grey22     = {'term' : '254', 'gui' : '#e4e4e4'}
let s:grey23     = {'term' : '255', 'gui' : '#eeeeee'}
let s:none       = {'term' : 'NONE','gui' : 'NONE'}

function! s:h(hl, fg, bg, fmt) abort
  exe 'hi! '.a:hl.' ctermfg='.a:fg['term'].' guifg='.a:fg['gui']
        \.' ctermbg='.a:bg['term'].' guibg='.a:bg['gui']
        \.' cterm='.a:fmt.' gui='.a:fmt
endfunction

"----------------------------------------------------------------
"        Syntax group     | Foreground  | Background    | Style |
"----------------------------------------------------------------

call s:h('Normal',          s:grey16,     s:background, 'none')
call s:h('LineNr',          s:grey9,      s:background, 'none')
call s:h('CursorLine',      s:none,       s:grey4,      'none')
call s:h('CursorLineNR',    s:white,      s:background, 'none')

call s:h('CursorColumn',    s:none,       s:grey4,      'none')
call s:h('FoldColumn',      s:none,       s:background, 'none')
call s:h('SignColumn',      s:none,       s:background, 'none')
call s:h('Folded',          s:grey14,     s:grey2,      'none')

call s:h('VertSplit',       s:grey2,      s:grey2,      'none')
call s:h('ColorColumn',     s:none,       s:grey4,      'none')

call s:h('Directory',       s:blue,       s:background, 'none')
call s:h('Search',          s:black,      s:yellow,     'none')
call s:h('IncSearch',       s:black,      s:yellow,     'none')

call s:h('WildMenu',        s:boldgreen,  s:grey4,      'none')
call s:h('Question',        s:boldgreen,  s:background, 'none')
call s:h('Title',           s:yellow,     s:background, 'none')
call s:h('ModeMsg',         s:boldgreen,  s:background, 'none')
call s:h('MoreMsg',         s:boldgreen,  s:background, 'none')

call s:h('MatchParen',      s:boldcyan,   s:grey4,      'none')
call s:h('Visual',          s:none,       s:grey4,      'none')
call s:h('NonText',         s:blurple,    s:background, 'none')
call s:h('Todo',            s:green,      s:background, 'bold')
call s:h('Underlined',      s:blue,       s:background, 'underline')
call s:h('Error',           s:darkpurple, s:boldred,    'underline')
call s:h('ErrorMsg',        s:black,      s:red,        'none')
call s:h('WarningMsg',      s:black,      s:orange,     'none')
call s:h('Ignore',          s:none,       s:background, 'none')
call s:h('SpecialKey',      s:white,      s:background, 'none')

call s:h('Constant',        s:cyan,       s:background, 'none')
call s:h('String',          s:boldgreen,  s:background, 'none')
call s:h('StringDelimiter', s:green,      s:background, 'none')
call s:h('Character',       s:white,      s:background, 'none')
call s:h('Number',          s:cyan,       s:background, 'none')
call s:h('Boolean',         s:cyan,       s:background, 'none')
call s:h('Float',           s:cyan,       s:background, 'none')
call s:h('Identifier',      s:white,      s:background, 'none')
call s:h('Function',        s:blue,       s:background, 'none')
call s:h('Primitive',       s:white,      s:background, 'italic')

call s:h('Statement',       s:grey23,     s:background, 'none')
call s:h('Conditional',     s:grey23,     s:background, 'none')
call s:h('Repeat',          s:grey23,     s:background, 'none')
call s:h('Label',           s:grey23,     s:background, 'none')
call s:h('Operator',        s:grey10,     s:background, 'none')
call s:h('Keyword',         s:white,      s:background, 'none')
call s:h('Exception',       s:grey23,     s:background, 'none')
call s:h('Comment',         s:grey9,      s:background, 'none')
call s:h('Builtin',         s:white,      s:background, 'none')
call s:h('Language',        s:white,      s:background, 'none')
call s:h('Special',         s:red,        s:background, 'none')
call s:h('SpecialChar',     s:white,      s:background, 'bold')
call s:h('Tag',             s:grey14,     s:background, 'none')
call s:h('Delimiter',       s:bluegrey,   s:background, 'none')
call s:h('Coding',          s:white,      s:background, 'italic')

call s:h('PreProc',         s:grey16,     s:background, 'none')
call s:h('Include',         s:white,      s:background, 'none')
call s:h('Type',            s:white,      s:background, 'none')
call s:h('StorageClass',    s:white,      s:background, 'none')
call s:h('Structure',       s:white,      s:background, 'none')
call s:h('Class',           s:white,      s:background, 'bold')

call s:h('DiffAdd',         s:boldgreen,  s:grey1,      'none')
call s:h('DiffChange',      s:yellow,     s:grey1,      'none')
call s:h('DiffDelete',      s:red,        s:grey1,      'none')
call s:h('DiffText',        s:black,      s:grey14,     'none')
call s:h('diffAdded',       s:boldgreen,  s:background, 'none')

call s:h('Pmenu',           s:white,      s:grey4,      'none')
call s:h('PmenuSel',        s:white,      s:grey4,      'reverse')

call s:h('SpellBad',        s:darkpurple, s:boldred,    'none')
call s:h('SpellCap',        s:darkpurple, s:boldblue,   'none')
call s:h('SpellLocal',      s:cyan,       s:boldcyan,   'none')
call s:h('SpellRare',       s:purple,     s:boldpurple, 'none')

call s:h('StatusLine',      s:white,      s:grey2,      'none')
call s:h('StatusLineNC',    s:black,      s:grey14,     'none')

call s:h('TabLine',         s:black,      s:grey14,     'none')
call s:h('TabLineFill',     s:black,      s:grey14,     'none')
call s:h('TabLineSel',      s:white,      s:grey4,      'bold')

call s:h('Sneak',           s:white,      s:magenta,    'none')
call s:h('SneakLabel',      s:white,      s:magenta,    'none')
call s:h('SneakLabelMask',  s:magenta,    s:magenta,    'none')

