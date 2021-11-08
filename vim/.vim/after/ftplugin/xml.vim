setlocal foldmethod=indent
setlocal smarttab
setlocal conceallevel=0
setlocal foldnestmax=2
setlocal foldlevel=1
setlocal iskeyword+=-
setlocal expandtab
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
if &l:statusline !~# '\V%{findfunc#FindFunc()}\$'
  setlocal statusline+=%{findfunc#FindFunc()}
endif

inoremap <buffer> <expr> / getline('.')[col('.')-2] ==# '<' ? "/\<C-x>\<C-o>\<C-n>\<C-y>\<C-f>" : "/"

nnoremap <silent> <buffer> [m :call search('<resource','Wb')<CR>
nnoremap <silent> <buffer> ]m :call search('<resource','W')<CR>
xnoremap <silent> <buffer> [m :<C-u>execute "normal! gv"\|call search('<resource','Wb')<CR>
xnoremap <silent> <buffer> ]m :<C-u>execute "normal! gv"\|call search('<resource','W')<CR>
onoremap <silent> <buffer> [m :call search('<resource','Wb')<CR>
onoremap <silent> <buffer> ]m :call search('<resource','W')<CR>

nnoremap <silent> <buffer> [M :call search('<\/resource','Wb')<CR>
nnoremap <silent> <buffer> ]M :call search('<\/resource','W')<CR>
xnoremap <silent> <buffer> [M :<C-u>execute "normal! gv"\|call search('<\/resource','Wb')<CR>
xnoremap <silent> <buffer> ]M :<C-u>execute "normal! gv"\|call search('<\/resource','W')<CR>
onoremap <silent> <buffer> [M :call search('<\/resource','Wb')<CR>
onoremap <silent> <buffer> ]M :call search('<\/resource','W')<CR>

nnoremap <buffer> [[ vatato<Esc>^
nnoremap <buffer> ]] vatat<Esc>^

setlocal omnifunc=xml#complete#CompleteTags
compiler xmllint
setlocal makeprg=xmllint\ --noout\ %:S
setlocal formatprg=xmllint\ --format\ -
setlocal syntax=xml
setlocal path=.,,*/src/main/synapse-config,*/src/main/dataservice/,*_DataMapper/,*/dataservice/,*/src/main/synapse-config/*
set suffixesadd+=.xml,.dbs
setlocal isfname-=/
setlocal include=\\%(target\\\|key\\\|messageStore\\)=
setlocal define=\\%(name\\)=
nnoremap <buffer> cx :set operatorfunc=xml#escape#escape<CR>g@
xnoremap <buffer> X :<C-u>call xml#escape#escape()<CR>

command! -bar -buffer -nargs=* Maven :Dispatch mvn <args>
command! -bar -buffer -nargs=* Install :Maven clean install <args>
command! -bar -buffer -nargs=* Version :Maven versions:set -DnewVersion=<args>
command! -bar -buffer -nargs=* Deploy :Dispatch mcar

nnoremap <buffer> <space>I :<C-u>Install<space>
nnoremap <buffer> <space>V :<C-u>Version<space>

let b:undo_ftplugin = 'setlocal foldmethod< smarttab< conceallevel< foldnestmax< iskeyword< expandtab< tabstop< shiftwidth< softtabstop< omnifunc< makeprg< formatprg< syntax< path< suffixesadd< isfname< include<'

augroup XML
  autocmd!
  if executable('xmllint')
    autocmd BufWritePost <buffer> silent! make|cwindow|redraw!
  endif
  if exists(':UltiSnipsAddFiletypes')
    autocmd BufEnter pom.xml,artifact.xml UltiSnipsAddFiletypes pom.xml
  endif
  autocmd BufEnter */api/*.xml XMLns api
  autocmd BufEnter */sequences/*.xml XMLns sequence
  autocmd BufEnter */templates/*.xml XMLns template
  autocmd BufEnter */endpoints/*.xml XMLns endpoint
  autocmd BufEnter */local-entries/*.xml execute('XMLns xsl xsl') | XMLns localEntry
  autocmd BufEnter */proxy-services/*.xml XMLns proxyservice
augroup END

" let b:endwise_addition = '\="</".submatch(0)[1:stridx(submatch(0)," ")-1].">"'
" let b:endwise_words = ''
" let b:endwise_pattern = '<\%([^ /!?"''<>][^>]*\)\?[^/>]>\s*$'
" let b:endwise_syngroups = 'xmlTag,xmlTagPunct'

let b:textobj_declaration_char = '\S'

let g:xmldata_none = {}

let b:xmldata_endpoint = {
      \ 'endpoint': [
      \ ['http', 'address'],
      \ {'key': []}
      \ ],
      \ 'http': [
      \ [],
      \ {'method': ['get', 'post', 'put', 'delete', 'path'], 'uri-template': []}
      \ ],
      \ 'address': [
      \ ['enableSec'],
      \ {'uri': [], 'format': ['soap11', 'soap10', 'pox']}
      \ ],
      \ 'enableSec': [
      \ [],
      \ {'policy': ['UTPasswordPolicy']}
      \ ]
      \ }
let b:xml_mediator_names = ['property', 'call-template', 'filter', 'payloadFactory', 'respond', 'store', 'send', 'call', 'log', 'sequence', 'enrich', 'xslt', 'script', 'class', 'header', 'dbreport', 'dblookup', 'datamapper', 'loopback']
let b:xmldata_mediators = {
      \ 'property': [
      \ [],
      \ {'name': [], 'value': [], 'expression': [], 'scope': ['default', 'axis2', 'transport'], 'type': ['STRING', 'BOOLEAN', 'NUMBER']}
      \ ],
      \ 'call-template': [
      \ ['with-param'],
      \ {'target': []}
      \ ],
      \ 'with-param': [
      \ [],
      \ {'name': ['message'], 'value': []}
      \ ],
      \ 'filter': [
      \ ['then', 'else'],
      \ {'xpath': [], 'source': [], 'regex': []}
      \ ],
      \ 'then': [
      \ b:xml_mediator_names,
      \ {}
      \ ],
      \ 'else': [
      \ b:xml_mediator_names,
      \ {}
      \ ],
      \ 'sequence': [
      \ [],
      \ {'key': []}
      \ ],
      \ 'enrich': [
      \ ['source', 'target'],
      \ {}
      \ ],
      \ 'source': [
      \ [],
      \ {'clone': ['false', 'true'], 'property': [], 'type': ['body', 'property']}
      \ ],
      \ 'target': [
      \ [],
      \ {'property': [], 'type': ['body', 'property']}
      \ ],
      \ 'payloadFactory': [
      \ ['format', 'args'],
      \ {'media-type': ['xml', 'json']}
      \ ],
      \ 'args': [
      \ ['arg'],
      \ {}
      \ ],
      \ 'arg': [
      \ [],
      \ {'expression': [], 'evaluator': ['xml', 'json']}
      \ ],
      \ 'store': [
      \ [],
      \ {'messageStore': []}
      \ ],
      \ 'log': [
      \ ['property'],
      \ {'level': ['custom', 'full', 'simple']}
      \ ],
      \ 'send': [
      \ ['endpoint'],
      \ {}
      \ ],
      \ 'call': [
      \ ['endpoint'],
      \ {}
      \ ],
      \ 'xslt': [
      \ ['property'],
      \ {'key': []}
      \ ],
      \ 'class': [],
      \ 'header': [
      \ [],
      \ {'name': [], 'scope': ['transport'], 'value': []}
      \ ],
      \ 'dbreport': [
      \ ['connection', 'statement'],
      \ {}
      \ ],
      \ 'dblookup': [
      \ ['connection', 'statement'],
      \ {}
      \ ],
      \ 'connection': [
      \ ['pool'],
      \ {}
      \ ],
      \ 'pool': [
      \ ['dsName'],
      \ {}
      \ ],
      \ 'statement': [
      \ ['sql', 'parameter', 'result'],
      \ {}
      \ ],
      \ 'parameter': [
      \ [],
      \ {'expression': [], 'type': ['VARCHAR']}
      \ ],
      \ 'result': [
      \ [],
      \ {'name': [], 'column': []}
      \ ],
      \ 'script': [
      \ [],
      \ {'language': ['groovy', 'js']}
      \ ],
      \ 'switch': [
      \ ['case'],
      \ {'source': []}
      \ ],
      \ 'case': [
      \ b:xml_mediator_names,
      \ {'regex': []}
      \ ],
      \ 'datamapper': [
      \ [],
      \ {'config': [], 'inputSchema': [], 'inputType': ['JSON', 'XML'], 'outputSchema': [], 'outputType': ['JSON', 'XML']}
      \ ],
      \ 'vimxmltaginfo': {
      \ 'property': ['/>', ''],
      \ 'respond': ['/>', ''],
      \ 'with-param': ['/>', ''],
      \ 'store': ['/>', ''],
      \ 'loopback': ['/>', '']
      \ }
      \ }
let b:xmldata_mediators = extend(b:xmldata_mediators, b:xmldata_endpoint)
