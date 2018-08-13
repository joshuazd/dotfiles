setlocal makeprg=yamllint\ -f\ parsable\ -d\ \"{rules:\ {line-length:\ disable}}\"\ %:S
setlocal errorformat=%f:%l:%c:\ [%trror]\ %m,%f:%l:%c:\ [%tarning]\ %m
setlocal commentstring=#%s
command! -range=% FormatYAML <line1>,<line2>!python -c
      \"from yaml import dump, load; import sys; print dump(load(sys.stdin.read()),default_flow_style=False)"
augroup YAML
    autocmd!
    if executable('yamllint')
      autocmd BufWritePost *.yaml,*.yml silent! make|cwindow|redraw!
    endif
augroup END
