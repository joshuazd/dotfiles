" material.vim -- Vim color scheme.

hi clear

if exists('syntax_on')
  syntax reset
endif

set background=dark

let colors_name = 'material'

if ($TERM =~# '256' || &t_Co >= 256) || has('gui_running')
    hi Normal ctermbg=235 ctermfg=251 cterm=NONE guibg=#262626 guifg=#c6c6c6 gui=NONE

    hi LineNr ctermbg=235 ctermfg=240 cterm=NONE guibg=#262626 guifg=#585858 gui=NONE
    hi CursorLine ctermbg=236 ctermfg=NONE cterm=NONE guibg=#303030 guifg=NONE gui=NONE
    hi CursorLineNR ctermbg=235 ctermfg=116 cterm=NONE guibg=#262626 guifg=#87d7d7 gui=NONE
    hi CursorColumn ctermbg=236 ctermfg=NONE cterm=NONE guibg=#303030 guifg=NONE gui=NONE
    hi FoldColumn ctermbg=235 ctermfg=NONE cterm=NONE guibg=#262626 guifg=NONE gui=NONE
    hi SignColumn ctermbg=235 ctermfg=NONE cterm=NONE guibg=#262626 guifg=NONE gui=NONE
    hi Folded ctermbg=234 ctermfg=246 cterm=NONE guibg=#1c1c1c guifg=#949494 gui=NONE
    hi VertSplit ctermbg=235 ctermfg=240 cterm=NONE guibg=#262626 guifg=#585858 gui=NONE
    hi ColorColumn ctermbg=236 ctermfg=NONE cterm=NONE guibg=#303030 guifg=NONE gui=NONE
    hi Directory ctermbg=235 ctermfg=111 cterm=NONE guibg=#262626 guifg=#87aaff gui=NONE
    hi Search ctermbg=222 ctermfg=16 cterm=NONE guibg=#ffd787 guifg=#000000 gui=NONE
    hi IncSearch ctermbg=67 ctermfg=16 cterm=NONE guibg=#5f87af guifg=#000000 gui=NONE
    hi WildMenu ctermbg=236 ctermfg=108 cterm=NONE guibg=#303030 guifg=#87af87 gui=NONE
    hi Question ctermbg=235 ctermfg=108 cterm=NONE guibg=#262626 guifg=#87af87 gui=NONE
    hi Title ctermbg=235 ctermfg=222 cterm=NONE guibg=#262626 guifg=#ffd787 gui=NONE
    hi ModeMsg ctermbg=235 ctermfg=67 cterm=NONE guibg=#262626 guifg=#5f87af gui=NONE
    hi MoreMsg ctermbg=235 ctermfg=108 cterm=NONE guibg=#262626 guifg=#87af87 gui=NONE
    hi MatchParen ctermbg=236 ctermfg=116 cterm=NONE guibg=#303030 guifg=#87d7d7 gui=NONE
    hi Visual ctermbg=236 ctermfg=NONE cterm=NONE guibg=#303030 guifg=NONE gui=NONE
    hi NonText ctermbg=235 ctermfg=67 cterm=NONE guibg=#262626 guifg=#5f87af gui=NONE
    hi Todo ctermbg=NONE ctermfg=203 cterm=BOLD guibg=NONE guifg=#ff5f5f gui=BOLD
    hi Underlined ctermbg=235 ctermfg=111 cterm=UNDERLINE guibg=#262626 guifg=#87aaff gui=UNDERLINE
    hi Error ctermbg=203 ctermfg=16 cterm=UNDERLINE guibg=#ff5f5f guifg=#000000 gui=UNDERLINE
    hi ErrorMsg ctermbg=203 ctermfg=16 cterm=NONE guibg=#ff5f5f guifg=#000000 gui=NONE
    hi WarningMsg ctermbg=173 ctermfg=16 cterm=NONE guibg=#d7875f guifg=#000000 gui=NONE
    hi Ignore ctermbg=235 ctermfg=NONE cterm=NONE guibg=#262626 guifg=NONE gui=NONE
    hi SpecialKey ctermbg=NONE ctermfg=236 cterm=NONE guibg=NONE guifg=#303030 gui=NONE
    hi Constant ctermbg=NONE ctermfg=73 cterm=NONE guibg=NONE guifg=#5fafaf gui=NONE
    hi String ctermbg=NONE ctermfg=108 cterm=NONE guibg=NONE guifg=#87af87 gui=NONE
    hi StringDelimiter ctermbg=NONE ctermfg=114 cterm=NONE guibg=NONE guifg=#87d787 gui=NONE
    hi Identifier ctermbg=NONE ctermfg=222 cterm=NONE guibg=NONE guifg=#ffd787 gui=NONE
    hi Function ctermbg=NONE ctermfg=111 cterm=NONE guibg=NONE guifg=#87aaff gui=NONE
    hi Primitive ctermbg=NONE ctermfg=215 cterm=ITALIC guibg=NONE guifg=#ffaf5f gui=ITALIC
    hi Statement ctermbg=NONE ctermfg=104 cterm=NONE guibg=NONE guifg=#8787d7 gui=NONE
    hi Operator ctermbg=NONE ctermfg=137 cterm=NONE guibg=NONE guifg=#ab7967 gui=NONE
    hi Comment ctermbg=NONE ctermfg=240 cterm=ITALIC guibg=NONE guifg=#585858 gui=ITALIC
    hi Builtin ctermbg=NONE ctermfg=173 cterm=NONE guibg=NONE guifg=#d7875f gui=NONE
    hi Language ctermbg=NONE ctermfg=203 cterm=NONE guibg=NONE guifg=#ff5f5f gui=NONE
    hi Special ctermbg=NONE ctermfg=203 cterm=NONE guibg=NONE guifg=#ff5f5f gui=NONE
    hi Tag ctermbg=NONE ctermfg=203 cterm=NONE guibg=NONE guifg=#ff5f5f gui=NONE
    hi SpecialChar ctermbg=NONE ctermfg=73 cterm=BOLD guibg=NONE guifg=#5fafaf gui=BOLD
    hi Delimiter ctermbg=NONE ctermfg=246 cterm=NONE guibg=NONE guifg=#949494 gui=NONE
    hi Coding ctermbg=NONE ctermfg=203 cterm=ITALIC guibg=NONE guifg=#ff5f5f gui=ITALIC
    hi PreProc ctermbg=NONE ctermfg=116 cterm=NONE guibg=NONE guifg=#87d7d7 gui=NONE
    hi Type ctermbg=NONE ctermfg=222 cterm=NONE guibg=NONE guifg=#ffd787 gui=NONE
    hi Storage ctermbg=NONE ctermfg=97 cterm=NONE guibg=NONE guifg=#875faf gui=NONE
    hi StorageClass ctermbg=NONE ctermfg=114 cterm=NONE guibg=NONE guifg=#87d787 gui=NONE
    hi Structure ctermbg=NONE ctermfg=116 cterm=NONE guibg=NONE guifg=#87d7d7 gui=NONE
    hi Class ctermbg=NONE ctermfg=67 cterm=BOLD guibg=NONE guifg=#5f87af gui=BOLD
    hi DiffAdd ctermbg=236 ctermfg=108 cterm=NONE guibg=#303030 guifg=#87af87 gui=NONE
    hi DiffChange ctermbg=236 ctermfg=222 cterm=NONE guibg=#303030 guifg=#ffd787 gui=NONE
    hi DiffDelete ctermbg=236 ctermfg=203 cterm=NONE guibg=#303030 guifg=#ff5f5f gui=NONE
    hi DiffText ctermbg=246 ctermfg=16 cterm=NONE guibg=#949494 guifg=#000000 gui=NONE
    hi diffAdded ctermbg=235 ctermfg=108 cterm=NONE guibg=#262626 guifg=#87af87 gui=NONE
    hi Pmenu ctermbg=236 ctermfg=251 cterm=NONE guibg=#303030 guifg=#c6c6c6 gui=NONE
    hi PmenuSel ctermbg=236 ctermfg=251 cterm=REVERSE guibg=#303030 guifg=#c6c6c6 gui=REVERSE
    hi SpellBad ctermbg=203 ctermfg=236 cterm=NONE guibg=#ff5f5f guifg=#303030 gui=NONE
    hi SpellCap ctermbg=67 ctermfg=236 cterm=NONE guibg=#5f87af guifg=#303030 gui=NONE
    hi SpellLocal ctermbg=116 ctermfg=73 cterm=NONE guibg=#87d7d7 guifg=#5fafaf gui=NONE
    hi SpellRare ctermbg=97 ctermfg=104 cterm=NONE guibg=#875faf guifg=#8787d7 gui=NONE
    hi StatusLine ctermbg=236 ctermfg=251 cterm=NONE guibg=#303030 guifg=#c6c6c6 gui=NONE
    hi StatusLineNC ctermbg=234 ctermfg=240 cterm=BOLD guibg=#1c1c1c guifg=#585858 gui=BOLD
    hi TabLine ctermbg=246 ctermfg=16 cterm=NONE guibg=#949494 guifg=#000000 gui=NONE
    hi TabLineFill ctermbg=246 ctermfg=16 cterm=NONE guibg=#949494 guifg=#000000 gui=NONE
    hi TabLineSel ctermbg=236 ctermfg=251 cterm=BOLD guibg=#303030 guifg=#c6c6c6 gui=BOLD
    hi Sneak ctermbg=97 ctermfg=251 cterm=NONE guibg=#875faf guifg=#c6c6c6 gui=NONE
    hi SneakLabel ctermbg=97 ctermfg=251 cterm=NONE guibg=#875faf guifg=#c6c6c6 gui=NONE
    hi SneakLabelMask ctermbg=97 ctermfg=97 cterm=NONE guibg=#875faf guifg=#875faf gui=NONE

elseif &t_Co == 8 || $TERM !~# '^linux' || &t_Co == 16
    set t_Co=16

    hi Normal ctermbg=black ctermfg=white cterm=NONE

    hi LineNr ctermbg=black ctermfg=grey cterm=NONE
    hi CursorLine ctermbg=darkgrey ctermfg=NONE cterm=NONE
    hi CursorLineNR ctermbg=black ctermfg=cyan cterm=NONE
    hi CursorColumn ctermbg=darkgrey ctermfg=NONE cterm=NONE
    hi FoldColumn ctermbg=black ctermfg=NONE cterm=NONE
    hi SignColumn ctermbg=black ctermfg=NONE cterm=NONE
    hi Folded ctermbg=black ctermfg=lightgrey cterm=NONE
    hi VertSplit ctermbg=black ctermfg=grey cterm=NONE
    hi ColorColumn ctermbg=darkgrey ctermfg=NONE cterm=NONE
    hi Directory ctermbg=black ctermfg=blue cterm=NONE
    hi Search ctermbg=yellow ctermfg=black cterm=NONE
    hi IncSearch ctermbg=darkblue ctermfg=black cterm=NONE
    hi WildMenu ctermbg=darkgrey ctermfg=darkgreen cterm=NONE
    hi Question ctermbg=black ctermfg=darkgreen cterm=NONE
    hi Title ctermbg=black ctermfg=yellow cterm=NONE
    hi ModeMsg ctermbg=black ctermfg=darkblue cterm=NONE
    hi MoreMsg ctermbg=black ctermfg=darkgreen cterm=NONE
    hi MatchParen ctermbg=darkgrey ctermfg=cyan cterm=NONE
    hi Visual ctermbg=darkgrey ctermfg=NONE cterm=NONE
    hi NonText ctermbg=black ctermfg=darkblue cterm=NONE
    hi Todo ctermbg=NONE ctermfg=darkred cterm=NONE
    hi Underlined ctermbg=black ctermfg=blue cterm=NONE
    hi Error ctermbg=darkred ctermfg=black cterm=NONE
    hi ErrorMsg ctermbg=darkred ctermfg=black cterm=NONE
    hi WarningMsg ctermbg=red ctermfg=black cterm=NONE
    hi Ignore ctermbg=black ctermfg=NONE cterm=NONE
    hi SpecialKey ctermbg=NONE ctermfg=darkgrey cterm=NONE
    hi Constant ctermbg=NONE ctermfg=darkcyan cterm=NONE
    hi String ctermbg=NONE ctermfg=darkgreen cterm=NONE
    hi StringDelimiter ctermbg=NONE ctermfg=green cterm=NONE
    hi Identifier ctermbg=NONE ctermfg=yellow cterm=NONE
    hi Function ctermbg=NONE ctermfg=blue cterm=NONE
    hi Primitive ctermbg=NONE ctermfg=darkyellow cterm=NONE
    hi Statement ctermbg=NONE ctermfg=magenta cterm=NONE
    hi Operator ctermbg=NONE ctermfg=lightgrey cterm=NONE
    hi Comment ctermbg=NONE ctermfg=grey cterm=NONE
    hi Builtin ctermbg=NONE ctermfg=red cterm=NONE
    hi Language ctermbg=NONE ctermfg=darkred cterm=NONE
    hi Special ctermbg=NONE ctermfg=darkred cterm=NONE
    hi Tag ctermbg=NONE ctermfg=darkred cterm=NONE
    hi SpecialChar ctermbg=NONE ctermfg=darkcyan cterm=NONE
    hi Delimiter ctermbg=NONE ctermfg=lightgrey cterm=NONE
    hi Coding ctermbg=NONE ctermfg=darkred cterm=NONE
    hi PreProc ctermbg=NONE ctermfg=cyan cterm=NONE
    hi Type ctermbg=NONE ctermfg=yellow cterm=NONE
    hi Storage ctermbg=NONE ctermfg=darkmagenta cterm=NONE
    hi StorageClass ctermbg=NONE ctermfg=green cterm=NONE
    hi Structure ctermbg=NONE ctermfg=cyan cterm=NONE
    hi Class ctermbg=NONE ctermfg=darkblue cterm=NONE
    hi DiffAdd ctermbg=darkgrey ctermfg=darkgreen cterm=NONE
    hi DiffChange ctermbg=darkgrey ctermfg=yellow cterm=NONE
    hi DiffDelete ctermbg=darkgrey ctermfg=darkred cterm=NONE
    hi DiffText ctermbg=lightgrey ctermfg=black cterm=NONE
    hi diffAdded ctermbg=black ctermfg=darkgreen cterm=NONE
    hi Pmenu ctermbg=darkgrey ctermfg=white cterm=NONE
    hi PmenuSel ctermbg=darkgrey ctermfg=white cterm=NONE
    hi SpellBad ctermbg=darkred ctermfg=darkgrey cterm=NONE
    hi SpellCap ctermbg=darkblue ctermfg=darkgrey cterm=NONE
    hi SpellLocal ctermbg=cyan ctermfg=darkcyan cterm=NONE
    hi SpellRare ctermbg=darkmagenta ctermfg=magenta cterm=NONE
    hi StatusLine ctermbg=darkgrey ctermfg=white cterm=NONE
    hi StatusLineNC ctermbg=black ctermfg=grey cterm=NONE
    hi TabLine ctermbg=lightgrey ctermfg=black cterm=NONE
    hi TabLineFill ctermbg=lightgrey ctermfg=black cterm=NONE
    hi TabLineSel ctermbg=darkgrey ctermfg=white cterm=NONE
    hi Sneak ctermbg=darkmagenta ctermfg=white cterm=NONE
    hi SneakLabel ctermbg=darkmagenta ctermfg=white cterm=NONE
    hi SneakLabelMask ctermbg=darkmagenta ctermfg=darkmagenta cterm=NONE
endif

let g:terminal_ansi_colors = [
        \ '#262626',
        \ '#ff5f5f',
        \ '#87af87',
        \ '#ffaf5f',
        \ '#5f87af',
        \ '#875faf',
        \ '#5fafaf',
        \ '#949494',
        \ '#585858',
        \ '#d7875f',
        \ '#87d787',
        \ '#ffd787',
        \ '#87aaff',
        \ '#8787d7',
        \ '#87d7d7',
        \ '#c6c6c6',
        \ ]

" Generated with RNB (https://github.com/romainl/vim-rnb)
