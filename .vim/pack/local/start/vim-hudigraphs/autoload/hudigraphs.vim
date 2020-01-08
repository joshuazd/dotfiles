" This elaboration intercepts the timeouts on regular getchar()...
function! s:active_getchar () abort
    let char = 0
    while !char
        let char = getchar()
    endwhile
    return nr2char(char)
endfunction

" Retrieve the digraph list (should be called in a :silent)...
function! s:get_digraphs() abort
    redir => digraphs
    digraphs
    redir END
    return substitute(digraphs,'\%d173', '-?','')   " Translate invisible soft-hyphen
endfunction

function! s:show_digraphs (digraphs, cursor_char, context) abort
    " Pad digraph table to fill screen
    let digraphs = copy(a:digraphs) + repeat(['~'], winheight(0))

    " Display first half of digraph table...
    echon "\n"
    echohl SpecialKey
    echon join(digraphs[0 : a:context.line-3], "\n") . "\n"

    " Display cursor line with emulated digraph marker...
    echohl Normal
    echon strpart(a:context.text, 0, a:context.col-1)
    echohl HUDG_Cursor_Emulation
    echon a:cursor_char
    echohl Normal
    echon strpart(a:context.text, a:context.col-1) . "\n"

    " Display remainder of digraph table...
    echohl SpecialKey
    echon join(digraphs[a:context.line-2 : winheight(0)-2], "\n") . "\n"
    echohl None
endfunction

let g:HUDG_filtering = 1

function! s:filter_digraphs(digraphs, char) abort
  if !g:HUDG_filtering
    return a:digraphs
  endif
  let digraphs = copy(a:digraphs)

  for line in range(len(digraphs))
    let filtered_line = ''
    for digraph_spec in split(digraphs[line], '..\s*.\zs\s*')
      let dgrph = split(digraph_spec, '\s\+')
      if len(dgrph) != 2
        continue
      else
        let [key_code, digraph] = dgrph
      endif
      if key_code =~# '\V\^' . a:char
        let filtered_line .= ' ' . key_code[1:] . ' ' . digraph . "\t"
      else
        let filtered_line .= repeat(' ',strdisplaywidth(digraph_spec)) . "\t"
      endif
    endfor
    let digraphs[line] = filtered_line
  endfor

  return digraphs
endfunction

function! s:digraphs_table() abort
  silent! let digraphs_list = split(s:get_digraphs(), "\n")

  let digraphs_table = []
  for line in range(len(digraphs_list))
    let table_line = ''
    for digraph_spec in split(digraphs_list[line], '..\s*.\s*\d\+\s\zs\s*')
      try
        let [key_code, digraph, unicode] = split(digraph_spec, '\s\+')
      catch
        let [key_code, digraph, unicode] = ['','',0]
      endtry
      if (unicode >= 160 && unicode < 1488) || unicode > 1700
        " let digraphs_table += [digraph_spec]
        let table_line .= key_code . ' ' . digraph . "\t"
        " let digraphs_table += [key_code . ' ' . digraph . ' ']
      endif
    endfor
    if !empty(table_line)
      let digraphs_table += [table_line]
    endif
  endfor

  return digraphs_table
endfunction

" Emulate a more helpful ^K...
function! hudigraphs#HUDG_GetDigraph() abort
  let more = &more
  set nomore
    " Locate cursor...
    let context = { 'line': winline(), 'col': wincol(), 'text': getline('.') }

    " Grab list of digraphs...
    let digraphs = s:digraphs_table()

    " Simulate first char of two-character digraph code (with <C-K> or <ESC> to escape)...
    call s:show_digraphs(digraphs, '?', context)
    let char1 = s:active_getchar()

    " Simulate second char of two-character digraph code (with <C-K> or <ESC> to escape)...
    if (char1 ==? "\<C-K>" || char1 ==? "\<ESC>")
        let char2 = ''
    else
        call s:show_digraphs(s:filter_digraphs(digraphs, char1), char1, context)
        let char2 = s:active_getchar()
    endif

    " Return the digraph-constructing sequence...
    return "\<C-K>".char1.char2
    let &more = more
endfunction
