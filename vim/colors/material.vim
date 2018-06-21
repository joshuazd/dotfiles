highlight clear
if exists('syntax_on')
    syntax reset
endif

set background=dark

let g:colors_name  = 'material'

" Colors

let s:red          = {'term' : '203', 'gui' : '#ff5f5f'}
let s:boldred      = {'term' : '167', 'gui' : '#d75f5f'}
let s:pink         = {'term' : '210', 'gui' : '#f07178'}
let s:orange       = {'term' : '209', 'gui' : '#ff875f'}
let s:yellow       = {'term' : '222', 'gui' : '#ffd787'}
let s:boldyellow   = {'term' : '215', 'gui' : '#ffaf5f'}
let s:green        = {'term' : '114', 'gui' : '#87d787'}
let s:boldgreen    = {'term' : '108', 'gui' : '#87af87'}
let s:blue         = {'term' : '111', 'gui' : '#87aaff'}
let s:boldblue     = {'term' : '67',  'gui' : '#5f87af'}
let s:cyan         = {'term' : '73',  'gui' : '#39adb5'}
let s:boldcyan     = {'term' : '116', 'gui' : '#87d7d7'}
let s:bluegrey     = {'term' : '248', 'gui' : '#a8a8a8'}
let s:purple       = {'term' : '140', 'gui' : '#af87d7'}
let s:boldpurple   = {'term' : '97',  'gui' : '#875faf'}
let s:darkpurple   = {'term' : '53',  'gui' : '#5f005f'}
let s:magenta      = {'term' : '55',  'gui' : '#5f00af'}
let s:blurple      = {'term' : '60',  'gui' : '#5f5f87'}
let s:brown        = {'term' : '137', 'gui' : '#af785f'}
let s:lightgrey    = {'term' : '246', 'gui' : '#949494'}
let s:mediumgrey   = {'term' : '236', 'gui' : '#303030'}
let s:darkgrey     = {'term' : '234', 'gui' : '#1c1c1c'}
let s:darkdarkgrey = {'term' : '233', 'gui' : '#121212'}
let s:grey         = {'term' : '241', 'gui' : '#626262'}
let s:black        = {'term' : '16',  'gui' : '#000000'}
let s:background   = {'term' : 'NONE','gui' : '#262626'}
let s:white        = {'term' : '251', 'gui' : '#c6c6c6'}
let s:none         = {'term' : 'NONE','gui' : 'NONE'}

function! s:h(hl, fg, bg, fmt) abort
  exe 'hi! '.a:hl.' ctermfg='.a:fg['term'].' guifg='.a:fg['gui']
        \.' ctermbg='.a:bg['term'].' guibg='.a:bg['gui']
        \.' cterm='.a:fmt.' gui='.a:fmt
endfunction

"----------------------------------------------------------------
"        Syntax group     | Foreground  | Background    | Style |
"----------------------------------------------------------------

call s:h('Normal',          s:white,      s:background,   'none')
call s:h('LineNr',          s:grey,       s:background,   'none')
call s:h('CursorLine',      s:none,       s:mediumgrey,   'none')
call s:h('CursorLineNR',    s:boldcyan,   s:background,   'none')

call s:h('CursorColumn',    s:none,       s:mediumgrey,   'none')
call s:h('FoldColumn',      s:none,       s:background,   'none')
call s:h('SignColumn',      s:none,       s:background,   'none')
call s:h('Folded',          s:lightgrey,  s:darkgrey,     'none')

call s:h('VertSplit',       s:darkgrey,   s:darkgrey,     'none')
call s:h('ColorColumn',     s:none,       s:mediumgrey,   'none')

call s:h('Directory',       s:blue,       s:background,   'none')
call s:h('Search',          s:black,      s:yellow,       'none')
call s:h('IncSearch',       s:black,      s:yellow,       'none')

call s:h('WildMenu',        s:boldgreen,  s:mediumgrey,   'none')
call s:h('Question',        s:boldgreen,  s:background,   'none')
call s:h('Title',           s:yellow,     s:background,   'none')
call s:h('ModeMsg',         s:boldgreen,  s:background,   'none')
call s:h('MoreMsg',         s:boldgreen,  s:background,   'none')

call s:h('MatchParen',      s:boldcyan,   s:mediumgrey,   'none')
call s:h('Visual',          s:none,       s:mediumgrey,   'none')
call s:h('NonText',         s:blurple,    s:background,   'none')
call s:h('Todo',            s:green,      s:background,   'bold')
call s:h('Underlined',      s:blue,       s:background,   'underline')
call s:h('Error',           s:darkpurple, s:boldred,      'underline')
call s:h('ErrorMsg',        s:black,      s:red,          'none')
call s:h('WarningMsg',      s:black,      s:orange,       'none')
call s:h('Ignore',          s:none,       s:background,   'none')
call s:h('SpecialKey',      s:blurple,    s:background,   'none')

call s:h('Constant',        s:cyan,       s:background,   'none')
call s:h('String',          s:boldgreen,  s:background,   'none')
call s:h('StringDelimiter', s:green,      s:background,   'none')
call s:h('Character',       s:cyan,       s:background,   'none')
call s:h('Number',          s:cyan,       s:background,   'none')
call s:h('Boolean',         s:cyan,       s:background,   'none')
call s:h('Float',           s:cyan,       s:background,   'none')
call s:h('Identifier',      s:yellow,     s:background,   'none')
call s:h('Function',        s:blue,       s:background,   'none')
call s:h('Primitive',       s:boldyellow, s:background,   'italic')

call s:h('Statement',       s:purple,     s:background,   'none')
call s:h('Conditional',     s:purple,     s:background,   'none')
call s:h('Repeat',          s:purple,     s:background,   'none')
call s:h('Label',           s:purple,     s:background,   'none')
call s:h('Operator',        s:brown,      s:background,   'none')
call s:h('Keyword',         s:purple,     s:background,   'none')
call s:h('Comment',         s:grey,       s:background,   'none')
call s:h('Builtin',         s:orange,     s:background,   'none')
call s:h('Language',        s:pink,       s:background,   'none')
call s:h('Special',         s:red,        s:background,   'none')
call s:h('SpecialChar',     s:cyan,       s:background,   'bold')
call s:h('Tag',             s:red,        s:background,   'none')
call s:h('Delimiter',       s:bluegrey,   s:background,   'none')
call s:h('Coding',          s:red,        s:background,   'italic')

call s:h('PreProc',         s:boldcyan,   s:background,   'none')
call s:h('Include',         s:purple,     s:background,   'none')
call s:h('Type',            s:yellow,     s:background,   'none')
call s:h('Storage',         s:boldpurple, s:background,   'none')
call s:h('StorageClass',    s:green,      s:background,   'none')
call s:h('Structure',       s:boldcyan,   s:background,   'none')
call s:h('Class',           s:boldblue,   s:background,   'bold')

call s:h('DiffAdd',         s:boldgreen,  s:darkdarkgrey, 'none')
call s:h('DiffChange',      s:yellow,     s:darkdarkgrey, 'none')
call s:h('DiffDelete',      s:red,        s:darkdarkgrey, 'none')
call s:h('DiffText',        s:black,      s:lightgrey,    'none')
call s:h('diffAdded',       s:boldgreen,  s:background,   'none')

call s:h('Pmenu',           s:white,      s:mediumgrey,   'none')
call s:h('PmenuSel',        s:white,      s:mediumgrey,   'reverse')

call s:h('SpellBad',        s:darkpurple, s:boldred,      'none')
call s:h('SpellCap',        s:darkpurple, s:boldblue,     'none')
call s:h('SpellLocal',      s:cyan,       s:boldcyan,     'none')
call s:h('SpellRare',       s:purple,     s:boldpurple,   'none')

call s:h('StatusLine',      s:white,      s:mediumgrey,   'none')
call s:h('StatusLineNC',    s:black,      s:lightgrey,    'none')

call s:h('TabLine',         s:black,      s:lightgrey,    'none')
call s:h('TabLineFill',     s:black,      s:lightgrey,    'none')
call s:h('TabLineSel',      s:white,      s:mediumgrey,   'bold')

call s:h('Sneak',           s:white,      s:magenta,      'none')
call s:h('SneakLabel',      s:white,      s:magenta,      'none')
call s:h('SneakLabelMask',  s:magenta,    s:magenta,      'none')
