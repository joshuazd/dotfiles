function! findfunc#FindFunc() abort
  if get(get(g:, 'findfunc', {}), &filetype, []) == []
    return ''
  endif
  let curline = line('.')
  let curcol = col('.')
  let func_start = search(g:findfunc[&filetype][0], 'bnWc')
  let func_end = search(g:findfunc[&filetype][1], 'bnWc')
  if func_start >= func_end
    return matchstr(getline(func_start), g:findfunc[&filetype][2])
  else
    return ''
  endif
endfunction
