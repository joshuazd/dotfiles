function! pair#pair() abort
  let l:pair = get(g:, 'pair', v:false)
  if !l:pair
    bufdo setglobal number
    bufdo setglobal cursorline
    bufdo set number cursorline
    let g:pair = v:true
  else
    bufdo setglobal nonumber
    bufdo setglobal nocursorline
    bufdo set nonumber nocursorline
    let g:pair = v:false
  endif
endfunction
