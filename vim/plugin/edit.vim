command! -complete=file_in_path -nargs=? E call edit#open(<q-args>)

nnoremap <Space>a :E **/*
nnoremap <Space>f :E<space>
nnoremap <Space>e :E <C-r>=fnameescape(expand('%:p:h'))<CR>/<C-d>
