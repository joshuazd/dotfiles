highlight clear
if exists('syntax_on')
    syntax reset
endif

set background=dark

let g:colors_name = 'monochrome'

" Colors

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
let s:background = {'term' : 'NONE','gui' : '#262626'}
let s:none       = {'term' : 'NONE','gui' : 'NONE'}

function! s:h(hl, fg, bg, fmt) abort
  exe 'hi! '.a:hl.' ctermfg='.a:fg['term'].' guifg='.a:fg['gui']
        \.' ctermbg='.a:bg['term'].' guibg='.a:bg['gui']
        \.' cterm='.a:fmt.' gui='.a:fmt
endfunction

"----------------------------------------------------------------
"        Syntax group     | Foreground  | Background    | Style |
"----------------------------------------------------------------

call s:h('Normal',          s:grey18,     s:background,   'none')
call s:h('LineNr',          s:grey7,      s:background,   'none')
call s:h('CursorLine',      s:none,       s:grey9,        'none')
call s:h('CursorLineNR',    s:grey23,     s:background,   'none')

call s:h('CursorColumn',    s:none,       s:grey9,        'none')
call s:h('FoldColumn',      s:none,       s:background,   'none')
call s:h('SignColumn',      s:none,       s:background,   'none')
call s:h('Folded',          s:grey16,     s:grey1,        'none')

call s:h('VertSplit',       s:grey1,      s:grey1,        'none')
call s:h('ColorColumn',     s:none,       s:grey9,        'none')

call s:h('Directory',       s:grey14,     s:background,   'bold')
call s:h('Search',          s:grey18,     s:background,   'inverse')
call s:h('IncSearch',       s:grey18,     s:background,   'inverse')

call s:h('WildMenu',        s:grey18,     s:grey9,        'none')
call s:h('Question',        s:grey18,     s:background,   'none')
call s:h('Title',           s:grey22,     s:background,   'none')
call s:h('ModeMsg',         s:grey18,     s:background,   'none')
call s:h('MoreMsg',         s:grey18,     s:background,   'none')

call s:h('MatchParen',      s:grey23,     s:grey9,        'none')
call s:h('Visual',          s:none,       s:grey9,        'none')
call s:h('NonText',         s:grey5,      s:background,   'none')
call s:h('Todo',            s:grey23,     s:background,   'bold')
call s:h('Underlined',      s:grey14,     s:background,   'underline')
call s:h('Error',           s:black,      s:grey23,       'underline')
call s:h('ErrorMsg',        s:black,      s:grey23,       'none')
call s:h('WarningMsg',      s:grey1,      s:grey19,       'none')
call s:h('Ignore',          s:none,       s:background,   'none')
call s:h('SpecialKey',      s:grey8,      s:background,   'none')

call s:h('Constant',        s:grey20,     s:background,   'none')
call s:h('String',          s:grey13,     s:background,   'none')
call s:h('StringDelimiter', s:grey23,     s:background,   'none')
call s:h('Character',       s:grey20,     s:background,   'none')
call s:h('Number',          s:grey20,     s:background,   'none')
call s:h('Boolean',         s:grey20,     s:background,   'none')
call s:h('Float',           s:grey20,     s:background,   'none')
call s:h('Identifier',      s:grey22,     s:background,   'none')
call s:h('Function',        s:grey16,     s:background,   'underline')
call s:h('Primitive',       s:grey13,     s:background,   'italic')

call s:h('Statement',       s:grey23,     s:background,   'none')
call s:h('Conditional',     s:grey14,     s:background,   'none')
call s:h('Repeat',          s:grey14,     s:background,   'none')
call s:h('Label',           s:grey14,     s:background,   'none')
call s:h('Operator',        s:grey9,      s:background,   'none')
call s:h('Keyword',         s:grey14,     s:background,   'none')
call s:h('Comment',         s:grey8,      s:background,   'italic')
call s:h('Builtin',         s:grey18,     s:background,   'none')
call s:h('Language',        s:grey18,     s:background,   'none')
call s:h('Special',         s:grey20,     s:background,   'none')
call s:h('SpecialChar',     s:grey22,     s:background,   'bold')
call s:h('Tag',             s:grey19,     s:background,   'bold')
call s:h('Delimiter',       s:grey7,      s:background,   'none')
call s:h('Coding',          s:grey20,     s:background,   'italic')

call s:h('PreProc',         s:grey14,     s:background,   'none')
call s:h('Include',         s:grey11,     s:background,   'none')
call s:h('Type',            s:grey22,     s:background,   'none')
call s:h('StorageClass',    s:grey10,     s:background,   'none')
call s:h('Structure',       s:grey22,     s:background,   'none')
call s:h('Class',           s:grey16,     s:background,   'bold')

call s:h('DiffAdd',         s:grey18,     s:grey2,        'bold')
call s:h('DiffChange',      s:grey18,     s:grey2,        'italic')
call s:h('DiffDelete',      s:grey18,     s:grey2,        'underline')
call s:h('DiffText',        s:black,      s:grey16,       'none')
call s:h('diffAdded',       s:grey18,     s:background,   'none')

call s:h('Pmenu',           s:grey18,     s:grey9,        'none')
call s:h('PmenuSel',        s:grey18,     s:grey9,        'reverse')

call s:h('SpellBad',        s:black,      s:grey23,       'underline')
call s:h('SpellCap',        s:black,      s:grey23,       'italic')
call s:h('SpellLocal',      s:black,      s:grey23,       'none')
call s:h('SpellRare',       s:grey15,     s:grey5,        'none')

call s:h('StatusLine',      s:grey18,     s:grey4,        'none')
call s:h('StatusLineNC',    s:black,      s:grey16,       'none')

call s:h('TabLine',         s:black,      s:grey16,       'none')
call s:h('TabLineFill',     s:black,      s:grey16,       'none')
call s:h('TabLineSel',      s:grey18,     s:grey9,        'bold')

call s:h('Sneak',           s:grey18,     s:black,        'none')
call s:h('SneakLabel',      s:grey18,     s:black,        'none')
call s:h('SneakLabelMask',  s:black,      s:black,        'none')
