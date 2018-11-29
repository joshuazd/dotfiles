let s:linenum_pat = '%(\d+|\.|\$|\%|''[a-zA-Z<>]|\?|\&|\/.*\/|\?.*\?|\/)'
let s:commands = '\s*%(s%[ubstitute]|v%[global]|g%[lobal]\!?|sor%[t]\!?%(\s+[bfinorux]*)?\s+)'
let s:range = '%(' . s:linenum_pat . '%([,;]' . s:linenum_pat . ')*)?'
let s:do_pat = '\v^%(' . s:range . '%(windo|bufdo\!?)\s+' . s:range . s:commands . ')$'
let s:sub_pat = '\v^%(' . s:range . s:commands . ')$'
let s:range_pat = '\v^%(%(' . s:linenum_pat . '[,;])+)$'

function! verymagic#verymagic(...) abort
  if a:0
    let char = a:1
  else
    let char = '/'
  endif
  let cmdline = getcmdline()[0:getcmdpos()-2]
  if cmdline =~# (getcmdtype() ==? ':' ? escape(char,'~^') : '') . '\\v$' &&
        \ ((xor(getcmdtype() !~? '/', char ==? '/') && xor(getcmdtype() !~? '?', char ==? '?')) || getcmdtype() ==? ':')
    return "\<BS>\<BS>" . char
  elseif getcmdtype() !=? ':'
    return char
  endif
  if cmdline =~# s:sub_pat || ((cmdline =~# s:range_pat || cmdline ==? '') && char =~? '[/?]') || cmdline =~# s:do_pat
    return char .'\v'
  else
    return char
  endif
endfunction
