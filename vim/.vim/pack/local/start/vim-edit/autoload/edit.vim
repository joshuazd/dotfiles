function! edit#open(...) abort
  if !a:0 || empty(a:1)
    call feedkeys(":E \<C-d>")
    return
  endif
  if len(glob(a:1, 0, 1)) <= 1
    execute 'edit ' a:1
  else
    try
      if len(globpath(&path, a:1, 0, 1)) == 1
        execute 'find' a:1
      else
        throw 'Too many files'
      endif
    catch
      let files = []
      for dir in globpath('.,'.&path, a:1, 0, 1)
        if index(files, dir) == -1 && index(argv(), dir) == -1
              \ && index(files, './'.dir) == -1 && index(argv(), './'.dir) == -1
          let files += [dir]
        endif
      endfor
      if !empty(files)
        execute 'argadd ' join(files,' ')
        execute 'edit ' files[0]
      endif
    endtry
  endif
endfunction
