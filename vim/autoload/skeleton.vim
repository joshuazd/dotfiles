function! skeleton#replace() abort
  let file_name = substitute(substitute(expand('%:p:r'),'\v^%(\/[^\/]+){-1,}\/?%($|plugin|autoload|ftplugin)\/?','',''),'\/','#','g')
  exe 'silent! %s/\C\V@file_name@/'.file_name
  exe 'silent! %s/\C\V@date@/'.strftime('%Y-%m-%d')
endfunction

function! skeleton#edit() abort
  normal! Gddgg
  call search('@start_here@')
  normal! cc
endfunction
