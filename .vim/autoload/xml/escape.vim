function! xml#escape#escape(...) abort
  if !a:0
    normal! gv"ay
  elseif a:1 ==? 'line'
    normal! V'[o']"ay
  else
    normal! v`[o`]"ay
  endif
  let escapes =
        \{ '<' : '\&lt;',
        \  '>' : '\&gt;',
        \  '&' : '\&amp;'}
  for k in keys(escapes)
    let @a = substitute(@a, k, escapes[k], 'g')
  endfor
  normal! gv"ap
endfunction
