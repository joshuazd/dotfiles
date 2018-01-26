function! <SID>indentMotionMove(dir, type, count) abort
  let l:count = a:count
  let l:line = line('.')
  let l:togglev = 0
  if a:type ==? 'v' || a:type ==? ''
    if a:dir ==? 'j'
      let l:start = '<'
      let l:end = '>'
      if line("'>") > line('.')
      endif
    elseif a:dir ==? 'k'
      let l:start = '>'
      let l:end = '<'
      if line("'<") < line('.')
      endif
    endif
  endif
  while l:count > 0
    if a:dir ==? 'j'
      let l:pos = search('^' . matchstr(getline(l:line), '\(^\s*\)') .'\%>' . l:line . 'l\S', 'nW')
    else
      let l:pos = search('^' . matchstr(getline(l:line), '\(^\s*\)') .'\%<' . l:line . 'l\S', 'bnW')
    endif
    if l:pos > 0
      let l:line = l:pos
    endif
    let l:count = l:count - 1
  endwhile
  let l:move = abs(l:line - line('.'))
  if l:move > 0
    if a:type ==? 'v' || a:type ==? ''
      return "\<esc>`" . l:start . a:type . '`' . l:end . l:move . a:dir . ":\<C-u>silent redraw\<CR>gv"
    elseif a:type ==? 'n'
      return "\<esc>" . l:move . a:dir
    endif
  else
    echom 'no movement'
  endif
endfunction

function! Vline() abort range
  echom line('v')
  echom line('.')
endfunction

nnoremap <silent> <expr> <Plug>IndentMotionDown <SID>indentMotionMove('j', mode(), v:count1)
nnoremap <silent> <expr> <Plug>IndentMotionUp <SID>indentMotionMove('k', mode(), v:count1)

xnoremap <silent> <expr> <Plug>IndentMotionDown <SID>indentMotionMove('j', mode(), v:count1)
xnoremap <silent> <expr> <Plug>IndentMotionUp <SID>indentMotionMove('k', mode(), v:count1)
