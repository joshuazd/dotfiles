function! putoperator#PutOperator(...) abort
  if !a:0
    return ":set opfunc=putoperator#PutOperator\<cr>\"" . v:register . 'g@'
  else
    let visual = get({'line': 'V', 'block': "\<c-v>"}, a:1, 'v')
    let [rv, rt] = [getreg(v:register), getregtype(v:register)]
    execute 'normal! g`[' . visual . 'g`]"' . v:register . 'p'
    call setreg(v:register, rv, rt)
  endif
endfunction
