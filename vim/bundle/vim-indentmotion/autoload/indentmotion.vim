" vim-indentmotion
" Maintainer:	joshuazd
" Version:	0.1.0
" Location:	plugin/indentmotion.vim
"

function! indentmotion#findSameIndent(count, dir, visual, operator) abort
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

function! indentmotion#indentTextObj(inner) abort
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

function! indentmotion#blockTextObj() abort
  let curcol = col('.')
  let curline = line('.')
  let lastline = line('$')
  let i = indent(line('.'))
  if getline('.') !~? "^\\s*$"
    let p = line('.') - 1
    let nextblank = getline(p) =~? "^\\s*$"

    while p > 0 && (!nextblank && indent(p) == i)
      -
      let p = line('.') - 1
      let nextblank = getline(p) =~? "^\\s*$"
    endwhile

    normal! 0V
    call cursor(curline, curcol)
    let p = line('.') + 1
    let nextblank = getline(p) =~? "^\\s*$"
    while p <= lastline && (!nextblank && indent(p) == i)
      +
      let p = line('.') + 1
      let nextblank = getline(p) =~? "^\\s*$"
    endwhile
    normal! $
  endif
endfunction
