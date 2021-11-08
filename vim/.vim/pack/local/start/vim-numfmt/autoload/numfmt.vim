function! numfmt#convertNum(num) abort
  if a:num !~? '.\{-}\(\d\+,\?\)\{-1,}\d\+.\{-}'
    return
  endif
  let num = matchstr(a:num, '.\{-}\zs\(\d\+,\?\)\+\d\+\ze.\{-}')
  if num =~? '^\d\+$'
    let reverse_num = join(reverse(split(num, '\zs')), '')
    let num_parts = split(reverse_num, '\d\{1,3}\zs')
    let num = join(reverse(split(join(num_parts, ','), '\zs')), '')
  elseif num =~? '^\(\d\+,\)\+\d\+$'
    let num = join(split(num, ','), '')
  endif
  let @n = substitute(a:num, '.\{-}\zs\(\d\+,\?\)\+\d\+\ze.\{-}', num, '')
endfunction
