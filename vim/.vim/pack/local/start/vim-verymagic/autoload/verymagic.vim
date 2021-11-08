let s:linenum_pat = '%(\d+|\.|\$|\%|''[a-zA-Z<>]|\?|\&|\/.*\/|\?.*\?|\/)'
let s:cmd_commands = 'v%[global]|g%[lobal]\!?'
let s:commands = '\s*%(s%[ubstitute]|' . s:cmd_commands . '|sor%[t]\!?%(\s+[bfinorux]*)?\s+)'
let s:range = '%(' . s:linenum_pat . '%([,;]' . s:linenum_pat . ')*)?'
let s:do_pat = '\v^%(' . s:range . '%(cdo|argdo|windo|bufdo\!?)\s+' . s:range . s:commands . ')$'
let s:sub_pat = '\v^%(' . s:range . s:commands . ')$'
let s:range_pat = '\v^%(%(' . s:linenum_pat . '[,;])+)$'
let s:global_pat = '\v^\s*' . s:range . '%(' . s:cmd_commands . ')([-~`!@#$%^&*()_+={}\[\]:;'', <>,.?/]).*\1' . s:commands . '$'

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
  if cmdline =~# s:sub_pat || ((cmdline =~# s:range_pat || cmdline ==? '') && char =~? '[/?]') || cmdline =~# s:do_pat || cmdline =~# s:global_pat
    return char .'\v'
  else
    return char
  endif
endfunction
