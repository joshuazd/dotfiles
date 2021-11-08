highlight clear
if exists('syntax_on')
    syntax reset
endif

set background=dark

let g:colors_name  = 'material'

" Colors

let s:black        = {'ansi': '0',    'term' : '16',   'gui' : '#000000'}
let s:red          = {'ansi': '1',    'term' : '203',  'gui' : '#ff5f5f'}
let s:green        = {'ansi': '2',    'term' : '114',  'gui' : '#87d787'}
let s:yellow       = {'ansi': '3',    'term' : '222',  'gui' : '#ffd787'}
let s:blue         = {'ansi': '12',   'term' : '111',  'gui' : '#87aaff'}
let s:purple       = {'ansi': '5',    'term' : '104',  'gui' : '#8787d7'}
let s:cyan         = {'ansi': '6',    'term' : '73',   'gui' : '#5fafaf'}
let s:lightgrey    = {'ansi': '7',    'term' : '246',  'gui' : '#949494'}
let s:grey         = {'ansi': '7',    'term' : '240',  'gui' : '#585858'}
let s:mediumgrey   = {'ansi': '8',    'term' : '236',  'gui' : '#303030'}
let s:darkgrey     = {'ansi': '8',    'term' : '234',  'gui' : '#1c1c1c'}
let s:boldred      = {'ansi': '9',    'term' : '167',  'gui' : '#d75f5f'}
let s:boldgreen    = {'ansi': '10',   'term' : '108',  'gui' : '#87af87'}
let s:boldyellow   = {'ansi': '11',   'term' : '215',  'gui' : '#ffaf5f'}
let s:boldblue     = {'ansi': '4',    'term' : '67',   'gui' : '#5f87af'}
let s:boldpurple   = {'ansi': '13',   'term' : '97',   'gui' : '#875faf'}
let s:boldcyan     = {'ansi': '14',   'term' : '116',  'gui' : '#87d7d7'}
let s:white        = {'ansi': '15',   'term' : '251',  'gui' : '#c6c6c6'}
let s:pink         = {'ansi': '1',    'term' : '210',  'gui' : '#f07178'}
let s:orange       = {'ansi': '11',   'term' : '173',  'gui' : '#d7875f'}
let s:bluegrey     = {'ansi': '7',    'term' : '248',  'gui' : '#a8a8a8'}
let s:darkpurple   = {'ansi': '13',   'term' : '53',   'gui' : '#5f005f'}
let s:magenta      = {'ansi': '13',   'term' : '55',   'gui' : '#5f00af'}
let s:blurple      = {'ansi': '4',    'term' : '60',   'gui' : '#5f5f87'}
let s:brown        = {'ansi': '11',   'term' : '137',  'gui' : '#ab7967'}
let s:grey         = {'ansi': '8',    'term' : '241',  'gui' : '#626262'}
let s:darkdarkgrey = {'ansi': '8',    'term' : '233',  'gui' : '#121212'}
let s:background   = {'ansi': 'NONE', 'term' : 'NONE', 'gui' : '#262626'}
let s:none         = {'ansi': 'NONE', 'term' : 'NONE', 'gui' : 'NONE'}
let g:terminal_ansi_colors = ['#262626','#ff4f4f','#87d787','#ffd787','#5f87af','#8787d7','#5fafaf','#a8a8a8',
                            \ '#4a4a4a','#d75f5f','#87af87','#ffaf5f','#87aaff','#5f005f','#87d7d7','#c6c6c6']

if &t_Co >= 256 || $TERM =~? '256'|| has('gui_running')
  function! s:h(hl, fg, bg, fmt) abort
    exe 'hi! '.a:hl.' ctermfg='.a:fg['term'].' guifg='.a:fg['gui']
          \.' ctermbg='.a:bg['term'].' guibg='.a:bg['gui']
          \.' cterm='.a:fmt.' gui='.a:fmt
  endfunction
elseif &t_Co == 8 || &t_Co == 16
  set t_Co=16

  function! s:h(hl, fg, bg, fmt) abort
    exe 'hi! '.a:hl.' ctermfg='.a:fg['ansi']
          \.' ctermbg='.a:bg['ansi']
          \.(a:fmt ==? ' cterm=reverse' ? a:fmt : '')
  endfunction
endif

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

call s:h('VertSplit',       s:grey,       s:background,   'none')
call s:h('ColorColumn',     s:none,       s:mediumgrey,   'none')

call s:h('Directory',       s:blue,       s:background,   'none')
call s:h('Search',          s:black,      s:yellow,       'none')
call s:h('IncSearch',       s:black,      s:blurple,       'none')

call s:h('WildMenu',        s:boldgreen,  s:mediumgrey,   'none')
call s:h('Question',        s:boldgreen,  s:background,   'none')
call s:h('Title',           s:yellow,     s:background,   'none')
call s:h('ModeMsg',         s:boldblue,   s:background,   'none')
call s:h('MoreMsg',         s:boldgreen,  s:background,   'none')

call s:h('MatchParen',      s:boldcyan,   s:mediumgrey,   'none')
call s:h('Visual',          s:none,       s:mediumgrey,   'none')
call s:h('NonText',         s:blurple,    s:background,   'none')
call s:h('Todo',            s:pink,       s:background,   'bold')
call s:h('Underlined',      s:blue,       s:background,   'underline')
call s:h('Error',           s:darkpurple, s:boldred,      'underline')
call s:h('ErrorMsg',        s:black,      s:red,          'none')
call s:h('WarningMsg',      s:black,      s:orange,       'none')
call s:h('Ignore',          s:none,       s:background,   'none')
call s:h('SpecialKey',      s:blurple,    s:background,   'none')

call s:h('Constant',        s:cyan,       s:background,   'none')
call s:h('String',          s:boldgreen,  s:background,   'none')
call s:h('StringDelimiter', s:green,      s:background,   'none')
call s:h('Identifier',      s:yellow,     s:background,   'none')
call s:h('Function',        s:blue,       s:background,   'none')
call s:h('Primitive',       s:boldyellow, s:background,   'italic')

call s:h('Statement',       s:purple,     s:background,   'none')
call s:h('Operator',        s:brown,      s:background,   'none')
call s:h('Comment',         s:grey,       s:background,   'italic')
call s:h('Builtin',         s:orange,     s:background,   'none')
call s:h('Language',        s:pink,       s:background,   'none')
call s:h('Special',         s:pink,       s:background,   'none')
call s:h('Tag',             s:red,        s:background,   'none')
call s:h('SpecialChar',     s:cyan,       s:background,   'bold')
call s:h('Delimiter',       s:bluegrey,   s:background,   'none')
call s:h('Coding',          s:red,        s:background,   'italic')

call s:h('PreProc',         s:boldcyan,   s:background,   'none')
call s:h('Type',            s:yellow,     s:background,   'none')
call s:h('Storage',         s:boldpurple, s:background,   'none')
call s:h('StorageClass',    s:green,      s:background,   'none')
call s:h('Structure',       s:boldcyan,   s:background,   'none')
call s:h('Class',           s:boldblue,   s:background,   'bold')

call s:h('DiffAdd',         s:boldgreen,  s:mediumgrey,   'none')
call s:h('DiffChange',      s:yellow,     s:mediumgrey,   'none')
call s:h('DiffDelete',      s:red,        s:mediumgrey,   'none')
call s:h('DiffText',        s:black,      s:lightgrey,    'none')
call s:h('diffAdded',       s:boldgreen,  s:background,   'none')

call s:h('Pmenu',           s:white,      s:mediumgrey,   'none')
call s:h('PmenuSel',        s:white,      s:mediumgrey,   'reverse')

call s:h('SpellBad',        s:darkpurple, s:boldred,      'none')
call s:h('SpellCap',        s:darkpurple, s:boldblue,     'none')
call s:h('SpellLocal',      s:cyan,       s:boldcyan,     'none')
call s:h('SpellRare',       s:purple,     s:boldpurple,   'none')

call s:h('StatusLine',      s:white,      s:mediumgrey,   'none')
call s:h('StatusLineNC',    s:grey,       s:darkgrey,     'bold')

call s:h('TabLine',         s:black,      s:lightgrey,    'none')
call s:h('TabLineFill',     s:black,      s:lightgrey,    'none')
call s:h('TabLineSel',      s:white,      s:mediumgrey,   'bold')

call s:h('Sneak',           s:white,      s:magenta,      'none')
call s:h('SneakLabel',      s:white,      s:magenta,      'none')
call s:h('SneakLabelMask',  s:magenta,    s:magenta,      'none')
