syn include @jinja syntax/jinja.vim
syn region yamlBlockString start=/^\z(\s\+\)/ skip=/^$/ end=/^\%(\z1\)\@!/ contained contains=@jinja

hi! def link yamlMappingKey Special
hi def link yamlBlockString String
hi! def link yamlBlockScalarHeader Keyword
