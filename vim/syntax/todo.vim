if exists('b:current_syntax')
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

if exists('g:todo_words')
  for list in g:todo_words
    let break = index(list, '|')
    let words = list[0:break-1]
    execute 'syn keyword todoTODOwords contained ' . join(words, ' ')
    let words = list[break+1:]
    execute 'syn keyword todoDONEwords contained ' . join(words, ' ')
  endfor
else
  syn keyword todoTODOwords contained TODO
  syn keyword todoDONEwords contained DONE
endif

syn cluster todoWords contains=todoTODOwords,todoDONEwords

syn match todoListMarker "[-+*]" contained
syn match todoList "[-+*]\s\+.*" contains=todoListMarker,@todoWords

syn match todoHeaderMarker ":" conceal contained
syn match todoHeader "^.\S.*"
syn match todoSubHeader "\s\+\zs:.*" contains=todoHeaderMarker

hi def link todoTODOwords Todo
hi def link todoDONEwords Question
hi def link todoListMarker Keyword
hi def link todoHeader String
hi def link todoSubHeader Constant

let b:current_syntax = 'todo'

let &cpo = s:cpo_save
unlet s:cpo_save
