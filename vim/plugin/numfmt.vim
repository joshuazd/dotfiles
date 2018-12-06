if exists('g:loaded_numfmt')
  finish
endif
let g:loaded_numfmt = 1

let s:save_cpo = &cpo
set cpo&vim

nnoremap <silent> <Plug>(NumFmt) :<C-u>let isk=&l:isk\|setl isk+=,<CR>mn"nyiw:call numfmt#convertNum('<C-r>n')<CR>viw"np`n:<C-u>setl isk=<C-r>=isk<CR>\|silent! call repeat#set("\<lt>Plug>(NumFmt)", v:count)<CR>
xnoremap <silent> <Plug>(NumFmt) mn"ny:call numfmt#convertNum('<C-r>n')<CR>gv"np`ngv
nmap <Space>, <Plug>(NumFmt)
xmap <Space>, <Plug>(NumFmt)

let &cpo = s:save_cpo
unlet s:save_cpo
