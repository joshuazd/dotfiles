function! ruby#run_command_in_engine(command) abort
  let cwd = getcwd()
  exec 'cd '.matchstr(expand('%:.'), '^engines/\w\+')
  exec a:command
  exec 'cd '.cwd
endfunction

function! ruby#FindFunc() abort
  " find most recent function
  let function_line = search(b:funcstart, 'bnWc')
  let [bufnum, lnum, col, off] = getpos('.')
  let search_range = join(getline(function_line, lnum - 1), "\n")
  let starts = []
  let ends = []
  call substitute(search_range, b:endstart, '\=add(starts, submatch(0))', 'g')
  call substitute(search_range, b:endend, '\=add(ends, submatch(0))', 'g')
  if len(starts) > len(ends)
    " inside the function
    let name = matchstr(getline(function_line), b:funcstart)
    return (name !=? '' ? ' ' . name : '')
  else
    return ''
  endif
endfunction

