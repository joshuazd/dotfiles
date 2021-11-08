function! args#tabsplit(...) abort
  if !a:0
    let arglist = argv()
  else
    let arglist = a:000
  endif
  let files = reverse(glob(arglist[0], v:false, v:true))
  execute 'tabedit '.files[0]
  if len(files) > 1
    let arglist = files[1:] + arglist[1:]
  endif
  for arg in arglist
    for file in reverse(glob(arg, v:false, v:true))
      execute 'split '.file
    endfor
  endfor
  1winc w
endfunction
