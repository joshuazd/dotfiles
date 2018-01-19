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

" make list-like commands more intuitive
function! functions#CCR() abort
    let cmdline = getcmdline()
    if cmdline =~? '\v\C^(ls|files|buffers)'
        " like :ls but prompts for a buffer command
        return "\<CR>:b"
    elseif cmdline =~? '\v\C/(#|nu|num|numb|numbe|number)$'
        " like :g//# but prompts for a command
        return "\<CR>:"
    elseif cmdline =~? '\v\C^(dli|il)'
        " like :dlist or :ilist but prompts for a count for :djump or :ijump
        return "\<CR>:" . cmdline[0] . 'j  ' . split(cmdline, ' ')[1] . "\<S-Left>\<Left>"
    elseif cmdline =~? '\v\C^(cli|lli)'
        " like :clist or :llist but prompts for an error/location number
        return "\<CR>:sil " . repeat(cmdline[0], 2) . "\<Space>"
    elseif cmdline =~? '\C^old'
        " like :oldfiles but prompts for an old file to edit
        return "\<CR>:e #<"
    elseif cmdline =~? '\C^changes'
        " like :changes but prompts for a change to jump to
        return "\<CR>:norm! g;\<S-Left>"
    elseif cmdline =~? '\C^ju'
        " like :jumps but prompts for a position to jump to
        return "\<CR>:norm! \<C-o>\<S-Left>"
    elseif cmdline =~? '\C^marks'
        " like :marks but prompts for a mark to jump to
        return "\<CR>:norm! `"
    elseif cmdline =~? '\C^undol'
        " like :undolist but prompts for a change to undo
        return "\<CR>:u "
    else
        return "\<CR>"
    endif
endfunction

function! functions#InsertToggle(toggle) abort
    if exists('*GitGutterDisable')
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
