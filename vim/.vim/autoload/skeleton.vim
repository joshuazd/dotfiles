function! skeleton#replace() abort
  if &ft ==# 'vim'
    let file_name = substitute(substitute(expand('%:p:r'),'\v^%(\/[^\/]+){-1,}\/?%($|plugin|autoload|ftplugin)\/?','',''),'\/','#','g')
  else
    let file_name = expand('%:t')
  endif
  exe 'silent! %s/\C\V@file_name@/'.file_name
  exe 'silent! %s/\C\V@date@/'.strftime('%Y-%m-%d')
endfunction

function! skeleton#edit() abort
  normal! Gddgg
  call search('@start_here@')
  normal! cc
endfunction
