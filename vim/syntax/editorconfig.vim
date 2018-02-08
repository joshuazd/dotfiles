" quit when a syntax file was already loaded
if exists('b:current_syntax')
  finish
endif


syn match  editorconfigNumber   "\<\d\+\>"
syn match  editorconfigNumber   "\<\d*\.\d\+\>"
syn match  editorconfigNumber   "\<\d\+e[+-]\=\d\+\>"


syn match  editorconfigLabel    "^.\{-}=" contains=editorconfigOptions,editorconfigOptionError
syn region editorconfigHeader   start="^\s*\[" end="\]"
syn match  editorconfigComment  "^[#;].*$"


syn match editorconfigOptionError +\k\++ contained

syn keyword editorconfigOptions indent_style indent_size tab_width end_of_line charset contained
syn keyword editorconfigOptions trim_trailing_whitespace insert_final_newline contained
syn keyword editorconfigOptions max_line_length root c_include_path local_vimrc contained
syn keyword editorconfigOptions spell_enabled spell_language



" Define the default highlighting.
" Only when an item doesn't have highlighting yet

hi def link editorconfigNumber          Number
hi def link editorconfigHeader          Special
hi def link editorconfigComment         Comment
hi def link editorconfigOptions         Type
hi def link editorconfigOptionError     Error


let b:current_syntax = 'editorconfig'
