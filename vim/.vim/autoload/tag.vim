function! tag#get(tag) abort
  redir => info
  exe 'silent! tselect '.a:tag
  redir END
  let info = trim(info)
  if info =~# '^Error'
    echohl ErrorMsg
    echo 'E426: tag not found: '.a:tag
    echohl None
    return
  endif
  let info = split(info, '\n')[1:-2]
  let tag = []
  for i in range(1,len(info)-1)
    if info[i] =~? '\V  \d\+\(\s\+\w\*\)\*\s\+'.a:tag
      break
    endif
    let tag += [trim(info[i])]
  endfor
  call popup_atcursor(tag, {'moved':'word','border':[]})
endfunction
