" setlocal omnifunc=javacomplete#Complete
let g:ale_lint_on_text_changed = 'never'
set makeprg=mvn\ install
set path=.,src/main/java/com/panera/**/
" javacomplete setup {{{
  let g:JavaComplete_JavaviLogfileDirectory = '~/.javacomplete/servers'
  let g:JavaComplete_ClosingBrace = 1
" }}}
