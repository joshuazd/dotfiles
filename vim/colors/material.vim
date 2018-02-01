highlight clear
if exists('syntax_on')
    syntax reset
endif

set background=dark

let g:colors_name  = 'material'
let s:bg           = '235'
let s:red          = '203'
let s:brightred    = '167'
let s:pink         = '210'
let s:brightpink   = '203'
let s:orange       = '209'
let s:brightorange = '203'
let s:yellow       = '221'
let s:brightyellow = '214'
let s:green        = '150'
let s:brightgreen  = '107'
let s:blue         = '111'
let s:brightblue   = '68'
let s:cyan         = '73'
let s:brightcyan   = '117'
let s:purple       = '176'
let s:brightpurple = '97'
let s:darkpurple   = '53'
let s:brown        = '137'
let s:darkgrey     = '236'
let s:darkdarkgrey = '233'
let s:grey         = '239'
let s:lightgrey    = '246'
let s:black        = '235'
let s:bg           = 'none'
let s:white        = '254'
let s:none         = 'none'

"----------------------------------------------------------------------------------------------------
" General settings                                                                                  |
"----------------------------------------------------------------------------------------------------
"----------------------------------------------------------------------------------------------------
" Syntax group         | Foreground                   | Background                   | Style        |
"----------------------------------------------------------------------------------------------------

" --------------------------------
" Editor settings
" --------------------------------
exe 'hi! Normal          ctermfg='     .s:white        .' ctermbg='   .s:bg         .' cterm=none'
exe 'hi! Cursor                                                                        cterm=reverse'
exe 'hi! CursorLine      ctermfg='     .s:none         .' ctermbg='   .s:darkgrey   .' cterm=none'
exe 'hi! LineNr          ctermfg='     .s:grey         .' ctermbg='   .s:bg         .' cterm=none'
exe 'hi! CursorLineNR    ctermfg='     .s:brightcyan   .' ctermbg='   .s:bg         .' cterm=none'

" -----------------
" - Number column -
" -----------------
exe 'hi! CursorColumn    ctermfg='     .s:none         .' ctermbg='   .s:darkgrey   .' cterm=none'
exe 'hi! FoldColumn      ctermfg='     .s:none         .' ctermbg='   .s:bg         .' cterm=none'
exe 'hi! SignColumn      ctermfg='     .s:none         .' ctermbg='   .s:bg         .' cterm=none'
exe 'hi! Folded          ctermfg='     .s:lightgrey    .' ctermbg=233                  cterm=none'

" -------------------------
" - Window/Tab delimiters - 
" -------------------------
exe 'hi! VertSplit       ctermfg=236                      ctermbg=236                   cterm=none'
exe 'hi! ColorColumn     ctermfg='     .s:none         .' ctermbg='   .s:darkgrey    .' cterm=none'
" exe 'hi! TabLine         ctermfg='     .s:             .' ctermbg='   .s:bg           cterm=none
" exe 'hi! TabLineFill     ctermfg='     .s:             .' ctermbg='   .s:bg           cterm=none
" exe 'hi! TabLineSel      ctermfg='     .s:             .' ctermbg='   .s:bg           cterm=none

" -------------------------------
" - File Navigation / Searching -
" -------------------------------
exe 'hi! Directory       ctermfg='     .s:blue         .' ctermbg='   .s:bg          .' cterm=none'
exe 'hi! Search          ctermfg='     .s:black        .' ctermbg='   .s:yellow      .' cterm=none'
exe 'hi! IncSearch       ctermfg='     .s:black        .' ctermbg='   .s:yellow      .' cterm=none'

" -----------------
" - Prompt/Status -
" -----------------
exe 'hi! StatusLine      ctermfg=251                      ctermbg=236                   cterm=none'
exe 'hi! StatusLineNC    ctermfg=245                      ctermbg=236                   cterm=none'
exe 'hi! WildMenu        ctermfg='     .s:brightgreen  .' ctermbg='   .s:darkgrey    .' cterm=none'
exe 'hi! Question        ctermfg='     .s:brightgreen  .' ctermbg='   .s:bg          .' cterm=none'
exe 'hi! Title           ctermfg='     .s:yellow       .' ctermbg='   .s:bg          .' cterm=none'
exe 'hi! ModeMsg         ctermfg='     .s:brightgreen  .' ctermbg='   .s:bg          .' cterm=none'
exe 'hi! MoreMsg         ctermfg='     .s:brightgreen  .' ctermbg='   .s:bg          .' cterm=none'

" --------------
" - Visual aid -
" --------------
exe 'hi! MatchParen      ctermfg='     .s:brightcyan   .' ctermbg='   .s:darkgrey    .' cterm=none'
exe 'hi! Visual          ctermfg='     .s:none         .' ctermbg=236                   cterm=none'
" exe 'hi! VisualNOS     ctermfg='     .s:             .' ctermbg='   .s:bg                   cterm=none
exe 'hi! NonText         ctermfg='     .s:darkgrey     .' ctermbg='   .s:bg          .' cterm=none'

exe 'hi! Todo            ctermfg='     .s:green        .' ctermbg='   .s:bg          .' cterm=bold'
exe 'hi! Underlined      ctermfg='     .s:blue         .' ctermbg='   .s:bg          .' cterm=none'
exe 'hi! Error           ctermfg='     .s:darkpurple   .' ctermbg='   .s:brightred   .' cterm=underline'
exe 'hi! ErrorMsg        ctermfg='     .s:black        .' ctermbg='   .s:red         .' cterm=none'
exe 'hi! WarningMsg      ctermfg='     .s:black        .' ctermbg='   .s:orange      .' cterm=none'
exe 'hi! Ignore          ctermfg='     .s:none         .' ctermbg='   .s:bg          .' cterm=none'
exe 'hi! SpecialKey      ctermfg='     .s:darkgrey     .' ctermbg='   .s:bg          .' cterm=none'

" --------------------------------
" Variable types
" --------------------------------
exe 'hi! Constant        ctermfg='     .s:cyan         .' ctermbg='   .s:bg          .' cterm=none'
exe 'hi! String          ctermfg='     .s:brightgreen  .' ctermbg='   .s:bg          .' cterm=none'
exe 'hi! StringDelimiter ctermfg='     .s:green        .' ctermbg='   .s:bg          .' cterm=none'
exe 'hi! Character       ctermfg='     .s:cyan         .' ctermbg='   .s:bg          .' cterm=none'
exe 'hi! Number          ctermfg='     .s:cyan         .' ctermbg='   .s:bg          .' cterm=none'
exe 'hi! Boolean         ctermfg='     .s:cyan         .' ctermbg='   .s:bg          .' cterm=none'
exe 'hi! Float           ctermfg='     .s:cyan         .' ctermbg='   .s:bg          .' cterm=none'

exe 'hi! Identifier      ctermfg='     .s:yellow       .' ctermbg='   .s:bg          .' cterm=none'
exe 'hi! Function        ctermfg='     .s:blue         .' ctermbg='   .s:bg          .' cterm=none'
exe 'hi! Primitive       ctermfg='     .s:brightyellow .' ctermbg='   .s:bg          .' cterm=italic'

" --------------------------------
" Language constructs
" --------------------------------
exe 'hi! Statement       ctermfg='     .s:purple       .' ctermbg='   .s:bg          .' cterm=none'
" exe 'hi! Conditional   ctermfg='     .s:             .' ctermbg='   .s:bg          .' cterm=none'
" exe 'hi! Repeat        ctermfg='     .s:             .' ctermbg='   .s:bg          .' cterm=none'
" exe 'hi! Label         ctermfg='     .s:             .' ctermbg='   .s:bg          .' cterm=none'
exe 'hi! Operator        ctermfg='     .s:brown        .' ctermbg='   .s:bg          .' cterm=none'
exe 'hi! Keyword         ctermfg='     .s:purple       .' ctermbg='   .s:bg          .' cterm=none'
" exe 'hi! Exception     ctermfg='     .s:             .' ctermbg='   .s:bg          .' cterm=none'
exe 'hi! Comment         ctermfg='     .s:grey         .' ctermbg='   .s:bg          .' cterm=none'
exe 'hi! Language        ctermfg='     .s:pink         .' ctermbg='   .s:bg          .' cterm=none'

exe 'hi! Special         ctermfg='     .s:red          .' ctermbg='   .s:bg          .' cterm=none'
exe 'hi! SpecialChar     ctermfg='     .s:cyan         .' ctermbg='   .s:bg          .' cterm=bold'
exe 'hi! Tag             ctermfg='     .s:red          .' ctermbg='   .s:bg          .' cterm=none'
exe 'hi! Delimiter       ctermfg='     .s:brightcyan   .' ctermbg='   .s:bg          .' cterm=none'
"exe 'hi! SpecialComment ctermfg='     .s:             .' ctermbg='   .s:bg          .' cterm=none'
" exe 'hi! Debug         ctermfg='     .s:             .' ctermbg='   .s:bg          .' cterm=none'

" ----------
" - C like -
" ----------
exe 'hi! PreProc         ctermfg='     .s:brightcyan   .' ctermbg='   .s:bg          .' cterm=none'
exe 'hi! Include         ctermfg='     .s:purple       .' ctermbg='   .s:bg          .' cterm=none'
" exe 'hi! Define        ctermfg='     .s:             .' ctermbg='   .s:bg          .' cterm=none'
" exe 'hi! Macro         ctermfg='     .s:             .' ctermbg='   .s:bg          .' cterm=none'
" exe 'hi! PreCondit     ctermfg='     .s:             .' ctermbg='   .s:bg          .' cterm=none'

exe 'hi! Type            ctermfg='     .s:yellow       .' ctermbg='   .s:bg          .' cterm=none'
exe 'hi! StorageClass    ctermfg='     .s:brightpurple .' ctermbg='   .s:bg          .' cterm=none'
exe 'hi! Structure       ctermfg='     .s:cyan         .' ctermbg='   .s:bg          .' cterm=none'
" exe 'hi! Typedef         ctermfg='     .s:             .' ctermbg='   .s:bg          .' cterm=none'

" --------------------------------
" Diff
" --------------------------------
exe 'hi! DiffAdd         ctermfg='     .s:brightgreen  .' ctermbg='   .s:darkdarkgrey.' cterm=none'
exe 'hi! DiffChange      ctermfg='     .s:yellow       .' ctermbg='   .s:darkdarkgrey.' cterm=none'
exe 'hi! DiffDelete      ctermfg='     .s:red          .' ctermbg='   .s:darkdarkgrey.' cterm=none'
exe 'hi! DiffText        ctermfg='     .s:black        .' ctermbg='   .s:lightgrey   .' cterm=none'
exe 'hi! diffAdded       ctermfg='     .s:brightgreen  .' ctermbg='   .s:bg          .' cterm=none'

" --------------------------------
" Completion menu
" --------------------------------
exe 'hi! Pmenu           ctermfg='     .s:white        .' ctermbg='   .s:darkgrey    .' cterm=none'
exe 'hi! PmenuSel        ctermfg='     .s:white        .' ctermbg='   .s:darkgrey    .' cterm=reverse'
" exe 'hi! PmenuSbar     ctermfg='     .s:             .' ctermbg='   .s:bg          .' cterm=none'
" exe 'hi! PmenuThumb    ctermfg='     .s:             .' ctermbg='   .s:bg          .' cterm=none'

" --------------------------------
" Spelling
" --------------------------------
exe 'hi! SpellBad        ctermfg='     .s:darkpurple   .' ctermbg='   .s:brightred   .' cterm=none'
exe 'hi! SpellCap        ctermfg='     .s:darkpurple   .' ctermbg='   .s:brightblue  .' cterm=none'
exe 'hi! SpellLocal      ctermfg='     .s:cyan         .' ctermbg='   .s:brightcyan  .' cterm=none'
exe 'hi! SpellRare       ctermfg='     .s:purple       .' ctermbg='   .s:brightpurple.' cterm=none'
