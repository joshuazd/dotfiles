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
  while len(l:wspace) <= len(l:temp_wspace) && l:curline > 0
    let l:curline += l:inc
    let l:temp_wspace = matchstr(getline(l:curline), '\(^\s*\)')
  endwhile
  return l:curline
endfunction

function! <SID>indentMotionObject(line, object) abort
  let l:upper = <SID>findSmallerIndent(a:line, 'k')
  let l:lower = <SID>findSmallerIndent(a:line, 'j') - 1
  if a:object ==? 'ii'
    let l:upper += 1
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

onoremap <Plug>IndentMotionII :<C-u>call <SID>indentMotionObject(line('.'), 'ii')<CR>
onoremap <Plug>IndentMotionAI :<C-u>call <SID>indentMotionObject(line('.'), 'ai')<CR>
xnoremap <Plug>IndentMotionII :<C-u>call <SID>indentMotionObject(line('.'), 'ii')<CR>
xnoremap <Plug>IndentMotionAI :<C-u>call <SID>indentMotionObject(line('.'), 'ai')<CR>
if !hasmapto('<Plug>IndentMotionII', 'o')
  omap ii <Plug>IndentMotionII
endif
if !hasmapto('<Plug>IndentMotionAI', 'o')
  omap ai <Plug>IndentMotionAI
endif
if !hasmapto('<Plug>IndentMotionII', 'v')
  xmap ii <Plug>IndentMotionII
endif
if !hasmapto('<Plug>IndentMotionAI', 'v')
  xmap ai <Plug>IndentMotionAI
endif
