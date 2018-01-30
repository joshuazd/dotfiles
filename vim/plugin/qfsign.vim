if exists('g:loaded_qfsign')
  finish
endif
let g:loaded_qfsign =1

let s:orig_scl = ''

sign define QFErr  texthl=ErrorMsg text=>>
sign define QFWarn texthl=Cursor   text=>>
sign define QFInfo texthl=Search   text=>>

command! -nargs=0 -bar SignsClear call s:clear_signs()
command! -nargs=0 -bar SignsPlace call s:place_signs()

augroup qfsign
  autocmd!
  autocmd QuickFixCmdPre [^l]* call s:clear_signs()
  autocmd QuickFixCmdPost [^l]* call s:place_signs()

  autocmd BufWinEnter * if getbufvar(0 + expand('<abuf>'), '&ft') ==? 'qf' | call s:place_signs() | endif
  autocmd BufWinLeave * if getbufvar(0 + expand('<abuf>'), '&ft') ==? 'qf' | call s:clear_signs() | endif
augroup END

let s:sign_count = get(s:, 'sign_count', 0)

function! s:place_signs() abort
  let l:qflist = getqflist()

  if len(l:qflist) > get(g:, 'qfsigns_max', 100)
    echohl ErrorMsg
    echom 'To many results, aborting'
    echohl NONE

    return
  endif

  if len(l:qflist) > 0
    let s:orig_scl = &signcolumn
    setlocal signcolumn=yes
  else
    let &l:signcolumn=s:orig_scl
  endif

  for l:error in l:qflist
    if l:error.bufnr < 0
      continue
    endif
    let s:sign_count = s:sign_count + 1
    if l:error.type ==# 'E'
      let l:err_sign = 'sign place ' . s:sign_count
            \ . ' line=' . l:error.lnum
            \ . ' name=QFErr'
            \ . ' buffer=' . l:error.bufnr
    elseif l:error.type ==# 'W'
      let l:err_sign = 'sign place ' . s:sign_count
            \ . ' line=' . l:error.lnum
            \ . ' name=QFWarn'
            \ . ' buffer=' . l:error.bufnr
    else
      let l:err_sign = 'sign place ' . s:sign_count
            \ . ' line=' . l:error.lnum
            \ . ' name=QFInfo'
            \ . ' buffer=' . l:error.bufnr
    endif
    silent! execute l:err_sign
  endfor
endfunction

function! s:clear_signs() abort
  while s:sign_count > 0
    execute 'sign unplace ' . s:sign_count
    let s:sign_count = s:sign_count - 1
  endwhile
  redraw!
endfunction
