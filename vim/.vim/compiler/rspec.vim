
if exists("current_compiler")
  finish
endif
let current_compiler = "rspec"

let s:cpo_save = &cpo
set cpo-=C

CompilerSet makeprg=rspec

CompilerSet errorformat=
    \%f:%l:%m

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: nowrap sw=2 sts=2 ts=8:

