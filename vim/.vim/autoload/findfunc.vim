function! findfunc#FindFunc() abort
  if get(get(g:, 'findfunc', functions#findFuncDefs()), &filetype, []) == []
    return ''
  endif
  let func_start = search(g:findfunc[&filetype][0], 'bnWc')
  let func_end = search(g:findfunc[&filetype][1], 'bnWc')
  if func_start >= func_end
    let name = matchstr(getline(func_start), g:findfunc[&filetype][2])
    return (name !=? '' ? ' ' . name : '')
  else
    return ''
  endif
endfunction
