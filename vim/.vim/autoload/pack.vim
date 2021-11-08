function! pack#add(name, bang) abort
  if has('packages')
    execute 'packadd'.a:bang.' '.a:name
    if a:bang !=# '!'
      execute 'runtime! pack/*/opt/'.a:name.'/after/plugin/**/*.vim'
    endif
  else
    silent! call pathogen#infect('pack/{}/opt/'.a:name)
  endif
  execute 'runtime! pack/*/opt/'.a:name.'/ftdetect/**/*.vim'
  silent! doautocmd filetypedetect
endfunction
