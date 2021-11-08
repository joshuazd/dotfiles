setlocal commentstring=#%s
setlocal softtabstop=2
setlocal shiftwidth=2
command! -range=% FormatYAML <line1>,<line2>!python -c
      \"from yaml import dump, load; import sys; print dump(load(sys.stdin.read()),default_flow_style=False)"
augroup YAML
    autocmd!
    if match(getline(1,'$'),'^\(swagger\|oas\)') != -1
      if executable('spectral')
        setlocal makeprg=spectral\ lint\ -r\ $HOME/.spectral.yml\ -q\ --format=text\ %:S
        autocmd BufWritePost <buffer> silent! make|cwindow|redraw!
      endif
    elseif executable('yamllint')
      setlocal errorformat=%f:%l:%c:\ [%trror]\ %m,%f:%l:%c:\ [%tarning]\ %m
      setlocal makeprg=yamllint\ -f\ parsable\ -d\ \"{rules:\ {line-length:\ disable}}\"\ %:S
      autocmd BufWritePost <buffer> silent! make|cwindow|redraw!
    endif
augroup END

let b:undo_ftplugin = 'setlocal makeprg< errorformat< commentstring<'
