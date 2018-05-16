compiler ant
setlocal makeprg=mvn\ install\ -e\ -ff\ -T\ 16\ -q
setlocal path=.,src/main/java/com/panera/*/,src/main/java/
setlocal foldmarker={,}
setlocal define=\\s*\\%(\\%(public\\\|private\\\|protected\\\|static\\\|abstract\\\|final\\)\\s*\\)\\+\\%(void\\\|int\\\|short\\\|long\\\|byte\\\|float\\\|double\\\|char\\\|boolean\\\|[A-Z][a-zA-Z0-9_\\.]*\\%(<.*>\\)\\=\\)\\s*
setlocal include=^\\s*import\\s*\\%(static\\)\\=\\s*
