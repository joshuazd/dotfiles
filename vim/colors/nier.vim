highlight clear
if exists('syntax_on')
    syntax reset
endif

set background=light

let g:colors_name  = 'nier'

hi  Normal           guifg=#45403a    guibg=#b4af9a
hi  Comment          guifg=#8a8570    guibg=#b4af9a
hi  StatusLine       guifg=#b4af9a    guibg=#45403a cterm=none              gui=none
hi  StatusLineNC     guifg=#777467    guibg=#999483 cterm=none              gui=none
hi  String           guifg=#b4af9a    guibg=#45403a
hi  Constant         guifg=#45403a    guibg=#b4af9a cterm=bold              gui=bold
hi  PreProc          guifg=#777467    guibg=#b4af9a cterm=bold              gui=bold
hi  Special          guifg=#000000    guibg=#b4af9a
hi  Underlined       guifg=#45403a    guibg=#b4af9a cterm=underline         gui=underline
hi  Search           guifg=#b4af9a    guibg=#bf4243
hi  Visual           guifg=#b4af9a    guibg=#8a8570
hi  Todo             guifg=#bf4243    guibg=#b4af9a cterm=bold              gui=bold
hi  Error            guifg=#bf4243    guibg=#b4af9a cterm=bold,underline    gui=bold,underline
hi  SpecialKey       guifg=#777467    guibg=#b4af9a
hi  NonText          guifg=#b4af9a    guibg=#999483
hi  MatchParen       guifg=#b4af9a    guibg=#bf4243
hi  Folded           guifg=#45403a    guibg=#999483 cterm=none              gui=none
hi  PmenuSbar        guifg=#999483    guibg=#45403a
hi  PmenuThumb       guifg=#45403a    guibg=#999483
hi  PmenuSel         guifg=#45403a    guibg=#8a8570
hi  Sneak            guifg=#45403a    guibg=#5f8c7d
hi  SneakLabel       guifg=#45403a    guibg=#5f8c7d cterm=bold              gui=bold
hi  SneakLabelMask   guifg=#5f8c7d    guibg=#5f8c7d
hi  SneakScope       guifg=#ffffff    guibg=#45403a
hi  MoreMsg          guifg=#465953    guibg=#b4af9a
hi  Error            guifg=#bf4243    guibg=#b4af9a cterm=underline         gui=underline
hi  ErrorMsg         guifg=#bf4243    guibg=#b4af9a cterm=underline,reverse gui=underline,reverse
hi  DiffAdd          guifg=#45403a    guibg=#81895d
hi  DiffChange       guifg=#45403a    guibg=#957f5f
hi  DiffDelete       guifg=#45403a    guibg=#bf4243
hi  SpecialChar      guifg=#bf4243    guibg=#45403a cterm=bold              gui=bold
hi! link             IncSearch        Search
hi! link             Identifier       Normal
hi! link             Statement        Normal
hi! link             Type             Normal
hi! link             Title            Normal
hi! link             Directory        Normal
hi! link             VertSplit        Normal
hi! link             Pmenu            StatusLine
hi! link             WildMenu         Folded
hi! link             Question         MoreMsg
hi! link             StatusLineTerm   StatusLine
hi! link             StatusLineTermNC StatusLineNC
hi! link             StringDelimiter  String
hi! link             DiffAdded        DiffAdd
hi! link             DiffChanged      DiffChange
hi! link             DiffRemoved      DiffDelete
