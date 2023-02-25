

let &l:errorformat =
      \ '%-G,' .
      \ '%-G# Running tests %.%#,' .
      \ '%-G%\([31m\[FE\]%#[0m%\|[32m.%#[0m%\)%\+%.%#,' .
      \ '%-G[31m%.%#[0m,' .
      \ '%-G[31mFailure:,' .
      \ '%E%o[%f:%l],' .
      \ '%Z%m[0m,' .
      \ '%E[31mError:,' .
      \ '%C%o:,' .
      \ '%Z%m,' .
      \ '%-G    %o %f:%l:in %.%#,' .
      \ '%-G    %f/bin/m:%l:in %.%#[0m,' .
      \ '%-G    %f/bin/m:%l:in %.%#,' .
      \ '%-G    %f/bin/bundle:%l:in %.%#[0m,' .
      \ '%-G    %f/bin/bundle:%l:in %.%#,' .
      \ '    %f:%l:in %.%#[0m,' .
      \ '    %f:%l:in %.%#,' .
      \ '%-GCoverage report%.%#,' .
      \ '%E%o[%f:%l],' .
      \ '%Z%m'

" CompilerSet errorformat=\%W\ %\\+%\\d%\\+)\ Failure:,
" 			\%C%m\ [%f:%l]:,
" 			\%E\ %\\+%\\d%\\+)\ Error:,
" 			\%C%m:,
" 			\%C\ \ \ \ %f:%l:%.%#,
" 			\%C%m,
" 			\%Z\ %#,
" 			\%-G%.%#

