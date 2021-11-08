nnoremap <buffer> { ?^@@<CR>
nnoremap <buffer> } /^@@<CR>
xnoremap <buffer> gm :s/<C-v><C-[>\[.*<C-v><C-[>\[m //<CR>
nnoremap <buffer> <space>c <esc>:read .plugin-update<CR>'[v']:s/<C-v><C-[>\[.*<C-v><C-[>\[m //<CR>
setlocal iskeyword+=-
setlocal spell
let b:undo_ftplugin = 'setlocal iskeyword< spell<'
