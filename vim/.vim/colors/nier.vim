highlight clear
if exists('syntax_on')
    syntax reset
endif

set background=light

let g:colors_name  = 'nier'
let g:terminal_ansi_colors = ['#45403a','#bf4243','#525643','#5b5143','#4c5361','#614c61','#465953','#999483'
                           \ ,'#777467','#d75f5f','#81895d','#957f5f','#7382a0','#9c739c','#5f8c7d','#ffffff']

hi Normal         ctermfg=0    guifg=#45403a ctermbg=NONE guibg=#b4af9a
hi Comment        ctermfg=8    guifg=#777467 ctermbg=NONE guibg=#b4af9a
hi StatusLine     ctermfg=7    guifg=#b4af9a ctermbg=0    guibg=#45403a cterm=none              gui=none
hi StatusLineNC   ctermfg=8    guifg=#777467 ctermbg=8    guibg=#999483 cterm=none              gui=none
hi String         ctermfg=NONE guifg=#45403a ctermbg=NONE guibg=#b4af9a cterm=reverse           gui=reverse
hi Constant       ctermfg=0    guifg=#45403a ctermbg=NONE guibg=#b4af9a cterm=bold              gui=bold
hi PreProc        ctermfg=8    guifg=#777467 ctermbg=NONE guibg=#b4af9a cterm=bold              gui=bold
hi Special        ctermfg=0    guifg=#000000 ctermbg=NONE guibg=#b4af9a
hi Underlined     ctermfg=0    guifg=#45403a ctermbg=NONE guibg=#b4af9a cterm=underline         gui=underline
hi Search         ctermfg=7    guifg=#b4af9a ctermbg=9    guibg=#bf4243
hi IncSearch      ctermfg=0    guifg=#45403a ctermbg=9    guibg=#957f5f cterm=bold              gui=bold
hi Visual         ctermfg=7    guifg=#b4af9a ctermbg=8    guibg=#8a8570
hi Todo           ctermfg=1    guifg=#bf4243 ctermbg=NONE guibg=#b4af9a cterm=bold              gui=bold
hi Error          ctermfg=1    guifg=#bf4243 ctermbg=NONE guibg=#b4af9a cterm=bold,underline    gui=bold,underline
hi SpecialKey     ctermfg=8    guifg=#999483 ctermbg=NONE guibg=#b4af9a
hi NonText        ctermfg=7    guifg=#b4af9a ctermbg=8    guibg=#999483
hi MatchParen     ctermfg=9    guifg=#bf4243 ctermbg=7    guibg=#b4af9a cterm=bold              gui=bold
hi Folded         ctermfg=0    guifg=#45403a ctermbg=8    guibg=#999483 cterm=none              gui=none
hi CursorLine                                ctermbg=8    guibg=#999483 cterm=none              gui=none
hi TabLine        ctermfg=0    guifg=#45403a ctermbg=7    guibg=#999483 cterm=none              gui=none
hi PmenuSbar      ctermfg=8    guifg=#999483 ctermbg=0    guibg=#45403a
hi PmenuThumb     ctermfg=0    guifg=#45403a ctermbg=8    guibg=#999483
hi PmenuSel       ctermfg=0    guifg=#45403a ctermbg=8    guibg=#8a8570
hi Sneak          ctermfg=0    guifg=#45403a ctermbg=6    guibg=#5f8c7d
hi SneakLabel     ctermfg=0    guifg=#45403a ctermbg=6    guibg=#5f8c7d cterm=bold              gui=bold
hi SneakLabelMask ctermfg=6    guifg=#5f8c7d ctermbg=6    guibg=#5f8c7d
hi SneakScope     ctermfg=15   guifg=#ffffff ctermbg=0    guibg=#45403a
hi MoreMsg        ctermfg=2    guifg=#465953 ctermbg=NONE guibg=#b4af9a
hi Error          ctermfg=1    guifg=#bf4243 ctermbg=NONE guibg=#b4af9a cterm=underline         gui=underline
hi ErrorMsg       ctermfg=1    guifg=#bf4243 ctermbg=NONE guibg=#b4af9a cterm=underline,reverse gui=underline,reverse
hi DiffAdd        ctermfg=0    guifg=#45403a ctermbg=10   guibg=#81895d
hi DiffChange     ctermfg=0    guifg=#45403a ctermbg=11   guibg=#957f5f
hi DiffDelete     ctermfg=0    guifg=#45403a ctermbg=9    guibg=#bf4243
hi SpecialChar    ctermfg=1    guifg=#bf4243 ctermbg=0    guibg=#45403a cterm=bold              gui=bold
hi Delimiter      ctermfg=0    guifg=#45403a ctermbg=NONE guibg=#b4af9a
hi SignColumn                                ctermbg=NONE guibg=#b4af9a
hi LineNr         ctermfg=0    guifg=#45403a ctermbg=NONE guibg=#b4af9a cterm=reverse           gui=reverse
hi SignifySignAdd ctermfg=1    guifg=#bf4243 ctermbg=NONE guibg=NONE

hi! link  Identifier       Normal
hi! link  Statement        Normal
hi! link  Type             Normal
hi! link  Title            Normal
hi! link  Directory        Normal
hi! link  VertSplit        Normal
hi! link  Pmenu            StatusLine
hi! link  WildMenu         Folded
hi! link  Question         MoreMsg
hi! link  StatusLineTerm   StatusLine
hi! link  StatusLineTermNC StatusLineNC
hi! link  StringDelimiter  String
hi! link  Quote            String
hi! link  DiffAdded        DiffAdd
hi! link  DiffChanged      DiffChange
hi! link  DiffRemoved      DiffDelete
hi! link  DiffText         Search
