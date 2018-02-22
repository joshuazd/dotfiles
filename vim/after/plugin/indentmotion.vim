if !hasmapto('<Plug>IndentMotionInner', 'o')
  omap ii <Plug>IndentMotionInner
endif
if !hasmapto('<Plug>IndentMotionUpper', 'o')
  omap ai <Plug>IndentMotionUpper
endif
if !hasmapto('<Plug>IndentMotionAround', 'o')
  omap aI <Plug>IndentMotionAround
endif
if !hasmapto('<Plug>IndentMotionInner', 'v')
  xmap ii <Plug>IndentMotionInner
endif
if !hasmapto('<Plug>IndentMotionUpper', 'v')
  xmap ai <Plug>IndentMotionUpper
endif
if !hasmapto('<Plug>IndentMotionAround', 'v')
  xmap aI <Plug>IndentMotionAround
endif
if !hasmapto('<Plug>IndentMotionDown', 'n')
  nmap ,j <Plug>IndentMotionDown
endif
if !hasmapto('<Plug>IndentMotionUp', 'n')
  nmap ,k <Plug>IndentMotionUp
endif
if !hasmapto('<Plug>IndentMotionDown', 'x')
  xmap ,j <Plug>IndentMotionDown
endif
if !hasmapto('<Plug>IndentMotionUp', 'x')
  xmap ,k <Plug>IndentMotionUp
endif
if !hasmapto('<Plug>IndentMotionDown', 'o')
  omap ,j <Plug>IndentMotionDown
endif
if !hasmapto('<Plug>IndentMotionUp', 'o')
  omap ,k <Plug>IndentMotionUp
endif

