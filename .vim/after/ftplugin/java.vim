compiler ant
setlocal makeprg=mvn\ install\ -e\ -ff
setlocal path=.,src/main/java/com/panera/,src/main/java/
setlocal foldmarker={,}
setlocal define=\\s*\\%(\\%(public\\\|private\\\|protected\\\|static\\\|abstract\\\|final\\)\\s*\\)\\+\\%(void\\\|int\\\|short\\\|long\\\|byte\\\|float\\\|double\\\|char\\\|boolean\\\|[A-Z][a-zA-Z0-9_\\.]*\\%(<.*>\\)\\=\\)\\s*
setlocal include=^\\s*import\\s*\\%(static\\)\\=\\s*
setlocal complete-=i
if executable('java-language-server') && exists(':Packadd')
  Packadd vim-lsc
endif
let b:undo_ftplugin = 'setlocal makeprg< path< foldmarker< define< include< complete<'
