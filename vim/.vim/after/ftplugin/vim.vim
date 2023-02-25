setlocal shiftwidth=2
setlocal softtabstop=2
setlocal foldmethod=marker
setlocal makeprg=vint\ %:S
setlocal keywordprg=:help
setlocal errorformat=%f:%l:%c:\ %t%n:\ %m,%f:%l:%c:\ %m
setlocal path=$HOME/.vim/,,.
setlocal suffixesadd+=.vim
setlocal tags+=$VIMRUNTIME/tags

" Move around functions.
nnoremap <silent><buffer> [m m':call search('^\s*fu\%[nction]\>', "bW")<CR>
xnoremap <silent><buffer> [m m':<C-U>exe "normal! gv"<Bar>call search('^\s*fu\%[nction]\>', "bW")<CR>
nnoremap <silent><buffer> ]m m':call search('^\s*fu\%[nction]\>', "W")<CR>
xnoremap <silent><buffer> ]m m':<C-U>exe "normal! gv"<Bar>call search('^\s*fu\%[nction]\>', "W")<CR>
nnoremap <silent><buffer> [M m':call search('^\s*endf*\%[unction]\>', "bW")<CR>
xnoremap <silent><buffer> [M m':<C-U>exe "normal! gv"<Bar>call search('^\s*endf*\%[unction]\>', "bW")<CR>
nnoremap <silent><buffer> ]M m':call search('^\s*endf*\%[unction]\>', "W")<CR>
xnoremap <silent><buffer> ]M m':<C-U>exe "normal! gv"<Bar>call search('^\s*endf*\%[unction]\>', "W")<CR>

nnoremap <buffer> g== :<C-u><C-r>=trim(getline('.'))<CR><CR>
nnoremap <buffer> g: :<C-u><C-r>=trim(getline('.'))<CR>
nnoremap <silent> <buffer> g= :set opfunc=<SID>evaluate<CR>g@
xnoremap <silent> <buffer> g= :call <SID>evaluate(visualmode(), getline('.'))<CR>

let b:ale_linters = ['vint']

function! s:evaluate(type, ...) abort
  if a:0
    exe trim(a:1)
  else
    for lnum in range(line("'["), line("']"))
      execute trim(getline(lnum))
    endfor
  endif
endfunction

augroup vimscript
  autocmd!
  " if executable('vint')
  "   if exists('g:loaded_dispatch')
  "     autocmd BufWritePost <buffer> execute 'Make'|cwindow|redraw!
  "   else
  "     autocmd BufWritePost <buffer> silent! make|cwindow|redraw!
  "   endif
  " endif
augroup END

let b:undo_ftplugin = 'setlocal shiftwidth< softtabstop< foldmethod< makeprg< keywordprg< errorformat< path< suffixesadd<'
