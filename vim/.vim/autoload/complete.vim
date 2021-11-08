function! complete#fzf_tags() abort
  let g:_fzf_layout = get(g:, 'fzf_layout', {})
  let g:fzf_layout = {'window': 'call complete#fzf_window()'}
  let g:_col = col('.')
  return fzf#vim#complete(fzf#wrap({
        \'options': ['--reverse', '--nth', '1..2'],
        \'prefix': '\k*$',
        \'source': funcref('complete#tags')
        \}))
endfunction

function! complete#tags(prefix) abort
  if len(a:prefix) == 0
    let prefix = '.'
    let g:complete_prefix_length = 2
  else
    let prefix = a:prefix
    let g:complete_prefix_length = len(prefix) + 2

  endif
  let tags = map(taglist(prefix), { _,x -> x.name })
  let g:complete#fzf#width = max(map(copy(tags), { _,x -> len(x) }))
  return tags
endfunction

function! complete#fzf_window() abort
  let line = line('.')+1
  echom line
  let args = {'border':[],
        \'maxwidth': &columns - 8,
        \'pos': 'topleft',
        \'line': line,
        \'col': (g:_col <= g:complete_prefix_length + 2 ? 1 : g:_col - g:complete_prefix_length - 2),
        \'minwidth': g:complete#fzf#width + 6,
        \'minheight': 22,
        \'borderchars': ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
        \'borderhighlight': ['Comment'],
        \'highlight': 'Normal',
        \'zindex': 50
        \}

  unlet g:complete#fzf#width
  call s:create_popup_window(args, 1)
  unlet args.border
  let args.col = (g:_col <= g:complete_prefix_length + 2 ? 3 : g:_col - g:complete_prefix_length)
  let args.minwidth -= 2
  " let args.minheight -= 2
  let args.line = line+1
  let args.callback = 'complete#_fzf_restore'
  let args.zindex += 1
  call s:create_popup_window(args, 0)
  " let buf = term_start(&shell, {'hidden': 1})
  " let id = popup_create(buf, args)
  " exe 'au BufWipeout * ++once bw! '.buf
endfunction

function! complete#_fzf_restore(...) abort
  let g:fzf_layout = g:_fzf_layout
  unlet g:_fzf_layout
  unlet g:_col
endfunction

function! s:create_popup_window(opts, frame) abort
  if a:frame
    let id = popup_create('', a:opts)
    " call setwinvar(id, '&wincolor', a:hl)
    exe 'au BufWipeout * ++once call popup_close('.id.')'
    return winbufnr(id)
  else
    let buf = term_start(&shell, {'hidden': 1})
    call popup_create(buf, a:opts)
    exe 'au BufWipeout * ++once bw! '.buf
  endif
endfunction
