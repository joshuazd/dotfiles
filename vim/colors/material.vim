let s:bg           = '235'
let s:red          = '203'
let s:brightred    = '167'
let s:pink         = '204'
let s:brightpink   = '203'
let s:orange       = '209'
let s:brightorange = '203'
let s:yellow       = '221'
let s:brightyellow = '214'
let s:green        = '186'
let s:brightgreen  = '107'
let s:blue         = '111'
let s:brightblue   = '68'
let s:cyan         = '73'
let s:brightcyan   = '117'
let s:purple       = '176'
let s:brightpurple = '97'
let s:darkpurple   = '53'
let s:brown        = '137'
let s:darkgrey     = '239'
let s:lightgrey    = '246'
let s:black        = '235'
let s:white        = '254'
let s:none         = 'none'

highlight clear
if exists('syntax_on')
    syntax reset
endif

let g:colors_name='material'
"----------------------------------------------------------------------------------------------------
" General settings                                                                                  |
"----------------------------------------------------------------------------------------------------
"----------------------------------------------------------------------------------------------------
" Syntax group         | Foreground                   | Background                   | Style        |
"----------------------------------------------------------------------------------------------------

" --------------------------------
" Editor settings
" --------------------------------
exe 'hi Normal          ctermfg='     .s:white        .' ctermbg='   .s:none       .' cterm=none'
exe 'hi Cursor                                                                        cterm=reverse'
" exe 'hi CursorLine      ctermfg='     .s:             .' ctermbg='   .s:none          cterm=none
exe 'hi LineNr          ctermfg='     .s:darkgrey     .' ctermbg='   .s:none       .' cterm=none'
exe 'hi CursorLineNR    ctermfg='     .s:cyan         .' ctermbg='   .s:none       .' cterm=none'

" -----------------
" - Number column -
" -----------------
exe 'hi CursorColumn    ctermfg='     .s:none         .' ctermbg='   .s:none       .' cterm=none'
exe 'hi FoldColumn      ctermfg='     .s:none         .' ctermbg='   .s:none       .' cterm=none'
exe 'hi SignColumn      ctermfg='     .s:none         .' ctermbg='   .s:none       .' cterm=none'
exe 'hi Folded          ctermfg='     .s:lightgrey    .' ctermbg=233                  cterm=none'

" -------------------------
" - Window/Tab delimiters - 
" -------------------------
exe 'hi VertSplit       ctermfg=236                      ctermbg=236                   cterm=none'
exe 'hi ColorColumn     ctermfg='     .s:darkgrey     .' ctermbg='   .s:darkgrey    .' cterm=none'
" exe 'hi TabLine         ctermfg='     .s:             .' ctermbg='   .s:none           cterm=none
" exe 'hi TabLineFill     ctermfg='     .s:             .' ctermbg='   .s:none           cterm=none
" exe 'hi TabLineSel      ctermfg='     .s:             .' ctermbg='   .s:none           cterm=none

" -------------------------------
" - File Navigation / Searching -
" -------------------------------
exe 'hi Directory       ctermfg='     .s:blue         .' ctermbg='   .s:none        .' cterm=none'
exe 'hi Search          ctermfg='     .s:black        .' ctermbg='   .s:yellow      .' cterm=bold'
exe 'hi IncSearch       ctermfg='     .s:black        .' ctermbg='   .s:yellow      .' cterm=bold'

" -----------------
" - Prompt/Status -
" -----------------
exe 'hi StatusLine      ctermfg=236                      ctermbg='   .s:lightgrey   .' cterm=none'
exe 'hi StatusLineNC    ctermfg=236                      ctermbg='   .s:lightgrey   .' cterm=none'
exe 'hi WildMenu        ctermfg='     .s:brightgreen  .' ctermbg='   .s:darkgrey    .' cterm=none'
exe 'hi Question        ctermfg='     .s:brightgreen  .' ctermbg='   .s:none        .' cterm=none'
exe 'hi Title           ctermfg='     .s:yellow       .' ctermbg='   .s:none        .' cterm=none'
exe 'hi ModeMsg         ctermfg='     .s:brightgreen  .' ctermbg='   .s:none        .' cterm=none'
exe 'hi MoreMsg         ctermfg='     .s:brightgreen  .' ctermbg='   .s:none        .' cterm=none'

" --------------
" - Visual aid -
" --------------
exe 'hi MatchParen      ctermfg='     .s:brightcyan   .' ctermbg='   .s:darkgrey    .' cterm=none'
exe 'hi Visual          ctermfg='     .s:none         .' ctermbg='   .s:darkgrey    .' cterm=none'
" exe 'hi VisualNOS     ctermfg='     .s:             .' ctermbg='   .s:none                 cterm=none
exe 'hi NonText         ctermfg='     .s:darkgrey     .' ctermbg='   .s:none        .' cterm=none'

exe 'hi Todo            ctermfg='     .s:green        .' ctermbg='   .s:none        .' cterm=bold'
exe 'hi Underlined      ctermfg='     .s:blue         .' ctermbg='   .s:none        .' cterm=none'
exe 'hi Error           ctermfg='     .s:darkpurple   .' ctermbg='   .s:brightred   .' cterm=underline'
exe 'hi ErrorMsg        ctermfg='     .s:black        .' ctermbg='   .s:red         .' cterm=none'
exe 'hi WarningMsg      ctermfg='     .s:black        .' ctermbg='   .s:orange      .' cterm=none'
exe 'hi Ignore          ctermfg='     .s:none         .' ctermbg='   .s:none        .' cterm=none'
exe 'hi SpecialKey      ctermfg='     .s:darkgrey     .' ctermbg='   .s:none        .' cterm=none'

" --------------------------------
" Variable types
" --------------------------------
exe 'hi Constant        ctermfg='     .s:cyan         .' ctermbg='   .s:none        .' cterm=none'
exe 'hi String          ctermfg='     .s:brightgreen  .' ctermbg='   .s:none        .' cterm=none'
exe 'hi StringDelimiter ctermfg='     .s:green        .' ctermbg='   .s:none        .' cterm=none'
exe 'hi Character       ctermfg='     .s:cyan         .' ctermbg='   .s:none        .' cterm=none'
exe 'hi Number          ctermfg='     .s:cyan         .' ctermbg='   .s:none        .' cterm=none'
exe 'hi Boolean         ctermfg='     .s:cyan         .' ctermbg='   .s:none        .' cterm=none'
exe 'hi Float           ctermfg='     .s:cyan         .' ctermbg='   .s:none        .' cterm=none'

exe 'hi Identifier      ctermfg='     .s:yellow       .' ctermbg='   .s:none        .' cterm=none'
exe 'hi Function        ctermfg='     .s:brightblue   .' ctermbg='   .s:none        .' cterm=none'

" --------------------------------
" Language constructs
" --------------------------------
exe 'hi Statement       ctermfg='     .s:purple       .' ctermbg='   .s:none        .' cterm=none'
" exe 'hi Conditional   ctermfg='     .s:             .' ctermbg='   .s:none        .' cterm=none'
" exe 'hi Repeat        ctermfg='     .s:             .' ctermbg='   .s:none        .' cterm=none'
" exe 'hi Label         ctermfg='     .s:             .' ctermbg='   .s:none        .' cterm=none'
exe 'hi Operator        ctermfg='     .s:brown        .' ctermbg='   .s:none        .' cterm=none'
exe 'hi Keyword         ctermfg='     .s:purple       .' ctermbg='   .s:none        .' cterm=none'
" exe 'hi Exception     ctermfg='     .s:             .' ctermbg='   .s:none        .' cterm=none'
exe 'hi Comment         ctermfg='     .s:darkgrey     .' ctermbg='   .s:none        .' cterm=none'
exe 'hi Language        ctermfg='     .s:pink         .' ctermbg='   .s:none        .' cterm=none'

exe 'hi Special         ctermfg='     .s:red          .' ctermbg='   .s:none        .' cterm=none'
exe 'hi SpecialChar     ctermfg='     .s:cyan         .' ctermbg='   .s:none        .' cterm=none'
exe 'hi Tag             ctermfg='     .s:red          .' ctermbg='   .s:none        .' cterm=none'
exe 'hi Delimiter       ctermfg='     .s:brightcyan   .' ctermbg='   .s:none        .' cterm=none'
"exe 'hi SpecialComment ctermfg='     .s:             .' ctermbg='   .s:none        .' cterm=none'
" exe 'hi Debug         ctermfg='     .s:             .' ctermbg='   .s:none        .' cterm=none'

" ----------
" - C like -
" ----------
exe 'hi PreProc         ctermfg='     .s:brightcyan   .' ctermbg='   .s:none        .' cterm=none'
exe 'hi Include         ctermfg='     .s:purple       .' ctermbg='   .s:none        .' cterm=none'
" exe 'hi Define        ctermfg='     .s:             .' ctermbg='   .s:none        .' cterm=none'
" exe 'hi Macro         ctermfg='     .s:             .' ctermbg='   .s:none        .' cterm=none'
" exe 'hi PreCondit     ctermfg='     .s:             .' ctermbg='   .s:none        .' cterm=none'

exe 'hi Type            ctermfg='     .s:yellow       .' ctermbg='   .s:none        .' cterm=none'
exe 'hi StorageClass    ctermfg='     .s:brightpurple .' ctermbg='   .s:none        .' cterm=none'
exe 'hi Structure       ctermfg='     .s:cyan         .' ctermbg='   .s:none        .' cterm=none'
" exe 'hi Typedef         ctermfg='     .s:             .' ctermbg='   .s:none        .' cterm=none'

" --------------------------------
" Diff
" --------------------------------
exe 'hi DiffAdd         ctermfg='     .s:brightgreen  .' ctermbg='   .s:darkgrey    .' cterm=none'
exe 'hi DiffChange      ctermfg='     .s:yellow       .' ctermbg='   .s:darkgrey    .' cterm=none'
exe 'hi DiffDelete      ctermfg='     .s:red          .' ctermbg='   .s:darkgrey    .' cterm=none'
exe 'hi DiffText        ctermfg='     .s:black        .' ctermbg='   .s:lightgrey   .' cterm=none'

" --------------------------------
" Completion menu
" --------------------------------
exe 'hi Pmenu           ctermfg='     .s:white        .' ctermbg='   .s:darkgrey    .' cterm=none'
exe 'hi PmenuSel        ctermfg='     .s:white        .' ctermbg='   .s:darkgrey    .' cterm=reverse'
" exe 'hi PmenuSbar     ctermfg='     .s:             .' ctermbg='   .s:none        .' cterm=none'
" exe 'hi PmenuThumb    ctermfg='     .s:             .' ctermbg='   .s:none        .' cterm=none'

" --------------------------------
" Spelling
" --------------------------------
exe 'hi SpellBad        ctermfg='     .s:red          .' ctermbg='   .s:brightred   .' cterm=none'
exe 'hi SpellCap        ctermfg='     .s:blue         .' ctermbg='   .s:brightblue  .' cterm=none'
exe 'hi SpellLocal      ctermfg='     .s:cyan         .' ctermbg='   .s:brightcyan  .' cterm=none'
exe 'hi SpellRare       ctermfg='     .s:purple       .' ctermbg='   .s:brightpurple.' cterm=none'
