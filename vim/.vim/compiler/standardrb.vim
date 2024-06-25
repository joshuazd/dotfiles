" Vim compiler file

if exists('current_compiler')
  finish
endif

let current_compiler = 'standardrb'

CompilerSet errorformat=%f:%l:%c:\ %t:\ %m
CompilerSet makeprg=bundle\ exec\ standardrb\ --no-fix\ --format\ emacs\ --no-color\ %:S
