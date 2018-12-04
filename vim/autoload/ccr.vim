" make list-like commands more intuitive
function! ccr#CCR() abort
  let cmdline = getcmdline()
  if getcmdtype() !=? ':' | return "\<CR>" | endif
  if cmdline =~? '\v\C^(ls|files|buffers)' | return "\<CR>:b "
  elseif cmdline =~? '\v\C^(dli|il)' && len(split(cmdline,' ')) > 1 | return "\<CR>:".cmdline[0].'j  '.split(cmdline,' ')[1]."\<S-Left>\<Left>"
  elseif cmdline =~? '\v\C^(cli|lli)'      | return "\<CR>:sil ".repeat(cmdline[0], 2)."\<Space>"
  elseif cmdline =~? '\C^old'              | return "\<CR>:e #<"
  elseif cmdline =~? '\C^changes'          | set nomore | return "\<CR>:set more|norm! g;\<S-Left>"
  elseif cmdline =~? '\C^ju'               | set nomore | return "\<CR>:set more|norm! \<C-o>\<S-Left>"
  elseif cmdline =~? '\C^marks'            | return "\<CR>:norm! `"
  elseif cmdline =~? '\C^undol'            | return "\<CR>:u "
  else                                     | return "\<CR>"
  endif
endfunction


