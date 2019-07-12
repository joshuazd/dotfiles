if exists('g:loaded_lazyload')
  finish
endif
let g:loaded_lazyload = 1

let s:save_cpo = &cpo
set cpo&vim


let cmd_map = { 'Make' : 'vim-dispatch', 'Dispatch': 'vim-dispatch' }

function! s:load(cmd, name, bang, ...) abort
  exe 'delcommand '.a:cmd
  exe 'Packadd '.a:name
  echom a:cmd.a:bang.(a:0 && len(a:1) ? ' '.a:1 : '')
  exe a:cmd.a:bang.(a:0 && len(a:1) ? ' '.a:1 : '')
endfunction
for [cmd, name] in items(cmd_map)
  execute 'command! -nargs=* -complete=file -bang -range '.cmd
        \. " call <SID>load('".cmd."', '".name."', '<bang>', '<args>')"
endfor


let &cpo = s:save_cpo
unlet s:save_cpo
