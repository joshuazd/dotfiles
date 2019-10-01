" material.vim -- Vim color scheme.

hi clear

if exists("syntax_on")
  syntax reset
endif

set background=dark

let colors_name = "material"

if ($TERM =~ '256' || &t_Co >= 256) || has("gui_running")
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
    hi Todo ctermbg=235 ctermfg=203 cterm=BOLD guibg=#262626 guifg=#ff5f5f gui=BOLD
    hi Underlined ctermbg=235 ctermfg=111 cterm=UNDERLINE guibg=#262626 guifg=#87aaff gui=UNDERLINE
    hi Error ctermbg=203 ctermfg=16 cterm=UNDERLINE guibg=#ff5f5f guifg=#000000 gui=UNDERLINE
    hi ErrorMsg ctermbg=203 ctermfg=16 cterm=NONE guibg=#ff5f5f guifg=#000000 gui=NONE
    hi WarningMsg ctermbg=173 ctermfg=16 cterm=NONE guibg=#d7875f guifg=#000000 gui=NONE
    hi Ignore ctermbg=235 ctermfg=NONE cterm=NONE guibg=#262626 guifg=NONE gui=NONE
    hi SpecialKey ctermbg=235 ctermfg=67 cterm=NONE guibg=#262626 guifg=#5f87af gui=NONE
    hi Constant ctermbg=235 ctermfg=73 cterm=NONE guibg=#262626 guifg=#5fafaf gui=NONE
    hi String ctermbg=235 ctermfg=108 cterm=NONE guibg=#262626 guifg=#87af87 gui=NONE
    hi StringDelimiter ctermbg=235 ctermfg=114 cterm=NONE guibg=#262626 guifg=#87d787 gui=NONE
    hi Identifier ctermbg=235 ctermfg=222 cterm=NONE guibg=#262626 guifg=#ffd787 gui=NONE
    hi Function ctermbg=235 ctermfg=111 cterm=NONE guibg=#262626 guifg=#87aaff gui=NONE
    hi Primitive ctermbg=235 ctermfg=215 cterm=ITALIC guibg=#262626 guifg=#ffaf5f gui=ITALIC
    hi Statement ctermbg=235 ctermfg=104 cterm=NONE guibg=#262626 guifg=#8787d7 gui=NONE
    hi Operator ctermbg=235 ctermfg=137 cterm=NONE guibg=#262626 guifg=#ab7967 gui=NONE
    hi Comment ctermbg=235 ctermfg=240 cterm=ITALIC guibg=#262626 guifg=#585858 gui=ITALIC
    hi Builtin ctermbg=235 ctermfg=173 cterm=NONE guibg=#262626 guifg=#d7875f gui=NONE
    hi Language ctermbg=235 ctermfg=203 cterm=NONE guibg=#262626 guifg=#ff5f5f gui=NONE
    hi Special ctermbg=235 ctermfg=203 cterm=NONE guibg=#262626 guifg=#ff5f5f gui=NONE
    hi Tag ctermbg=235 ctermfg=203 cterm=NONE guibg=#262626 guifg=#ff5f5f gui=NONE
    hi SpecialChar ctermbg=235 ctermfg=73 cterm=BOLD guibg=#262626 guifg=#5fafaf gui=BOLD
    hi Delimiter ctermbg=235 ctermfg=246 cterm=NONE guibg=#262626 guifg=#949494 gui=NONE
    hi Coding ctermbg=235 ctermfg=203 cterm=ITALIC guibg=#262626 guifg=#ff5f5f gui=ITALIC
    hi PreProc ctermbg=235 ctermfg=116 cterm=NONE guibg=#262626 guifg=#87d7d7 gui=NONE
    hi Type ctermbg=235 ctermfg=222 cterm=NONE guibg=#262626 guifg=#ffd787 gui=NONE
    hi Storage ctermbg=235 ctermfg=97 cterm=NONE guibg=#262626 guifg=#875faf gui=NONE
    hi StorageClass ctermbg=235 ctermfg=114 cterm=NONE guibg=#262626 guifg=#87d787 gui=NONE
    hi Structure ctermbg=235 ctermfg=116 cterm=NONE guibg=#262626 guifg=#87d7d7 gui=NONE
    hi Class ctermbg=235 ctermfg=67 cterm=BOLD guibg=#262626 guifg=#5f87af gui=BOLD
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
    hi CursorLineNR ctermbg=black ctermfg=darkcyan cterm=NONE
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
    hi MatchParen ctermbg=darkgrey ctermfg=darkcyan cterm=NONE
    hi Visual ctermbg=darkgrey ctermfg=NONE cterm=NONE
    hi NonText ctermbg=black ctermfg=darkblue cterm=NONE
    hi Todo ctermbg=black ctermfg=darkred cterm=BOLD
    hi Underlined ctermbg=black ctermfg=blue cterm=UNDERLINE
    hi Error ctermbg=darkred ctermfg=black cterm=UNDERLINE
    hi ErrorMsg ctermbg=darkred ctermfg=black cterm=NONE
    hi WarningMsg ctermbg=red ctermfg=black cterm=NONE
    hi Ignore ctermbg=black ctermfg=NONE cterm=NONE
    hi SpecialKey ctermbg=black ctermfg=darkblue cterm=NONE
    hi Constant ctermbg=black ctermfg=cyan cterm=NONE
    hi String ctermbg=black ctermfg=darkgreen cterm=NONE
    hi StringDelimiter ctermbg=black ctermfg=green cterm=NONE
    hi Identifier ctermbg=black ctermfg=yellow cterm=NONE
    hi Function ctermbg=black ctermfg=blue cterm=NONE
    hi Primitive ctermbg=black ctermfg=darkyellow cterm=ITALIC
    hi Statement ctermbg=black ctermfg=magenta cterm=NONE
    hi Operator ctermbg=black ctermfg=darkgrey cterm=NONE
    hi Comment ctermbg=black ctermfg=grey cterm=ITALIC
    hi Builtin ctermbg=black ctermfg=red cterm=NONE
    hi Language ctermbg=black ctermfg=darkred cterm=NONE
    hi Special ctermbg=black ctermfg=darkred cterm=NONE
    hi Tag ctermbg=black ctermfg=darkred cterm=NONE
    hi SpecialChar ctermbg=black ctermfg=cyan cterm=BOLD
    hi Delimiter ctermbg=black ctermfg=lightgrey cterm=NONE
    hi Coding ctermbg=black ctermfg=darkred cterm=ITALIC
    hi PreProc ctermbg=black ctermfg=darkcyan cterm=NONE
    hi Type ctermbg=black ctermfg=yellow cterm=NONE
    hi Storage ctermbg=black ctermfg=darkmagenta cterm=NONE
    hi StorageClass ctermbg=black ctermfg=green cterm=NONE
    hi Structure ctermbg=black ctermfg=darkcyan cterm=NONE
    hi Class ctermbg=black ctermfg=darkblue cterm=BOLD
    hi DiffAdd ctermbg=darkgrey ctermfg=darkgreen cterm=NONE
    hi DiffChange ctermbg=darkgrey ctermfg=yellow cterm=NONE
    hi DiffDelete ctermbg=darkgrey ctermfg=darkred cterm=NONE
    hi DiffText ctermbg=lightgrey ctermfg=black cterm=NONE
    hi diffAdded ctermbg=black ctermfg=darkgreen cterm=NONE
    hi Pmenu ctermbg=darkgrey ctermfg=white cterm=NONE
    hi PmenuSel ctermbg=darkgrey ctermfg=white cterm=REVERSE
    hi SpellBad ctermbg=darkred ctermfg=darkgrey cterm=NONE
    hi SpellCap ctermbg=darkblue ctermfg=darkgrey cterm=NONE
    hi SpellLocal ctermbg=darkcyan ctermfg=cyan cterm=NONE
    hi SpellRare ctermbg=darkmagenta ctermfg=magenta cterm=NONE
    hi StatusLine ctermbg=darkgrey ctermfg=white cterm=NONE
    hi StatusLineNC ctermbg=black ctermfg=grey cterm=BOLD
    hi TabLine ctermbg=lightgrey ctermfg=black cterm=NONE
    hi TabLineFill ctermbg=lightgrey ctermfg=black cterm=NONE
    hi TabLineSel ctermbg=darkgrey ctermfg=white cterm=BOLD
    hi Sneak ctermbg=darkmagenta ctermfg=white cterm=NONE
    hi SneakLabel ctermbg=darkmagenta ctermfg=white cterm=NONE
    hi SneakLabelMask ctermbg=darkmagenta ctermfg=darkmagenta cterm=NONE
endif

let g:terminal_ansi_colors = [
        \ '#262626',
        \ '#d7875f',
        \ '#87af87',
        \ '#ffd787',
        \ '#5f87af',
        \ '#8787d7',
        \ '#87d7d7',
        \ '#949494',
        \ '#585858',
        \ '#ff5f5f',
        \ '#87d787',
        \ '#ffaf5f',
        \ '#87aaff',
        \ '#875faf',
        \ '#5fafaf',
        \ '#c6c6c6',
        \ ]

" Generated with RNB (https://github.com/romainl/vim-rnb)
