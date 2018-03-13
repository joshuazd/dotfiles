if !hasmapto('<Plug>IndentMotionInner', 'o')
  omap <silent> ii <Plug>IndentMotionInner
endif
if !hasmapto('<Plug>IndentMotionUpper', 'o')
  omap <silent> ai <Plug>IndentMotionUpper
endif
if !hasmapto('<Plug>IndentMotionAround', 'o')
  omap <silent> aI <Plug>IndentMotionAround
endif
if !hasmapto('<Plug>IndentMotionInner', 'v')
  xmap <silent> ii <Plug>IndentMotionInner
endif
if !hasmapto('<Plug>IndentMotionUpper', 'v')
  xmap <silent> ai <Plug>IndentMotionUpper
endif
if !hasmapto('<Plug>IndentMotionAround', 'v')
  xmap <silent> aI <Plug>IndentMotionAround
endif
if !hasmapto('<Plug>IndentMotionDown', 'n')
  nmap <silent> ,j <Plug>IndentMotionDown
endif
if !hasmapto('<Plug>IndentMotionUp', 'n')
  nmap <silent> ,k <Plug>IndentMotionUp
endif
if !hasmapto('<Plug>IndentMotionDown', 'x')
  xmap <silent> ,j <Plug>IndentMotionDown
endif
if !hasmapto('<Plug>IndentMotionUp', 'x')
  xmap <silent> ,k <Plug>IndentMotionUp
endif
if !hasmapto('<Plug>IndentMotionDown', 'o')
  omap <silent> ,j <Plug>IndentMotionDown
endif
if !hasmapto('<Plug>IndentMotionUp', 'o')
  omap <silent> ,k <Plug>IndentMotionUp
endif

