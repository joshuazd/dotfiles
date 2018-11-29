" vim-decselect
" Maintainer:	joshuazd
" Version:	0.1.0
" Location:	autoload/decselect.vim
"

function! decselect#Select(visual) abort
  let firstline = line('.')
  let curcol = col('.')
  let lastline = line('.')
  let char = get(b:, 'decselect_char', '\k')
  let word = matchstr(getline(firstline), '^\s*\zs' . char . '\+\>\ze')
  let match = '\C^\s*\zs' . word . '\>\ze'
  let firstline -= 1
  while firstline > 0 && matchstr(getline(firstline), match) !=# ''
    let firstline -= 1
  endwhile
  let firstline += 1
  if a:visual
    execute 'normal! ' . firstline . "G^\<C-v>"
  else
    execute 'normal! ' . firstline . 'G^V'
  endif
  call cursor(lastline, curcol)
  let lastline += 1
  while lastline <= line('$') && matchstr(getline(lastline), match) !=# ''
    let lastline += 1
  endwhile
  let lastline -= 1
  execute 'normal! ' . lastline . 'G$'
endfunction
