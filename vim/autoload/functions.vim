function! functions#TrimWhiteSpace() abort
  if !&binary && &filetype !=? 'diff'
    let l:save = winsaveview()
    " vint: -ProhibitCommandRelyOnUser -ProhibitCommandWithUnintendedSideEffect
    keeppatterns %s/\s\+$//e
    " vint: +ProhibitCommandRelyOnUser +ProhibitCommandWithUnintendedSideEffect
    call winrestview(l:save)
  endif
endfunction

function! functions#VimGrepAll(pattern) abort
  call setqflist([])
  exe 'bufdo silent vimgrepadd ' . a:pattern . ' %'
  cwindow
  exe 'normal '
endfunction

function! functions#ToggleConceal() abort
  if &conceallevel == 0
    set conceallevel=2
  else
    set conceallevel=0
  endif
endfunction

function! functions#VimRefresh() abort
  NeoCompleteClean
  NeoCompleteBufferMakeCache
  NeoCompleteMemberMakeCache
  GutentagsUpdate!
  if &filetype ==? 'java'
    JCcacheClear
  endif
  redraw!
  syntax sync fromstart
endfunction


function! functions#InsertToggle(toggle) abort
  if exists(':GitGutterDisable')
    if a:toggle ==# 'enter'
      GitGutterDisable
    else
      GitGutterEnable
    endif
  endif
endfunction


function! functions#TabMapping() abort
  if neocomplete#complete_common_string() !=? ''
    return neocomplete#complete_common_string()
  elseif pumvisible()
    return "\<C-n>"
  else
    let l:snippet = UltiSnips#ExpandSnippetOrJump()
    if g:ulti_expand_or_jump_res > 0
      return l:snippet
    else
      return "\<TAB>"
    endif
  endif
endfunction
function! functions#ReverseTabMapping() abort
  if pumvisible()
    return "\<C-p>"
  else
    let l:snippet = UltiSnips#JumpBackwards()
    if g:ulti_jump_backwards_res > 0
      return l:snippet
    else
      return "\<TAB>"
    endif
  endif
endfunction
function! functions#EnterMapping() abort
  call UltiSnips#ExpandSnippetOrJump()
  return g:ulti_expand_or_jump_res
endfunction
