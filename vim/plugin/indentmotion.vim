function! <SID>findSameIndent(count, dir, visual, operator) abort
  let l:curline = line('.')
  let l:curcol = col('.')
  let l:line = line('.')
  if a:visual
    let l:curline = line("'<")
  endif
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
    let l:line = search('^' . matchstr(getline(l:line), '\(^\s*\)') .'\%' . l:end . l:line . 'l\S', l:search_dir . 'nW')
    let l:count = l:count - 1
  endwhile
  call cursor(l:curline, l:curcol)
  if a:operator
    normal! 0V
  elseif a:visual
    normal! gv
  endif
  call cursor(l:line, 0)
  normal! ^
endfunction

function! <SID>indentTextObj(inner)
  let curcol = col('.')
  let curline = line('.')
  let lastline = line('$')
  let i = indent(line('.'))
  if getline('.') !~? "^\\s*$"
    let p = line('.') - 1
    let nextblank = getline(p) =~? "^\\s*$"

    while p > 0 && ((!nextblank && indent(p) >= i) || (!a:inner && nextblank))
      -
      let p = line('.') - 1
      let nextblank = getline(p) =~? "^\\s*$"
    endwhile

    normal! 0V
    call cursor(curline, curcol)
    let p = line('.') + 1
    let nextblank = getline(p) =~? "^\\s*$"
    while p <= lastline && ((!nextblank && indent(p) >= i) || (!a:inner && nextblank))
      +
      let p = line('.') + 1
      let nextblank = getline(p) =~? "^\\s*$"
    endwhile
    normal! $
  endif
endfunction

onoremap <silent>ai :<C-u>call <SID>indentTextObj(0)<CR>
onoremap <silent>ii :<C-u>call <SID>indentTextObj(1)<CR>
xnoremap <silent>ai <Esc>:call <SID>indentTextObj(0)<CR><Esc>gv
xnoremap <silent>ii <Esc>:call <SID>indentTextObj(1)<CR><Esc>gv

nnoremap ,j :<C-u>call <SID>findSameIndent(v:count1, 'j', 0, 0)<CR>
nnoremap ,k :<C-u>call <SID>findSameIndent(v:count1, 'k', 0, 0)<CR>
xnoremap ,j <Esc>:call <SID>findSameIndent(v:count1, 'j', 1, 0)<CR><Esc>gv
xnoremap ,k <Esc>:call <SID>findSameIndent(v:count1, 'k', 1, 0)<CR><Esc>gv
onoremap ,j :<C-u>call <SID>findSameIndent(v:count1, 'j', 0, 1)<CR>
onoremap ,k :<C-u>call <SID>findSameIndent(v:count1, 'k', 0, 1)<CR>
