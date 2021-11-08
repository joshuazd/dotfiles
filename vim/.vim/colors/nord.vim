" nord.vim -- Vim color scheme.

hi clear

if exists('syntax_on')
  syntax reset
endif

set background=dark

let colors_name = 'nord'

if ($TERM =~# '256' || &t_Co >= 256) || has('gui_running')
    hi Normal ctermbg=NONE ctermfg=15 cterm=NONE guibg=#2e3440 guifg=#eceff4 gui=NONE

    set background=dark

    hi NonText ctermbg=NONE ctermfg=0 cterm=NONE guibg=NONE guifg=#3b4252 gui=NONE
    hi Comment ctermbg=NONE ctermfg=8 cterm=NONE guibg=NONE guifg=#616E88 gui=NONE
    hi Constant ctermbg=NONE ctermfg=5 cterm=NONE guibg=NONE guifg=#b48ead gui=NONE
    hi Error ctermbg=NONE ctermfg=1 cterm=NONE guibg=NONE guifg=#bf616a gui=NONE
    hi Identifier ctermbg=NONE ctermfg=7 cterm=NONE guibg=NONE guifg=#d8dee9 gui=NONE
    hi Function ctermbg=NONE ctermfg=14 cterm=NONE guibg=NONE guifg=#88c0d0 gui=NONE
    hi Ignore ctermbg=NONE ctermfg=8 cterm=NONE guibg=NONE guifg=#616E88 gui=NONE
    hi PreProc ctermbg=NONE ctermfg=4 cterm=NONE guibg=NONE guifg=#5e81ac gui=NONE
    hi Special ctermbg=NONE ctermfg=11 cterm=NONE guibg=NONE guifg=#ebcb8b gui=NONE
    hi Statement ctermbg=NONE ctermfg=12 cterm=NONE guibg=NONE guifg=#81a1c1 gui=NONE
    hi String ctermbg=NONE ctermfg=2 cterm=NONE guibg=NONE guifg=#a3be8c gui=NONE
    hi StringDelimiter ctermbg=NONE ctermfg=10 cterm=NONE guibg=NONE guifg=#a3be8c gui=NONE
    hi Character ctermbg=NONE ctermfg=2 cterm=NONE guibg=NONE guifg=#a3be8c gui=NONE
    hi Todo ctermbg=NONE ctermfg=4 cterm=NONE guibg=NONE guifg=#5e81ac gui=NONE
    hi Type ctermbg=NONE ctermfg=6 cterm=NONE guibg=NONE guifg=#8fbcbb gui=NONE
    hi Underlined ctermbg=NONE ctermfg=6 cterm=NONE guibg=NONE guifg=#8fbcbb gui=NONE
    hi StatusLine ctermbg=8 ctermfg=7 cterm=NONE guibg=#616E88 guifg=#d8dee9 gui=NONE
    hi StatusLineNC ctermbg=0 ctermfg=12 cterm=NONE guibg=#3b4252 guifg=#81a1c1 gui=NONE
    hi VertSplit ctermbg=0 ctermfg=0 cterm=NONE guibg=#3b4252 guifg=#3b4252 gui=NONE
    hi TabLine ctermbg=0 ctermfg=12 cterm=NONE guibg=#3b4252 guifg=#81a1c1 gui=NONE
    hi TabLineSel ctermbg=8 ctermfg=4 cterm=NONE guibg=#616E88 guifg=#5e81ac gui=NONE
    hi Title ctermbg=NONE ctermfg=14 cterm=NONE guibg=NONE guifg=#88c0d0 gui=NONE
    hi CursorLine ctermbg=0 ctermfg=NONE cterm=NONE guibg=#3b4252 guifg=NONE gui=NONE
    hi LineNr ctermbg=NONE ctermfg=8 cterm=NONE guibg=NONE guifg=#616E88 gui=NONE
    hi CursorLineNr ctermbg=NONE ctermfg=7 cterm=NONE guibg=NONE guifg=#d8dee9 gui=NONE
    hi Visual ctermbg=0 ctermfg=NONE cterm=NONE guibg=#3b4252 guifg=NONE gui=NONE
    hi VisualNOS ctermbg=0 ctermfg=NONE cterm=bold guibg=#3b4252 guifg=NONE gui=bold
    hi Pmenu ctermbg=0 ctermfg=15 cterm=NONE guibg=#3b4252 guifg=#eceff4 gui=NONE
    hi PmenuSel ctermbg=8 ctermfg=15 cterm=NONE guibg=#616E88 guifg=#eceff4 gui=NONE
    hi PmenuThumb ctermbg=8 ctermfg=8 cterm=NONE guibg=#616E88 guifg=#616E88 gui=NONE
    hi FoldColumn ctermbg=8 ctermfg=7 cterm=NONE guibg=#616E88 guifg=#d8dee9 gui=NONE
    hi Folded ctermbg=8 ctermfg=7 cterm=NONE guibg=#616E88 guifg=#d8dee9 gui=NONE
    hi WildMenu ctermbg=8 ctermfg=7 cterm=bold guibg=#616E88 guifg=#d8dee9 gui=bold
    hi SpecialKey ctermbg=NONE ctermfg=0 cterm=NONE guibg=NONE guifg=#3b4252 gui=NONE
    hi DiffAdd ctermbg=NONE ctermfg=2 cterm=NONE guibg=NONE guifg=#a3be8c gui=NONE
    hi DiffChange ctermbg=NONE ctermfg=11 cterm=NONE guibg=NONE guifg=#ebcb8b gui=NONE
    hi DiffDelete ctermbg=NONE ctermfg=1 cterm=NONE guibg=NONE guifg=#bf616a gui=NONE
    hi DiffText ctermbg=NONE ctermfg=7 cterm=NONE guibg=NONE guifg=#d8dee9 gui=NONE
    hi IncSearch ctermbg=3 ctermfg=0 cterm=NONE guibg=#d08770 guifg=#3b4252 gui=NONE
    hi Search ctermbg=11 ctermfg=0 cterm=NONE guibg=#ebcb8b guifg=#3b4252 gui=NONE
    hi Directory ctermbg=NONE ctermfg=12 cterm=NONE guibg=NONE guifg=#81a1c1 gui=NONE
    hi MatchParen ctermbg=NONE ctermfg=6 cterm=NONE guibg=NONE guifg=#8fbcbb gui=NONE
    hi SpellBad ctermbg=1 ctermfg=7 cterm=NONE guibg=#bf616a guifg=#d8dee9 gui=NONE guisp=#bf616a
    hi SpellCap ctermbg=11 ctermfg=0 cterm=NONE guibg=#ebcb8b guifg=#3b4252 gui=NONE guisp=#81a1c1
    hi SpellLocal ctermbg=4 ctermfg=0 cterm=NONE guibg=#5e81ac guifg=#3b4252 gui=NONE guisp=#b48ead
    hi SpellRare ctermbg=5 ctermfg=0 cterm=NONE guibg=#b48ead guifg=#3b4252 gui=NONE guisp=#88c0d0
    hi ColorColumn ctermbg=0 ctermfg=NONE cterm=NONE guibg=#3b4252 guifg=NONE gui=NONE
    hi SignColumn ctermbg=0 ctermfg=8 cterm=NONE guibg=#3b4252 guifg=#616E88 gui=NONE
    hi ErrorMsg ctermbg=NONE ctermfg=1 cterm=NONE guibg=NONE guifg=#bf616a gui=NONE
    hi ModeMsg ctermbg=NONE ctermfg=12 cterm=NONE guibg=NONE guifg=#81a1c1 gui=NONE
    hi MoreMsg ctermbg=NONE ctermfg=2 cterm=NONE guibg=NONE guifg=#a3be8c gui=NONE
    hi Question ctermbg=NONE ctermfg=2 cterm=NONE guibg=NONE guifg=#a3be8c gui=NONE
    hi WarningMsg ctermbg=NONE ctermfg=11 cterm=NONE guibg=NONE guifg=#ebcb8b gui=NONE
    hi Cursor ctermbg=15 ctermfg=NONE cterm=NONE guibg=#eceff4 guifg=NONE gui=NONE
    hi CursorColumn ctermbg=0 ctermfg=NONE cterm=NONE guibg=#3b4252 guifg=NONE gui=NONE
    hi Conceal ctermbg=NONE ctermfg=8 cterm=NONE guibg=NONE guifg=#616E88 gui=NONE
    hi ToolbarButton ctermbg=NONE ctermfg=7 cterm=NONE guibg=NONE guifg=#d8dee9 gui=NONE
    hi debugPC ctermbg=NONE ctermfg=8 cterm=NONE guibg=NONE guifg=#616E88 gui=NONE
    hi debugBreakpoint ctermbg=NONE ctermfg=8 cterm=NONE guibg=NONE guifg=#616E88 gui=NONE
    hi Delimiter ctermbg=NONE ctermfg=4 cterm=NONE guibg=NONE guifg=#5e81ac gui=NONE
    hi Builtin ctermbg=NONE ctermfg=3 cterm=NONE guibg=NONE guifg=#d08770 gui=NONE

elseif &t_Co == 8 || $TERM !~# '^linux' || &t_Co == 16
    set t_Co=16

    hi Normal ctermbg=NONE ctermfg=white cterm=NONE

    set background=dark

    hi NonText ctermbg=NONE ctermfg=black cterm=NONE
    hi Comment ctermbg=NONE ctermfg=darkgray cterm=NONE
    hi Constant ctermbg=NONE ctermfg=darkmagenta cterm=NONE
    hi Error ctermbg=NONE ctermfg=darkred cterm=NONE
    hi Identifier ctermbg=NONE ctermfg=gray cterm=NONE
    hi Function ctermbg=NONE ctermfg=cyan cterm=NONE
    hi Ignore ctermbg=NONE ctermfg=darkgray cterm=NONE
    hi PreProc ctermbg=NONE ctermfg=darkblue cterm=NONE
    hi Special ctermbg=NONE ctermfg=yellow cterm=NONE
    hi Statement ctermbg=NONE ctermfg=blue cterm=NONE
    hi String ctermbg=NONE ctermfg=darkgreen cterm=NONE
    hi StringDelimiter ctermbg=NONE ctermfg=green cterm=NONE
    hi Character ctermbg=NONE ctermfg=darkgreen cterm=NONE
    hi Todo ctermbg=NONE ctermfg=darkblue cterm=NONE
    hi Type ctermbg=NONE ctermfg=darkcyan cterm=NONE
    hi Underlined ctermbg=NONE ctermfg=darkcyan cterm=NONE
    hi StatusLine ctermbg=darkgray ctermfg=gray cterm=NONE
    hi StatusLineNC ctermbg=black ctermfg=blue cterm=NONE
    hi VertSplit ctermbg=black ctermfg=black cterm=NONE
    hi TabLine ctermbg=black ctermfg=blue cterm=NONE
    hi TabLineSel ctermbg=darkgray ctermfg=darkblue cterm=NONE
    hi Title ctermbg=NONE ctermfg=cyan cterm=NONE
    hi CursorLine ctermbg=black ctermfg=NONE cterm=NONE
    hi LineNr ctermbg=NONE ctermfg=darkgray cterm=NONE
    hi CursorLineNr ctermbg=NONE ctermfg=gray cterm=NONE
    hi Visual ctermbg=black ctermfg=NONE cterm=NONE
    hi VisualNOS ctermbg=black ctermfg=NONE cterm=bold
    hi Pmenu ctermbg=black ctermfg=white cterm=NONE
    hi PmenuSel ctermbg=darkgray ctermfg=white cterm=NONE
    hi PmenuThumb ctermbg=darkgray ctermfg=darkgray cterm=NONE
    hi FoldColumn ctermbg=darkgray ctermfg=gray cterm=NONE
    hi Folded ctermbg=darkgray ctermfg=gray cterm=NONE
    hi WildMenu ctermbg=darkgray ctermfg=gray cterm=bold
    hi SpecialKey ctermbg=NONE ctermfg=black cterm=NONE
    hi DiffAdd ctermbg=NONE ctermfg=darkgreen cterm=NONE
    hi DiffChange ctermbg=NONE ctermfg=yellow cterm=NONE
    hi DiffDelete ctermbg=NONE ctermfg=darkred cterm=NONE
    hi DiffText ctermbg=NONE ctermfg=gray cterm=NONE
    hi IncSearch ctermbg=darkyellow ctermfg=black cterm=NONE
    hi Search ctermbg=yellow ctermfg=black cterm=NONE
    hi Directory ctermbg=NONE ctermfg=blue cterm=NONE
    hi MatchParen ctermbg=NONE ctermfg=darkcyan cterm=NONE
    hi SpellBad ctermbg=darkred ctermfg=gray cterm=NONE
    hi SpellCap ctermbg=yellow ctermfg=black cterm=NONE
    hi SpellLocal ctermbg=darkblue ctermfg=black cterm=NONE
    hi SpellRare ctermbg=darkmagenta ctermfg=black cterm=NONE
    hi ColorColumn ctermbg=black ctermfg=NONE cterm=NONE
    hi SignColumn ctermbg=black ctermfg=darkgray cterm=NONE
    hi ErrorMsg ctermbg=NONE ctermfg=darkred cterm=NONE
    hi ModeMsg ctermbg=NONE ctermfg=blue cterm=NONE
    hi MoreMsg ctermbg=NONE ctermfg=darkgreen cterm=NONE
    hi Question ctermbg=NONE ctermfg=darkgreen cterm=NONE
    hi WarningMsg ctermbg=NONE ctermfg=yellow cterm=NONE
    hi Cursor ctermbg=white ctermfg=NONE cterm=NONE
    hi CursorColumn ctermbg=black ctermfg=NONE cterm=NONE
    hi Conceal ctermbg=NONE ctermfg=darkgray cterm=NONE
    hi ToolbarButton ctermbg=NONE ctermfg=gray cterm=NONE
    hi debugPC ctermbg=NONE ctermfg=darkgray cterm=NONE
    hi debugBreakpoint ctermbg=NONE ctermfg=darkgray cterm=NONE
    hi Delimiter ctermbg=NONE ctermfg=darkblue cterm=NONE
    hi Builtin ctermbg=NONE ctermfg=darkyellow cterm=NONE
endif

hi link EndOfBuffer NonText
hi link Number Constant
hi link Boolean Constant
hi link StatusLineTerm StatusLine
hi link StatusLineTermNC StatusLineNC
hi link TabLineFill TabLine
hi link PmenuSbar Pmenu
hi link CursorIM Cursor
hi link QuickFixLine StatusLine
hi link Terminal Normal
hi link ToolbarLine StatusLine
hi link Storage Type

let g:terminal_ansi_colors = [
        \ '#2e3440',
        \ '#bf616a',
        \ '#a3be8c',
        \ '#d08770',
        \ '#5e81ac',
        \ '#b48ead',
        \ '#8fbcbb',
        \ '#d8dee9',
        \ '#616e88',
        \ '#bf616a',
        \ '#a3be8c',
        \ '#ebcb8b',
        \ '#81a1c1',
        \ '#b48ead',
        \ '#88c0d0',
        \ '#eceff4',
        \ ]

" Generated with RNB (https://github.com/romainl/vim-rnb)
