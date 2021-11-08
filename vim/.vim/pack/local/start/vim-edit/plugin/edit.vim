if exists('g:loaded_edit')
  finish
endif
let g:loaded_edit = 1

" command! -complete=file_in_path -nargs=? E call edit#open(<q-args>)
