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

