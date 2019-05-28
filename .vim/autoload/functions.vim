" function for 'foldtext'
function! functions#MyFoldText() abort
  let line = getline(v:foldstart)
  let n = v:foldend - v:foldstart + 1
  let info = ' ' . n . ' lines  ├──────────'
  let line .= repeat(' ',999)
  let num_w = getwinvar(0, '&number' ) * getwinvar( 0, '&numberwidth')
  let fold_w = getwinvar(0, '&foldcolumn')
  let line = strpart(line, 0, winwidth(0) - strchars(info) - num_w - fold_w)
  return line . info
endfunction

" regexes for function names for findfunc#FindFunc
function! functions#findFuncDefs() abort
  let g:findfunc = {'vim'   : ['^\s*fun\%[ction]', '^\s*endf\%[unction]',  '^\s*fun\%[ction]!\?\s\+\zs[a-z][[:alnum:]#_]*\ze('],
        \'xml'   : ['^\s*<resource', '<\/resource>', '\%(ur[il]-\(mapping\|template\)="\)\@<=[^"]*"\@='],
        \'python': ['^\s*\(class\|def\|async def\)\>', '\S\n\=\zs\n*\(^\s*\(class\|def\|async def\)\|^\S\)', '^\s*\(class\|def\|async def\)\s\+\zs\h\w*\ze('],
        \'java'  : ['^\(\t\| \{' . &shiftwidth . '}\)\S\+.*\(\n^.*\)\={', '^\(\t\| \{' . &shiftwidth . '}\)}', '\h\w*\ze('],
        \'sh'    : ['^\s*[A-Za-z_0-9:][-a-zA-Z_0-9:]*\s*()\_s*{', '^\s*}', '[A-Za-z_0-9:][-a-zA-Z_0-9:]*'],
        \'zsh'   : ['^\s*\h[[:alnum:]_-]*\s*()\_s*{', '^\s*}', '\h[[:alnum:]_-]*'],
        \'c'     : ['\h\w*\s*(.*)\_s*{', '^\s*}', '\h\w*\ze\s*('],
        \'cpp'   : ['\h\w*\s*(.*)\_s*{', '^\s*}', '\h\w*\ze\s*(']}
endfunction
