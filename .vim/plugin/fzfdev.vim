if exists('g:loaded_fzfdev')
  finish
endif
let g:loaded_fzfdev = 1

let s:save_cpo = &cpo
set cpo&vim

function! s:webdev_symbols(files) abort
  let files = a:files
  let cache = {}
  for f in range(len(a:files))
    let fname = a:files[f]
    let ext = fname[0] ==# '.' ? fname : fnamemodify(fname, ':e')
    if !has_key(cache, ext)
      let cache[ext] = WebDevIconsGetFileTypeSymbol(fname)
    endif
    let a:files[f] = cache[ext]."\t".fname
  endfor
  return a:files
endfunction

function! s:echo(...) abort
  if len(a:1)
    for f in a:1
      if len(f)
        exe 'edit '.split(f)[-1]
      endif
    endfor
  endif
endfunction

let s:TYPE = {'dict': type({}), 'funcref': type(function('call')), 'string': type(''), 'list': type([])}
function! s:wrap(name, opts, bang)
  " fzf#wrap does not append --expect if sink or sink* is found
  let opts = copy(a:opts)
  let options = ''
  if has_key(opts, 'options')
    let options = type(opts.options) == s:TYPE.list ? join(opts.options) : opts.options
  endif
  if options !~ '--expect' && has_key(opts, 'sink*')
    let Sink = remove(opts, 'sink*')
    let wrapped = fzf#wrap(a:name, opts, a:bang)
    let wrapped['sink*'] = Sink
  else
    let wrapped = fzf#wrap(a:name, opts, a:bang)
  endif
  return wrapped
endfunction

let s:is_win = has('win32') || has('win64')
function! fzfdev#files(dir, bang, ...) abort
  let args = {}
  if !empty(a:dir)
    if !isdirectory(expand(a:dir))
      echohl WarningMsg
      echom 'Invalid directory'
      echohl None
      return
    endif
    let slash = (s:is_win && !&shellslash) ? '\\' : '/'
    let dir = substitute(a:dir, '[/\\]*$', slash, '')
    let args.dir = dir
  else
    let short = fnamemodify(getcwd(), ':~:.')
    if !has('win32unix')
      let short = pathshorten(short)
    endif
    let slash = (s:is_win && !&shellslash) ? '\' : '/'
    let dir = empty(short) ? '~'.slash : short . (short =~ escape(slash, '\').'$' ? '' : slash)
  endif

  exe 'cd '.dir
  let args.source = s:webdev_symbols(split(system($FZF_DEFAULT_COMMAND), '\n'))
  cd -
  let args['sink*'] = function('s:echo')
  let args.options = ['--tabstop=1']
  call fzf#run(s:wrap('files', args, a:bang))
endfunction

command! -nargs=* -complete=dir -bang DFiles call fzfdev#files(<q-args>, <bang>0)

let &cpo = s:save_cpo
unlet s:save_cpo
