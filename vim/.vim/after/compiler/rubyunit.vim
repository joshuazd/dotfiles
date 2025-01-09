

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

let &l:errorformat =
      \ '%-G,' .
      \ '%-GLoading dev_env.rb%.%#,' .
      \ '%-GFetching Doppler parameters%.%#,' .
      \ '%-GEnvironment variables loaded%.%#,' .
      \ '%-GDEPRECATION WARNING%.%#,' .
      \ '%-GBeing able to do this is deprecated. Autoloading during initialization is going%.%#,' .
      \ '%-Gto be an error condition in future versions of Rails.%.%#,' .
      \ '%-GReloading does not reboot the application\, and therefore code executed during%.%#,' .
      \ '%-Ginitialization does not run again. So\, if you reload Gateway\, for example\,%.%#,' .
      \ '%-Gthe expected changes won''t be reflected in that stale Module object.%.%#,' .
      \ '%-GThese autoloaded constants have been unloaded.%.%#,' .
      \ '%-GIn order to autoload safely at boot time\, please wrap your code in a reloader%.%#,' .
      \ '%-Gcallback this way:%.%#,' .
      \ '%-G    Rails.application.reloader.to_prepare do%.%#,' .
      \ '%-G      # Autoload classes and modules needed at boot time here.%.%#,' .
      \ '%-G    end%.%#,' .
      \ '%-GThat block runs when the application boots\, and every time there is a reload.%.%#,' .
      \ '%-GFor historical reasons\, it may run twice\, so it has to be idempotent.%.%#,' .
      \ '%-GCheck the "Autoloading and Reloading Constants" guide to learn more about how%.%#,' .
      \ '%-GRails autoloads and reloads.%.%#,' .
      \ '%-G (called from <main> at /Users/jzinkduda/backend/config/environment.rb:5)%.%#,' .
      \ '%-G# Running tests %.%#,' .
      \ '%-G%.%#Sidekiq%.%#connecting to Redis%.%#,' .
      \ '%-G%\([31m\[FE\]%#[0m%\|[32m.%#[0m%\)%\+%.%#,' .
      \ '%-G[31m%.%#[0m,' .
      \ '%-G[31mFailure:,' .
      \ '%o[%f:%l],' .
      \ '%m[0m,' .
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

