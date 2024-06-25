function! grep#grep(cmd, ...) abort
  let l:saved_errorformat = &errorformat
  let &errorformat = &grepformat
  try
    let l:grepcmd = "system(join([&grepprg] + [expandcmd(join(a:000, ' '))], ' '))"
    exec a:cmd . ' ' . l:grepcmd
  finally
    let &errorformat = l:saved_errorformat
  endtry
endfunction

