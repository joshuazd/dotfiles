if exists('g:loaded_commands')
  finish
endif
let g:loaded_commands = 1

let s:save_cpo = &cpo
set cpo&vim


let cmd_map = {
      \'Make'    : 'vim-dispatch',
      \'Dispatch': 'vim-dispatch'
      \}

for [cmd, name] in items(cmd_map)
  execute 'command! -nargs=* -complete=file -bang -range ' . cmd
        \. ' delcommand ' . cmd
        \. '| Packadd ' . name
        \. '|' . cmd . '<bang>' . ' <args>'
endfor


let &cpo = s:save_cpo
unlet s:save_cpo
