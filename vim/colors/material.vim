highlight clear
if exists('syntax_on')
    syntax reset
endif

set background=dark

let g:colors_name    = 'material'

" Terminal Colors
let s:t_red     = '203'
let s:t_bred    = '167'
let s:t_pink    = '210'
let s:t_orange  = '208'
let s:t_yellow  = '221'
let s:t_byellow = '214'
let s:t_green   = '156'
let s:t_bgreen  = '107'
let s:t_blue    = '111'
let s:t_bblue   = '68'
let s:t_cyan    = '73'
let s:t_bcyan   = '117'
let s:t_purple  = '176'
let s:t_bpurple = '97'
let s:t_dpurple = '53'
let s:t_spurple = '55'
let s:t_brown   = '137'
let s:t_dgrey   = '235'
let s:t_ddgrey  = '233'
let s:t_grey    = '239'
let s:t_mgrey   = '234'
let s:t_lgrey   = '246'
let s:t_black   = '16'
let s:t_bg      = 'NONE'
let s:t_white   = '254'
let s:t_none    = 'NONE'

" GUI Colors
let s:g_red     = '#ff5f5f'
let s:g_bred    = '#d75f5f'
let s:g_pink    = '#f07178'
let s:g_orange  = '#f76d47'
let s:g_yellow  = '#ffcb6b'
let s:g_byellow = '#ffb62c'
let s:g_green   = '#c3e88d'
let s:g_bgreen  = '#91b859'
let s:g_blue    = '#82aaff'
let s:g_bblue   = '#6182b8'
let s:g_cyan    = '#39adb5'
let s:g_bcyan   = '#89ddff'
let s:g_purple  = '#c792ea'
let s:g_bpurple = '#945eb8'
let s:g_dpurple = '#5f005f'
let s:g_spurple = '#5f00af'
let s:g_brown   = '#ab7967'
let s:g_dgrey   = '#262626'
let s:g_ddgrey  = '#121212'
let s:g_grey    = '#4e4e4e'
let s:g_mgrey   = '#1c1c1c'
let s:g_lgrey   = '#949494'
let s:g_black   = '#000000'
let s:g_bg      = '#121212'
let s:g_white   = '#ffffff'
let s:g_none    = 'NONE'
"---------------------------------------------------------------------------------------------------------------------------------------------------------
"                                                                General settings                                                                        |
"---------------------------------------------------------------------------------------------------------------------------------------------------------
"---------------------------------------------------------------------------------------------------------------------------------------------------------
"    Syntax group       |                  Foreground                  |                   Background                    |          Style                |
"---------------------------------------------------------------------------------------------------------------------------------------------------------

" --------------------------------
" Editor settings
" --------------------------------
exe 'hi! Normal          ctermfg=' .s:t_white   .' guifg=' .s:g_white   .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
" exe 'hi! Cursor                                                                                                              cterm=reverse gui=reverse'
exe 'hi! CursorLine      ctermfg=' .s:t_none    .' guifg=' .s:g_none    .' ctermbg=' .s:t_dgrey   .' guibg=' .s:g_dgrey   .' cterm=none gui=none'
exe 'hi! LineNr          ctermfg=' .s:t_grey    .' guifg=' .s:g_grey    .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! CursorLineNR    ctermfg=' .s:t_bcyan   .' guifg=' .s:g_bcyan   .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'

" -----------------
" - Number column -
" -----------------
exe 'hi! CursorColumn    ctermfg=' .s:t_none    .' guifg=' .s:g_none    .' ctermbg=' .s:t_dgrey   .' guibg=' .s:g_dgrey   .' cterm=none gui=none'
exe 'hi! FoldColumn      ctermfg=' .s:t_none    .' guifg=' .s:g_none    .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! SignColumn      ctermfg=' .s:t_none    .' guifg=' .s:g_none    .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! Folded          ctermfg=' .s:t_lgrey   .' guifg=' .s:g_lgrey   .' ctermbg=232               guibg=#080808           cterm=none gui=none'

" -------------------------
" - Window/Tab delimiters - 
" -------------------------
exe 'hi! VertSplit       ctermfg=' .s:t_mgrey   .' guifg=' .s:g_mgrey   .' ctermbg=' .s:t_mgrey   .' guibg=' .s:g_mgrey   .' cterm=none gui=none'
exe 'hi! ColorColumn     ctermfg=' .s:t_none    .' guifg=' .s:g_none    .' ctermbg=' .s:t_dgrey   .' guibg=' .s:g_dgrey   .' cterm=none gui=none'
" exe 'hi! TabLine         ctermfg=' .s:t_ .' guifg=' .s:g_             .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg           cterm=non gui=none'
" exe 'hi! TabLineFill     ctermfg=' .s:t_ .' guifg=' .s:g_             .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg           cterm=non gui=none'
" exe 'hi! TabLineSel      ctermfg=' .s:t_ .' guifg=' .s:g_             .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg           cterm=non gui=none'

" -------------------------------
" - File Navigation / Searching -
" -------------------------------
exe 'hi! Directory       ctermfg=' .s:t_blue    .' guifg=' .s:g_blue    .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! Search          ctermfg=' .s:t_black   .' guifg=' .s:g_black   .' ctermbg=' .s:t_yellow  .' guibg=' .s:g_yellow  .' cterm=none gui=none'
exe 'hi! IncSearch       ctermfg=' .s:t_black   .' guifg=' .s:g_black   .' ctermbg=' .s:t_yellow  .' guibg=' .s:g_yellow  .' cterm=none gui=none'

" -----------------
" - Prompt/Status -
" -----------------
exe 'hi! WildMenu        ctermfg=' .s:t_bgreen  .' guifg=' .s:g_bgreen  .' ctermbg=' .s:t_dgrey   .' guibg=' .s:g_dgrey   .' cterm=none gui=none'
exe 'hi! Question        ctermfg=' .s:t_bgreen  .' guifg=' .s:g_bgreen  .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! Title           ctermfg=' .s:t_yellow  .' guifg=' .s:g_yellow  .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! ModeMsg         ctermfg=' .s:t_bgreen  .' guifg=' .s:g_bgreen  .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! MoreMsg         ctermfg=' .s:t_bgreen  .' guifg=' .s:g_bgreen  .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'

" --------------
" - Visual aid -
" --------------
exe 'hi! MatchParen      ctermfg=' .s:t_bcyan   .' guifg=' .s:g_bcyan   .' ctermbg=' .s:t_dgrey   .' guibg=' .s:g_dgrey   .' cterm=none gui=none'
exe 'hi! Visual          ctermfg=' .s:t_none    .' guifg=' .s:g_none    .' ctermbg=' .s:t_dgrey   .' guibg=' .s:g_dgrey   .' cterm=none gui=none'
" exe 'hi! NonText         ctermfg=' .s:t_dgrey   .' guifg=' .s:g_dgrey   .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! NonText         ctermfg=60'            .' guifg=#5f5f87'       .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'

exe 'hi! Todo            ctermfg=' .s:t_green   .' guifg=' .s:g_green   .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=bold gui=bold'
exe 'hi! Underlined      ctermfg=' .s:t_blue    .' guifg=' .s:g_blue    .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=underline gui=underline'
exe 'hi! Error           ctermfg=' .s:t_dpurple .' guifg=' .s:g_dpurple .' ctermbg=' .s:t_bred    .' guibg=' .s:g_bred    .' cterm=underline gui=underline'
exe 'hi! ErrorMsg        ctermfg=' .s:t_black   .' guifg=' .s:g_black   .' ctermbg=' .s:t_red     .' guibg=' .s:g_red     .' cterm=none gui=none'
exe 'hi! WarningMsg      ctermfg=' .s:t_black   .' guifg=' .s:g_black   .' ctermbg=' .s:t_orange  .' guibg=' .s:g_orange  .' cterm=none gui=none'
exe 'hi! Ignore          ctermfg=' .s:t_none    .' guifg=' .s:g_none    .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! SpecialKey      ctermfg=60'            .' guifg=#5f5f87'       .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'

" --------------------------------
" Variable types
" --------------------------------
exe 'hi! Constant        ctermfg=' .s:t_cyan    .' guifg=' .s:g_cyan    .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! String          ctermfg=' .s:t_bgreen  .' guifg=' .s:g_bgreen  .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! StringDelimiter ctermfg=' .s:t_green   .' guifg=' .s:g_green   .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! Character       ctermfg=' .s:t_cyan    .' guifg=' .s:g_cyan    .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! Number          ctermfg=' .s:t_cyan    .' guifg=' .s:g_cyan    .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! Boolean         ctermfg=' .s:t_cyan    .' guifg=' .s:g_cyan    .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! Float           ctermfg=' .s:t_cyan    .' guifg=' .s:g_cyan    .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! Identifier      ctermfg=' .s:t_yellow  .' guifg=' .s:g_yellow  .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! Function        ctermfg=' .s:t_blue    .' guifg=' .s:g_blue    .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! Primitive       ctermfg=' .s:t_byellow .' guifg=' .s:g_byellow .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=italic gui=italic'

" --------------------------------
" Language constructs
" --------------------------------
exe 'hi! Statement       ctermfg=' .s:t_purple  .' guifg=' .s:g_purple  .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! Conditional     ctermfg=' .s:t_purple  .' guifg=' .s:g_purple  .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! Repeat          ctermfg=' .s:t_purple  .' guifg=' .s:g_purple  .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! Label           ctermfg=' .s:t_purple  .' guifg=' .s:g_purple  .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! Operator        ctermfg=' .s:t_brown   .' guifg=' .s:g_brown   .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! Keyword         ctermfg=' .s:t_purple  .' guifg=' .s:g_purple  .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! Comment         ctermfg=' .s:t_grey    .' guifg=' .s:g_grey    .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! Language        ctermfg=' .s:t_pink    .' guifg=' .s:g_pink    .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! Special         ctermfg=' .s:t_red     .' guifg=' .s:g_red     .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! SpecialChar     ctermfg=' .s:t_cyan    .' guifg=' .s:g_cyan    .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=bold gui=bold'
exe 'hi! Tag             ctermfg=' .s:t_red     .' guifg=' .s:g_red     .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! Delimiter       ctermfg=' .s:t_bcyan   .' guifg=' .s:g_bcyan   .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'

" ----------
" - C like -
" ----------
exe 'hi! PreProc         ctermfg=' .s:t_bcyan   .' guifg=' .s:g_bcyan   .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! Include         ctermfg=' .s:t_purple  .' guifg=' .s:g_purple  .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! Type            ctermfg=' .s:t_yellow  .' guifg=' .s:g_yellow  .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! StorageClass    ctermfg=' .s:t_bpurple .' guifg=' .s:g_bpurple .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'
exe 'hi! Structure       ctermfg=' .s:t_cyan    .' guifg=' .s:g_cyan    .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'

" --------------------------------
" Diff
" --------------------------------
exe 'hi! DiffAdd         ctermfg=' .s:t_bgreen  .' guifg=' .s:g_bgreen  .' ctermbg=' .s:t_ddgrey  .' guibg=' .s:g_ddgrey  .' cterm=none gui=none'
exe 'hi! DiffChange      ctermfg=' .s:t_yellow  .' guifg=' .s:g_yellow  .' ctermbg=' .s:t_ddgrey  .' guibg=' .s:g_ddgrey  .' cterm=none gui=none'
exe 'hi! DiffDelete      ctermfg=' .s:t_red     .' guifg=' .s:g_red     .' ctermbg=' .s:t_ddgrey  .' guibg=' .s:g_ddgrey  .' cterm=none gui=none'
exe 'hi! DiffText        ctermfg=' .s:t_black   .' guifg=' .s:g_black   .' ctermbg=' .s:t_lgrey   .' guibg=' .s:g_lgrey   .' cterm=none gui=none'
exe 'hi! diffAdded       ctermfg=' .s:t_bgreen  .' guifg=' .s:g_bgreen  .' ctermbg=' .s:t_bg      .' guibg=' .s:g_bg      .' cterm=none gui=none'

" --------------------------------
" Completion menu
" --------------------------------
exe 'hi! Pmenu           ctermfg=' .s:t_white   .' guifg=' .s:g_white   .' ctermbg=' .s:t_dgrey   .' guibg=' .s:g_dgrey   .' cterm=none gui=none'
exe 'hi! PmenuSel        ctermfg=' .s:t_white   .' guifg=' .s:g_white   .' ctermbg=' .s:t_dgrey   .' guibg=' .s:g_dgrey   .' cterm=reverse gui=reverse'

" --------------------------------
" Spelling
" --------------------------------
exe 'hi! SpellBad        ctermfg=' .s:t_dpurple .' guifg=' .s:g_dpurple .' ctermbg=' .s:t_bred    .' guibg=' .s:g_bred    .' cterm=none gui=none'
exe 'hi! SpellCap        ctermfg=' .s:t_dpurple .' guifg=' .s:g_dpurple .' ctermbg=' .s:t_bblue   .' guibg=' .s:g_bblue   .' cterm=none gui=none'
exe 'hi! SpellLocal      ctermfg=' .s:t_cyan    .' guifg=' .s:g_cyan    .' ctermbg=' .s:t_bcyan   .' guibg=' .s:g_bcyan   .' cterm=none gui=none'
exe 'hi! SpellRare       ctermfg=' .s:t_purple  .' guifg=' .s:g_purple  .' ctermbg=' .s:t_bpurple .' guibg=' .s:g_bpurple .' cterm=none gui=none'

" --------------------------------
" Sneak
" --------------------------------
exe 'hi! Sneak           ctermfg=' .s:t_white   .' guifg=' .s:g_white   .' ctermbg=' .s:t_spurple .' guibg=' .s:g_spurple .' cterm=none gui=none'
exe 'hi! SneakLabel      ctermfg=' .s:t_white   .' guifg=' .s:g_white   .' ctermbg=' .s:t_spurple .' guibg=' .s:g_spurple .' cterm=none gui=none'
exe 'hi! SneakLabelMask  ctermfg=' .s:t_spurple .' guifg=' .s:g_spurple .' ctermbg=' .s:t_spurple .' guibg=' .s:g_spurple .' cterm=none gui=none'
