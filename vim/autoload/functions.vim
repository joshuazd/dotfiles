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
  let info = ' ' . n . ' lines  + ---'
  let filltext = '                                             '
  let filltext .= filltext
  let filltext .= filltext
  let filltext .= filltext
  let sub .= ' ' . filltext
  let num_w = getwinvar(0, '&number' ) * getwinvar( 0, '&numberwidth')
  let fold_w = getwinvar(0, '&foldcolumn')
  let sub = strpart(sub, 0, winwidth(0) - strlen(info) - num_w - fold_w)
  return sub . info
endfunction

function! functions#PasteOp(type, ...) abort
  let l:mode = 'v'
  if a:type ==? 'line'
    let l:mode = 'V'
  elseif a:type ==? 'block'
    let l:mode = ''
  endif
  execute 'normal! g`[' . l:mode . 'gg`]p'
  let @+=@0
  let @"=@0
  let @*=@0
endfunction

function! functions#Focus() abort
  if exists('g:focus_enabled') && g:focus_enabled == 1
    let &laststatus = g:old_laststatus
    set noshowmode
    silent! !tmux resize-pane -Z
    silent! !tmux set status on
    let g:focus_enabled = 0
  else
    let g:focus_enabled = 1
    let g:old_laststatus = &laststatus
    set laststatus=0
    set showmode
    silent! !tmux resize-pane -Z
    silent! !tmux set status off
  endif
endfunction
