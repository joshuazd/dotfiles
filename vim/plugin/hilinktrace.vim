if exists('g:loaded_hilinks')
  finish
endif
let g:loaded_hilinks = 1

let s:save_cpo = &cpo
set cpo&vim

let s:HLTmode = 0

noremap <script> <Plug>HiLinkTrace :call hilinktrace#HiLinkTrace(0)<CR>
command! -bang HLT call hilinktrace#HiLinkTrace(<bang>0)

if !exists('g:hilinks_fmtwidth')
  let g:hilinks_fmtwidth= 35
endif

let &cpo = s:save_cpo
unlet s:save_cpo
