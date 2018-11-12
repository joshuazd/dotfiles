function! functions#TrimWhiteSpace() abort
  if !&binary && &filetype !=? 'diff'
    let l:save = winsaveview()
    " vint: -ProhibitCommandRelyOnUser -ProhibitCommandWithUnintendedSideEffect
    keeppatterns %s/\s\+$//e
    " vint: +ProhibitCommandRelyOnUser +ProhibitCommandWithUnintendedSideEffect
    call winrestview(l:save)
  endif
endfunction

function! functions#VimRefresh() abort
  if exists('g:loaded_gutentags') && g:loaded_gutentags == 1
    GutentagsUpdate!
  endif
  redraw!
  syntax sync fromstart
  echo 'Vim is refreshed'
endfunction

function! functions#AnsibleEdit() abort
  silent! new
  silent! put! a
  silent! keeppatterns %s/^\s\+//
  silent! execute 'write!' fnameescape(tempname())
  silent! !cp % temp
  silent! !ansible-vault view temp >| %
  silent! !rm temp
  silent! redraw!
  echo 'Ansible vault decrypted'
endfunction

function! functions#AnsibleEncrypt() abort
  silent! set buftype=
  silent! execute 'write!' fnameescape(tempname())
  silent! !ansible-vault encrypt %
  silent! redraw!
  echo 'Ansible vault encrypted'
endfunction

function! functions#MyFoldText() abort
  let line = getline(v:foldstart)
  if match(line, '^[ \t]*\(\/\*\|\/\/\)[*/\\]*[ \t]*$') == 0
    let initial = substitute(line, '^\([ \t]\)*\(\/\*\|\/\/\)\(.*\)', '\1\2', '')
    let linenum = v:foldstart + 1
    while linenum < v:foldend
      let line = getline(linenum)
      let comment_content = substitute( line, '^\([ \t\/\*]*\)\(.*\)$', '\2', 'g' )
      if comment_content !=# ''
        break
      endif
      let linenum = linenum + 1
    endwhile
    let sub = initial . ' ' . comment_content
  else
    let sub = line
    let startbrace = substitute(line, '^.*{[ \t]*$', '{', 'g')
    if startbrace ==# '{'
      let line = getline(v:foldend)
      let endbrace = substitute(line, '^[ \t]*}\(.*\)$', '}', 'g')
      if endbrace ==# '}'
        let sub = sub.substitute(line, '^[ \t]*}\(.*\)$', '...}\1', 'g')
      endif
    endif
  endif
  let n = v:foldend - v:foldstart + 1
  let info = ' ' . n . ' lines  + ───'
  let filltext = '                                             '
  let filltext .= filltext
  let filltext .= filltext
  let filltext .= filltext
  let sub .= ' ' . filltext
  let num_w = getwinvar(0, '&number' ) * getwinvar( 0, '&numberwidth')
  let fold_w = getwinvar(0, '&foldcolumn')
  let sub = strpart(sub, 0, winwidth(0) - strchars(info) - num_w - fold_w)
  return sub . info
endfunction

function! functions#PutOperator(...) abort
  if !a:0
    return ":set opfunc=functions#PutOperator\<cr>\"" . v:register . 'g@'
  else
    let visual = get({'line': 'V', 'block': "\<c-v>"}, a:1, 'v')
    let [rv, rt] = [getreg(v:register), getregtype(v:register)]
    execute 'normal! g`[' . visual . 'g`]"' . v:register . 'p'
    call setreg(v:register, rv, rt)
  endif
endfunction

function! functions#Focus() abort
  if exists('g:focus_enabled') && g:focus_enabled == 1
    let &laststatus = g:old_laststatus
    set noshowmode
    if executable('tmux') && $TMUX !=? ''
      silent! !tmux resize-pane -Z
      silent! !tmux set status on
    endif
    let g:focus_enabled = 0
  else
    let g:focus_enabled = 1
    let g:old_laststatus = &laststatus
    set laststatus=0
    set showmode
    if executable('tmux') && $TMUX !=? ''
      silent! !tmux resize-pane -Z
      silent! !tmux set status off
    endif
  endif
endfunction

function! functions#LC_maps() abort
  if has_key(g:LanguageClient_serverCommands, &filetype)
    nnoremap <buffer> <silent> K :call LanguageClient#textDocument_hover()<cr>
    nnoremap <buffer> <silent> gd :call LanguageClient#textDocument_definition()<CR>
    nnoremap <buffer> <silent> <F2> :call LanguageClient#textDocument_rename()<CR>
    nnoremap <buffer> <silent> ga :call LanguageClient#textDocument_codeAction()<CR>
    nnoremap <buffer> <silent> gr :call LanguageClient#textDocument_references()<CR>
    nnoremap <buffer> <silent> gs :call LanguageClient#textDocument_documentSymbol()<CR>
    setlocal formatexpr=LanguageClient#textDocument_rangeFormatting_sync()
    setl signcolumn=yes
  endif
endfunction

function! functions#findFuncDefs() abort
  let g:findfunc = {'vim'   : ['^\s*fun\%[ction]', '^\s*endf\%[unction]',  '^\s*fun\%[ction]!\?\s\+\zs[a-z][[:alnum:]#_]*\ze('],
        \'xml'   : ['^\s*<resource', '<\/resource>', '\%(ur[il]-\(mapping\|template\)="\)\@<=[^"]*"\@='],
        \'python': ['^\s*\(class\|def\|async def\)\>', '\S\n\=\zs\n*\(^\s*\(class\|def\|async def\)\|^\S\)', '^\s*\(class\|def\|async def\)\s\+\zs\h\w*\ze('],
        \'java'  : ['^\(\t\| \{' . &shiftwidth . '}\)\S\+.*\(\n^.*\)\={', '^\(\t\| \{' . &shiftwidth . '}\)}', '\h\w*\ze(']}
endfunction
