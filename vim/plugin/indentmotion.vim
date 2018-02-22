function! <SID>findSameIndent(count, line, dir) abort
  let l:line = a:line
  let l:count = a:count
  if a:dir ==? 'j'
    let l:end = '>'
    let l:search_dir = ''
  elseif a:dir ==? 'k'
    let l:end = '<'
    let l:search_dir = 'b'
  endif
  while l:count > 0
    " Search pattern taken from http://vim.wikia.com/wiki/Move_to_next/previous_line_with_same_indentation
    let l:pos = search('^' . matchstr(getline(l:line), '\(^\s*\)') .'\%' . l:end . l:line . 'l\S', l:search_dir . 'nW')
    if l:pos > 0
      let l:line = l:pos
    endif
    let l:count = l:count - 1
  endwhile
  return l:line
endfunction
			
function! <SID>findSmallerIndent(line, dir) abort
  let l:inc = (a:dir ==? 'j' ? 1 : -1)
  let l:wspace = matchstr(getline(a:line), '\(^\s*\)')
  let l:curline = a:line + l:inc
  let l:temp_wspace = matchstr(getline(l:curline), '\(^\s*\)')
  while (len(getline(l:curline)) == 0 || len(l:wspace) <= len(l:temp_wspace))
        \&& l:curline > 0 && l:curline <= line('$')
    let l:curline += l:inc
    let l:temp_wspace = matchstr(getline(l:curline), '\(^\s*\)')
  endwhile
  return l:curline
endfunction

function! <SID>indentMotionObject(line, object) abort
  let l:upper = <SID>findSmallerIndent(a:line, 'k')
  let l:lower = <SID>findSmallerIndent(a:line, 'j') - 1
  if a:object ==# 'ii'
    let l:upper += 1
  endif
  if a:object ==# 'aI'
    let l:lower += 1
  endif
  execute 'normal! ' . l:upper . 'GV' . l:lower . 'G'
endfunction

function! <SID>indentMotionMove(dir, type, count) abort
  if a:dir ==? 'j'
    let l:start = '<'
    let l:end = '>'
    let l:search_dir = ''
  elseif a:dir ==? 'k'
    let l:start = '>'
    let l:end = '<'
    let l:search_dir = 'b'
  endif
  let l:line = <SID>findSameIndent(a:count, line('.'), a:dir)
  let l:move = abs(l:line - line('.'))
  if l:move > 0
    if a:type ==? 'v' || a:type ==? ''
      return "\<esc>`" . l:start . a:type . '`' . l:end . l:move . a:dir . ":\<C-u>silent redraw\<CR>gv"
    elseif a:type ==? 'n'
      return "\<esc>" . l:move . a:dir
    elseif a:type ==? 'o'
      return "\<esc>" . v:operator . l:move . a:dir
    endif
  endif
endfunction

nnoremap <silent> <expr> <Plug>IndentMotionDown <SID>indentMotionMove('j', mode(), v:count1)
nnoremap <silent> <expr> <Plug>IndentMotionUp <SID>indentMotionMove('k', mode(), v:count1)

xnoremap <silent> <expr> <Plug>IndentMotionDown <SID>indentMotionMove('j', mode(), v:count1)
xnoremap <silent> <expr> <Plug>IndentMotionUp <SID>indentMotionMove('k', mode(), v:count1)

onoremap <silent> <expr> <Plug>IndentMotionDown <SID>indentMotionMove('j', 'o', v:count1)
onoremap <silent> <expr> <Plug>IndentMotionUp <SID>indentMotionMove('k', 'o', v:count1)

onoremap <Plug>IndentMotionii :<C-u>call <SID>indentMotionObject(line('.'), 'ii')<CR>
onoremap <Plug>IndentMotionai :<C-u>call <SID>indentMotionObject(line('.'), 'ai')<CR>
onoremap <Plug>IndentMotionaI :<C-u>call <SID>indentMotionObject(line('.'), 'aI')<CR>
xnoremap <Plug>IndentMotionii :<C-u>call <SID>indentMotionObject(line('.'), 'ii')<CR>
xnoremap <Plug>IndentMotionai :<C-u>call <SID>indentMotionObject(line('.'), 'ai')<CR>
xnoremap <Plug>IndentMotionaI :<C-u>call <SID>indentMotionObject(line('.'), 'aI')<CR>
if !hasmapto('<Plug>IndentMotionii', 'o')
  omap ii <Plug>IndentMotionii
endif
if !hasmapto('<Plug>IndentMotionai', 'o')
  omap ai <Plug>IndentMotionai
endif
if !hasmapto('<Plug>IndentMotionaI', 'o')
  omap aI <Plug>IndentMotionaI
endif
if !hasmapto('<Plug>IndentMotionii', 'v')
  xmap ii <Plug>IndentMotionii
endif
if !hasmapto('<Plug>IndentMotionai', 'v')
  xmap ai <Plug>IndentMotionai
endif
if !hasmapto('<Plug>IndentMotionaI', 'v')
  xmap aI <Plug>IndentMotionaI
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
