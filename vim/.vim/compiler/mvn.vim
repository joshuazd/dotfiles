if exists('current_compiler')
  finish
endif
let current_compiler = 'maven'

if exists(':CompilerSet') != 2
  command -nargs=* CompilerSet setlocal <args>
endif

let s:cpo_save = &cpo
set cpo&vim

CompilerSet makeprg=mvn

" Ignored message
CompilerSet errorformat=
	\%-G[INFO]\ %.%#,
	\%-G[debug]\ %.%#

" Error message for POM
CompilerSet errorformat+=
	\[FATAL]\ Non-parseable\ POM\ %f:\ %m%\\s%\\+@%.%#line\ %l\\,\ column\ %c%.%#,
	\[%tRROR]\ Malformed\ POM\ %f:\ %m%\\s%\\+@%.%#line\ %l\\,\ column\ %c%.%#

" Error message for compiling
CompilerSet errorformat+=
	\[%tARNING]\ %f:[%l\\,%c]\ %m,
	\[%tRROR]\ %f:[%l\\,%c]\ %m

" Message from JUnit 5(5.3.X), TestNG(6.14.X), JMockit(1.43), and AssertJ(3.11.X)
CompilerSet errorformat+=
	\%+E%>[ERROR]\ %.%\\+Time\ elapsed:%.%\\+<<<\ FAILURE!,
	\%+E%>[ERROR]\ %.%\\+Time\ elapsed:%.%\\+<<<\ ERROR!,
	\%+Z%\\s%#at\ %f(%\\f%\\+:%l),
	\%+C%.%#

let &cpo = s:cpo_save
unlet s:cpo_save
