function! ConvertNum(num) abort
  if a:num !~? '.\{-}\(\d\+,\?\)\{-1,}\d\+.\{-}'
    return
  endif
  let num = matchstr(a:num, '.\{-}\zs\(\d\+,\?\)\{-1}\d\+\ze.\{-}')
  if num =~? '^\d\+$'
    let reverse_num = join(reverse(split(num, '\zs')), '')
    let num_parts = split(reverse_num, '\d\{1,3}\zs')
    let num = join(reverse(split(join(num_parts, ','), '\zs')), '')
  elseif num =~? '^\(\d\+,\)\+\d\+$'
    let num = join(split(num, ','), '')
  endif
  let @n = substitute(a:num, '.\{-}\zs\(\d\+,\?\)\{-1}\d\+\ze.\{-}', num, '')
endfunction
nnoremap ,, :let isk=&l:isk\|setl isk+=,<CR>mn"nyiw:call ConvertNum('<C-r>n')<CR>viw"np`n:setl isk=<C-r>=isk<CR><CR>
xnoremap ,, mn"ny:call ConvertNum('<C-r>n')<CR>gv"np`ngv
