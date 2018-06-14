function! findfunc#FindFunc() abort
  if get(g:findfunc, &filetype, []) == []
    return ''
  endif
  let l:curline = line('.')
  let l:curcol = col('.')
  let l:func = substitute(g:findfunc[&filetype][0], '\&shiftwidth', &shiftwidth, 'g')
  let l:endfunc = substitute(g:findfunc[&filetype][1], '\&shiftwidth', &shiftwidth, 'g')
  let l:name = substitute(g:findfunc[&filetype][2], '\&shiftwidth', &shiftwidth, 'g')
  let l:start = search(l:func, 'bnWc')
  let l:end = search(l:endfunc, 'bnWc')
  if l:start >= l:end
    let l:name = matchstr(getline(l:start), l:name)
    return l:name
  else
    return ''
  endif
endfunction
