nnoremap / /\v
nnoremap ? ?\v
for char in ['~', '`', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '-', '+', '=', '{', '}', '[', ']', ':', ';', "'", '<', '>', ',', '.', '?', '/']
  execute 'cnoremap <expr> ' . char . ' verymagic#verymagic("' . char . '")'
endfor
