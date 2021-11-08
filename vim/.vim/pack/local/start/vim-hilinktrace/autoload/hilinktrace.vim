function! hilinktrace#HiLinkTrace(always) abort

  " save register a
  let keep_rega= @a

  " get highlighting linkages into register "a"
  redir @a
  silent! hi
  redir END

  " initialize with top-level highlighting
  let firstlink = synIDattr(synID(line('.'),col('.'),1),'name')
  let lastlink  = synIDattr(synIDtrans(synID(line('.'),col('.'),1)),'name')
  let translink = synIDattr(synID(line('.'),col('.'),0),'name')

  " if transparent link isn't the same as the top highlighting link,
  " then indicate it with a leading "T:"
  if firstlink != translink
    let hilink= 'T:'.translink.'->'.firstlink
  else
    let hilink= firstlink
  endif

  " trace through the linkages
  if firstlink != lastlink
    let no_overflow= 0
    let curlink    = firstlink
    "   call Decho("loop#".no_overflow.": hilink<".hilink.">")
    while curlink != lastlink && no_overflow < 10
      let no_overflow = no_overflow + 1
      let nxtlink     = substitute(@a,'^.*\<'.curlink.'\s\+xxx links to \(\a\+\).*$','\1','')
      if nxtlink =~# '\<start=\|\<cterm[fb]g=\|\<gui[fb]g='
        let nxtlink= substitute(nxtlink,'^[ \t\n]*\(\S\+\)\s\+.*$','\1','')
        let hilink = hilink .'->'. nxtlink
        break
      endif
      let hilink      = hilink .'->'. nxtlink
      let curlink     = nxtlink
    endwhile
  endif

  " Use new synstack() function, available with 7.1 and patch#215
  if v:version > 701 || ( v:version == 701 && has('patch215'))
    let syntaxstack = ''
    let isfirst     = 1
    let idlist      = synstack(line('.'),col('.'))
    if !empty(idlist)
      for id in idlist
        if isfirst
          let syntaxstack= syntaxstack.' '.synIDattr(id,'name')
          let isfirst = 0
        else
          let syntaxstack= syntaxstack.'->'.synIDattr(id,'name')
        endif
      endfor
    endif
  endif

  " display hilink traces
  redraw
  let synid= hlID(lastlink)
  if !exists('syntaxstack')
    echo printf('HltTrace: %-'.g:hilinks_fmtwidth.'s fg<%s> bg<%s>',hilink,synIDattr(synid,'fg'),synIDattr(synid,'bg'))
  else
    echo printf('SynStack: %-'.g:hilinks_fmtwidth.'s  HltTrace: %-'.g:hilinks_fmtwidth.'s fg<%s> bg<%s>',syntaxstack,hilink,synIDattr(synid,'fg'),synIDattr(synid,'bg'))
  endif

  " restore register a
  let @a= keep_rega

  " set up CursorMoved autocmd on bang
  if a:always
    if !s:HLTmode
      " install a CursorMoved highlighting trace
      let s:HLTmode= 1
      augroup HLTMODE
        autocmd!
        autocmd CursorMoved * call s:HiLinkTrace(0)
      augroup END
    else
      " remove the CursorMoved highlighting trace
      let s:HLTmode= 0
      augroup HLTMODE
        autocmd!
      augroup END
      augroup! HLTMODE
    endif
  endif

endfunction
