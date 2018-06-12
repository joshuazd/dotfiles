onoremap <silent>ai :<C-u>call indentmotion#indentTextObj(0)<CR>
onoremap <silent>ii :<C-u>call indentmotion#indentTextObj(1)<CR>
xnoremap <silent>ai <Esc>:call indentmotion#indentTextObj(0)<CR><Esc>gv
xnoremap <silent>ii <Esc>:call indentmotion#indentTextObj(1)<CR><Esc>gv

nnoremap ,j :<C-u>call indentmotion#findSameIndent(v:count1, 'j', 0, 0)<CR>
nnoremap ,k :<C-u>call indentmotion#findSameIndent(v:count1, 'k', 0, 0)<CR>
xnoremap ,j <Esc>:call indentmotion#findSameIndent(v:count1, 'j', 1, 0)<CR><Esc>gv
xnoremap ,k <Esc>:call indentmotion#findSameIndent(v:count1, 'k', 1, 0)<CR><Esc>gv
onoremap ,j :<C-u>call indentmotion#findSameIndent(v:count1, 'j', 0, 1)<CR>
onoremap ,k :<C-u>call indentmotion#findSameIndent(v:count1, 'k', 0, 1)<CR>
