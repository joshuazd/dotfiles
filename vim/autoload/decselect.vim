function! decselect#Select(visual) abort
  let l:firstline = line('.')
  let l:curcol = col('.')
  let l:lastline = line('.')
  let l:w = matchstr(getline(l:firstline), '^\s*\zs\S\+')
  let l:firstline -= 1
  while l:firstline > 0 && matchstr(getline(l:firstline), '^\s*\zs' . l:w) !=# ''
    let l:firstline -= 1
  endwhile
  let l:firstline += 1
  if a:visual
    execute 'normal! ' . l:firstline . "G^\<C-v>"
  else
    execute 'normal! ' . l:firstline . 'G^V'
  endif
  call cursor(l:lastline, l:curcol)
  let l:lastline += 1
  while l:lastline <= line('$') && matchstr(getline(l:lastline), '^\s*\zs' . l:w) !=# ''
    let l:lastline += 1
  endwhile
  let l:lastline -= 1
  execute 'normal! ' . l:lastline . 'G$'
endfunction
