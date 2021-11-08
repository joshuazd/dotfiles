setlocal conceallevel=2
setlocal comments=n:-,n::
setlocal formatoptions+=or
setlocal shiftwidth=2
setlocal softtabstop=2
let g:todo_words = get(g:, 'todo_words', [['TODO', '|', 'DONE']])
let g:todo_update_boxes = get(g:, 'todo_update_boxes', 1)

function! s:flatten(list)
  let val = []
  for elem in a:list
    if type(elem) == type([])
      call extend(val, s:flatten(elem))
    else
      call add(val, elem)
    endif
    unlet elem
  endfor
  return val
endfunction

function! s:taskChange() abort
  if match(getline('.'),'^\s*[-+*]\s\+') < 0
    return
  endif
  let flat_list = s:flatten(g:todo_words)
  call filter(flat_list, "v:val !=? '|'")
  if match(getline('.'),'^\s*[-+*]\s\+\(' . join(flat_list, '\|') . '\)\s') < 0
    call setline(line('.'), substitute(getline('.'), '^\s*[-+*]\s\+\zs', flat_list[0] . ' ', ''))
  else
    let task = matchstr(getline('.'), '^\s*[-+*]\s\+\zs\w\+')
    let next = ''
    for list in g:todo_words
      let idx = index(list,task)
      if idx >= 0 && idx + 1 < len(list)
        if list[idx+1] ==? '|'
          let next = list[idx+2]
        else
          let next = list[idx+1]
        endif
      endif
    endfor
    call setline(line('.'), substitute(getline('.'), '^\s*[-+*]\s\+\zs' . task . '\s*', next . (next ==? '' ? '' : ' '), ''))
  endif
  if g:todo_update_boxes
    call s:updateBoxes()
  endif
  silent! call repeat#set("\<Plug>(TodotaskChange)", v:count1)
endfunction

function! s:taskSelect(count) abort
  let flat_list = s:flatten(g:todo_words)
  let maxl = len(flat_list[0])
  for word in flat_list
    if len(word) > maxl
      let maxl = len(word)
    endif
  endfor
  let tasks = []
  let tsel = {}
  let labels = 'abcdefghijklmnopqrstuvwxyz'
  let idx = 0
  for list in g:todo_words
    let tasks += ['']
    for item in list
      if item !=? '|'
        let tasks[len(tasks) - 1] .= labels[idx] . ' : ' . item . repeat(' ', maxl - len(item) + 1)
        let tsel[labels[idx]] = item
        let idx += 1
      endif
    endfor
  endfor
  execute 'rightbelow ' . len(tasks) . 'new'
  setlocal nolist bufhidden=wipe buftype=nofile
  put! =join(tasks,\"\n\")
  normal! Gddgg
  setlocal nomodifiable readonly
  redraw!
  let char = nr2char(getchar())
  bwipe
  if index(keys(tsel),char) >= 0
    let n_task = tsel[char]
    for i in range(a:count)
      if match(getline(line('.')+i),'^\s*[-+*]\s\+' . join(flat_list, '\|') . '\s') < 0
        call setline(line('.')+i, substitute(getline(line('.')+i), '^\s*[-+*]\s\+\zs', n_task . ' ', ''))
      else
        call setline(line('.')+i, substitute(getline(line('.')+i), '^\s*[-+*]\s\+\zs\w*', n_task, ''))
      endif
    endfor
    if g:todo_update_boxes
      call s:updateBoxes()
    endif
  endif
  silent! call repeat#set("\<Plug>(TodotaskSelect)", a:count)
endfunction

function! s:updateBoxes() abort
  let done_words = []
  for list in g:todo_words
    for word in list[index(list, '|')+1:]
      let done_words += [word]
    endfor
  endfor
  for linenr in range(1, line('$'))
    if match(getline(linenr), '\[\d*/\d*\]') >= 0
      let done = 0
      let total = 0
      let ws = matchstr(getline(linenr), '^\s*')
      let lastln = linenr
      for n in range(linenr + 1, line('$'))
        if len(ws) >= len(matchstr(getline(n), '^\s*'))
          break
        endif
        if match(getline(n), '^\s*[-+*]\s\+\zs\(' . join(filter(s:flatten(g:todo_words), "v:val !=? '|'"), '\|') . '\)') >= 0
          let total += 1
        endif
        if match(getline(n), '^\s*[-+*]\s\+\zs\(' . join(done_words, '\|') . '\)') >= 0
          let done += 1
        endif
      endfor
      if match(getline(linenr), '\[' . done . '/' . total . '\]') < 0
        call setline(linenr, substitute(getline(linenr),  '\[\d*/\d*\]', '[' . done . '/' . total . ']', ''))
      endif
    endif
  endfor
  silent! call repeat#set("\<Plug>(TodoupdateBoxes)", -1)
endfunction

nnoremap <silent> <buffer> <Plug>(TodotaskChange) :call <SID>taskChange()<CR>
nnoremap <silent> <buffer> <Plug>(TodotaskSelect) :<C-u>call <SID>taskSelect(v:count1)<CR>
nnoremap <silent> <buffer> <Plug>(TodoupdateBoxes) :<C-u>call <SID>updateBoxes()<CR>
nmap <buffer> ,t <Plug>(TodotaskChange)
nmap <buffer> ,ct <Plug>(TodotaskSelect)
nmap <buffer> ,/ <Plug>(TodoupdateBoxes)
