function! quickfix#add(items, ...) abort
  if len(a:items) < 1
    return
  elseif len(a:items) < 2
    let parts = split(a:items[0], ':')
    silent! execute 'edit ' . parts[0] . '|' . parts[1] . '| normal! ' . parts[2] . '|'
    return
  endif
  let items = map(a:items, 's:convert_to_qf(v:val)')
  call setqflist(a:items)
  execute 'copen | resize ' . min([10,len(getqflist())]) . '| normal! '
endfunction

function! s:convert_to_qf(item) abort
  let parts = split(a:item, ':')
  return {'filename': parts[0], 'lnum': parts[1], 'col': parts[2], 'text': join(parts[3:],':')}
endfunction
