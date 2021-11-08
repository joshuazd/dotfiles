function! textobj#indent#findSameIndent(count, dir, visual, operator) abort
  let line = line('.')
  let l:count = a:count
  let [end, search_dir] = get({'k':['<', 'b']}, a:dir, ['>', ''])
  while l:count > 0
    " Search pattern taken from http://vim.wikia.com/wiki/Move_to_next/previous_line_with_same_indentation
    let line = search('^' . matchstr(getline(line), '\(^\s*\)') .'\%' . end . line . 'l\S', search_dir . 'nW')
    let l:count -= 1
  endwhile
  if a:operator
    keepjumps normal! 0V
  elseif a:visual
    normal! gv
  endif
  keepjumps call cursor(line, 0)
  keepjumps normal! ^
endfunction

function! textobj#indent#indentTextObj(inner, block) abort
  let indent = indent('.')
  let blank = a:inner ? '\s*$|' : ''
  let block = a:block ? '| {' . (indent + 1) . ',}|\t{' . (indent/&tabstop + 1) . ',}' : ''
  let pattern = '\v^%('. blank . '%( {,' . max([indent - 1,0]) . '}|\t{,' . max([indent - 1,0]) / &tabstop . '}' . block . ')\S)'
  let up = max([search(pattern, 'nWb'), 0])
  let down = min([search(pattern, 'nW'), line('$')])
  let up = (up == 1 ? 0 : up)
  let down = (down == 0 ? line('$') + 1 : down)
  if !indent && !a:inner
    normal! ggVG
  elseif !indent && a:inner
    normal! vip
  else
    execute 'normal! ' . (up + 1) . 'G0V' . (down - 1) . 'G'
  endif
endfunction

