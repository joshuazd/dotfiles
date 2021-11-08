if exists('g:loaded_textobj#column')
  finish
endif
let g:loaded_textobj#column = 1

let s:save_cpo = &cpo
set cpo&vim

function! s:column(whitespace, visualmode) abort
  let match = matchstr(getline('.'), '\v^\s*')
  let col = col('.')
  let lnum = line('.')
  let up = 0
  while(lnum-up-1 >= 1 && ((getline(lnum-up-1) =~? '\v^' . match . '\S' && col([lnum-up-1, '$']) > col) || (a:whitespace && getline(lnum-up-1) =~? '\v^\s*$')))
    let up += 1
  endwhile
  let down = 0
  while(lnum+down+1 <= line('$') && ((getline(lnum+down+1) =~? '\v^' . match . '\S' && col([lnum+down+1, '$']) > col) || (a:whitespace && getline(lnum+down+1) =~? '\v^\s*$')))
    let down += 1
  endwhile
  execute 'normal! ' . (a:visualmode ? "`<\<C-v>`>" : "\<C-v>" ) . (up ? up . 'k' : '' ) . 'o' . (down ? down . 'j' : '')
endfunction

xnoremap <silent> <Plug>(textobj#column_inner) m':<C-u>call <SID>column(0, 1)<CR>
onoremap <silent> <Plug>(textobj#column_inner) :<C-u>call <SID>column(0, 0)<CR>
xnoremap <silent> <Plug>(textobj#column_around) m':<C-u>call <SID>column(1, 1)<CR>
onoremap <silent> <Plug>(textobj#column_around) :<C-u>call <SID>column(1, 0)<CR>

if get(g:,'textobj_maps',1)
  xmap ic <Plug>(textobj#column_inner)
  omap ic <Plug>(textobj#column_inner)
  xmap ac <Plug>(textobj#column_around)
  omap ac <Plug>(textobj#column_around)
endif

let &cpo = s:save_cpo
unlet s:save_cpo
