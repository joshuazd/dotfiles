function! pack#add(name, bang) abort
  if has('packages')
    execute 'packadd'.a:bang.' '.a:name
  else
    silent! call pathogen#infect('pack/{}/opt/'.a:name)
  endif
  execute 'runtime! pack/*/opt/'.a:name.'/ftdetect/**/*.vim'
  doautocmd BufRead
endfunction
