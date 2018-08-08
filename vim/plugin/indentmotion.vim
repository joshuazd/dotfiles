onoremap <silent>ai :<C-u>call indentmotion#indentTextObj(0)<CR>
onoremap <silent>ii :<C-u>call indentmotion#indentTextObj(1)<CR>
xnoremap <silent>ai <Esc>:call indentmotion#indentTextObj(0)<CR><Esc>gv
xnoremap <silent>ii <Esc>:call indentmotion#indentTextObj(1)<CR><Esc>gv

nnoremap <silent> ,j :<C-u>call indentmotion#findSameIndent(v:count1, 'j', 0, 0)<CR>
nnoremap <silent> ,k :<C-u>call indentmotion#findSameIndent(v:count1, 'k', 0, 0)<CR>
xnoremap <silent> ,j <Esc>:call indentmotion#findSameIndent(v:count1, 'j', 1, 0)<CR><Esc>gv
xnoremap <silent> ,k <Esc>:call indentmotion#findSameIndent(v:count1, 'k', 1, 0)<CR><Esc>gv
onoremap <silent> ,j :<C-u>call indentmotion#findSameIndent(v:count1, 'j', 0, 1)<CR>
onoremap <silent> ,k :<C-u>call indentmotion#findSameIndent(v:count1, 'k', 0, 1)<CR>

onoremap <silent> iI :<C-u>call indentmotion#blockTextObj()<CR>
xnoremap <silent> iI <Esc>:call indentmotion#blockTextObj()<CR><Esc>gv
