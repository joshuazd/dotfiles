" quit when a syntax file was already loaded
if exists('b:current_syntax')
  finish
endif

" syn match editorconfigError +.\++
syn match editorconfigOptionError +\k\++ contained

syn match  editorconfigNumber   "\<\d\+\>" contained display
syn match  editorconfigNumber   "\<\d*\.\d\+\>" contained display
syn match  editorconfigNumber   "\<\d\+e[+-]\=\d\+\>" contained display

syn match editorconfigProperties +\.\w*vimrc\w*+ contained
syn iskeyword @,48-57,192-255,&,_,-,.
syn keyword editorconfigConstant false true contained
syn keyword editorconfigProperties tab space lf crlf cr latin1 contained
syn keyword editorconfigProperties off single double contained
syn keyword editorconfigProperties auto hybrid none inside outside both contained
syn keyword editorconfigProperties utf-8 utf-16be utf-16le contained
syn keyword editorconfigProperties K&R Allman GNU Horstmann contained

syn match  editorconfigLabel    "^\k\+" contains=editorconfigOptions,editorconfigOptionError nextgroup=editorconfigAssignment display
syn match  editorconfigAssignment " = " nextgroup=editorconfigValue display
syn region editorconfigHeader   start="^\s*\[" end="\]" display
syn match  editorconfigComment  "^[#;].*$" display

syn match editorconfigValue "\k\+" contained contains=editorconfigNumber,editorconfigConstant,editorconfigProperties,editorconfigOptionError display

syn keyword editorconfigOptions indent_style indent_size tab_width end_of_line charset contained
syn keyword editorconfigOptions trim_trailing_whitespace insert_final_newline contained
syn keyword editorconfigOptions max_line_length root c_include_path local_vimrc contained
syn keyword editorconfigOptions spell_enabled spell_language quote_type contained
syn keyword editorconfigOptions java_class_path curly_bracket_next_line contained
syn keyword editorconfigOptions spaces_around_operators spaces_around_brackets contained
syn keyword editorconfigOptions indent_brace_style wildcard_import_limit contained
syn keyword editorconfigOptions continuation_indent_size block_comment line_comment contained
syn keyword editorconfigOptions block_comment_start block_comment_end contained


" Only when an item doesn't have highlighting yet

hi def link editorconfigNumber          Number
hi def link editorconfigConstant        Constant
hi def link editorconfigHeader          Special
hi def link editorconfigProperties      Keyword
hi def link editorconfigComment         Comment
hi def link editorconfigAssignment      Operator
hi def link editorconfigOptions         Type
hi def link editorconfigOptionError     Error
hi def link editorconfigError           Error

let b:current_syntax = 'editorconfig'
