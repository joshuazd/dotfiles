if exists('b:current_syntax')
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

let s:todo_words = get(g:, 'todo_words', [['TODO','|','DONE']])
let s:todo_todo_words = []
let s:todo_done_words = []
for list in s:todo_words
  let break = index(list, '|')
  let words = list[0:break-1]
  let s:todo_todo_words += words
  let words = list[break+1:]
  let s:todo_done_words += words
endfor
execute 'syn keyword todoTODOwords contained ' . join(s:todo_todo_words, ' ')
execute 'syn keyword todoDONEwords contained ' . join(s:todo_done_words, ' ')

syn cluster todoWords contains=todoTODOwords,todoDONEwords

syn match todoDate "<\w\{3}\s\w\{3}\s\d\{1,2}>" contained
syn match todoDate "<\d\{4}[\./-]\d\{1,2}[\./-]\d\{1,2}>" contained

syn match todoBox "\s*\[\d*\/\d*\]" contained

syn match todoListMarker "[-+*]" contained
execute 'syn match todoTODOlist ''\v('.join(s:todo_todo_words, '|').')\s+.*'' contains=@todoWords'
execute 'syn match todoDONElist ''\v('.join(s:todo_done_words, '|').')\s+.*'' contains=@todoWords'
syn match todoList "[-+*]\s\+.*" contains=todoListMarker,todoTODOlist,todoDONElist,todoDate,todoBox

syn match todoHeaderMarker ":" conceal contained
syn match todoHeader "^\S.*" contains=todoBox
syn match todoSubHeader "\s\+\zs:.*" contains=todoHeaderMarker,todoBox

hi def link todoTODOwords Todo
hi def link todoDONEwords Question
hi def link todoListMarker Keyword
hi def link todoHeader Normal
hi def link todoSubHeader Constant
hi def link todoDate PreProc
hi def link todoBox Statement
function! s:hi(group, target, attr) abort
  let target_id = synIDtrans(hlID(a:target))
  let t_fg = synIDattr(target_id, 'fg', 'cterm')
  let t_bg = synIDattr(target_id, 'bg', 'cterm')
  let g_fg = synIDattr(target_id, 'fg', 'gui')
  let g_bg = synIDattr(target_id, 'bg', 'gui')
  let Syn = {x -> len(x) ? x : 'NONE'}
  execute 'highlight '.a:group.' ctermfg='.Syn(t_fg).' ctermbg='.Syn(t_bg).
        \' guifg='.Syn(g_fg).' guibg='.Syn(g_bg).
        \' cterm='.a:attr.' gui='.a:attr
endfunction
function! s:hilight() abort
  hi todoHeader cterm=reverse gui=reverse
  call s:hi('todoBox', 'Statement', 'bold')
  call s:hi('todoDONEwords', 'Question', 'strikethrough')
  call s:hi('todoDONElist', 'Comment', 'strikethrough')
endfunction
call s:hilight()
augroup todo_syntax
  autocmd!
  autocmd ColorScheme * call s:hilight()
augroup END

let b:current_syntax = 'todo'

let &cpo = s:cpo_save
unlet s:cpo_save
