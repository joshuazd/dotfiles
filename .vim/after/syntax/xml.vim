syn match callTemplate 'call-template'
syn match db 'dblookup\|dbreport'
syn match filter '\(filter\|then\|send\|else\|drop\|call\b\)'
syn keyword property property
syn match sequence '\(in\|out\|fault\)\?\(s\|S\)equence'
syn match param 'parameter\|result\|dsName\|target\|with-param'
syn match connection 'connection\|statement\|resource'

syn cluster xmlTagHook add=callTemplate,db,filter,property,sequence,connection,param

highlight param ctermfg=10
highlight connection ctermfg=13
highlight link property Constant
highlight sequence ctermfg=10
highlight link callTemplate Statement
highlight link db Function
highlight link filter Operator
highlight xmlAttrib ctermfg=7
