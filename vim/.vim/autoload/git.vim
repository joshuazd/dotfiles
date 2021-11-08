function! git#blame(range) abort
  let content = substitute(join(systemlist('git -C ' . shellescape(expand('%:p:h')) . ' blame -L '.a:range.' ' . expand('%:t')), "\n"), '^[^)]\+\zs) .*$', ')', '')
  if content !~# 'Not Committed Yet'
    let content = split(trim(substitute(content, '^\([a-z0-9]\+\)[^)]\+)$', '\=system("git log -1 " . submatch(1))', '')),'\n')
    " let content = trim(substitute(content, '^\([a-z0-9]\+\)[^)]\+\zs)$', '\=") " . system("git log -1 --pretty=%s " . submatch(1))', ''))
  endif
  if has('textprop')
    let cols = &columns
    let args = {'border':[],
          \'maxwidth': &columns - 8,
          \'pos': 'botleft',
          \'line': 'cursor-1',
          \'moved': 'WORD',
          \'borderchars': ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
          \'padding': [0,1,0,1],
          \'borderhighlight': ['Comment']
          \}
    if (len(content) < cols - 12)
      if (col('.') + len(content) + 8 < cols )
        if col('.') < 5
          let args.col = 5
        else
          let args.col = 'cursor'
        endif
      else
        let args.col = 'cursor-'.(len(content) + 8 + col('.') - cols)
      endif
    endif
    let id = popup_create(content, args)
    call setwinvar(id, '&wincolor', 'Normal')
    call setwinvar(id, '&linebreak', 1)
    " call win_execute(id, 'syntax enable')
    call setbufvar(winbufnr(id), '&filetype', 'git')
  else
    echom content
  endif
endfunction
