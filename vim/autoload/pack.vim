function! pack#add(name) abort
  if has('packages')
    execute 'packadd! '.a:name
  else
    silent! call pathogen#infect('pack/{}/opt/'.a:name)
  endif
  execute 'runtime! pack/*/opt/'.a:name.'/ftdetect/**/*.vim'
endfunction
