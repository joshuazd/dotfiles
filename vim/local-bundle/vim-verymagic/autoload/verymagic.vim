function! verymagic#verymagic(...) abort
  if a:0
    let char = a:1
  else
    let char = '/'
  endif
  let cmdline = getcmdline()[0:getcmdpos()-2]
  if cmdline =~? (getcmdtype() ==? ':' ? '[/?]' : '') . '\\v$'
    return "\<BS>\<BS>" . char
  elseif getcmdtype() !=? ':'
    return char
  endif
  let linenum_pat = '%(\d+|\.|\$|\%|''[a-zA-Z<>]|\?|\&|\/.*\/|\?.*\?|\/)'
  let commands = '%(s%[ubstitute]|v%[global]|g%[lobal]\!?|sor%[t]\!?%(\s+[bfinorux]*)?\s+)'
  let sub_pat = '\v^%(%(' . linenum_pat . '%([,;]' . linenum_pat . ')*)?' . commands . ')$'
  let range_pat = '\v^%(%(' . linenum_pat . '[,;])+)$'
  if cmdline =~? sub_pat || ((cmdline =~? range_pat || cmdline ==? '') && char =~? '[/?]')
    return char .'\v'
  else
    return char
  endif
endfunction
