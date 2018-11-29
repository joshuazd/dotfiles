" hilinks.vim: the source herein generates a trace of what
"              highlighting groups link to what highlighting groups
"
"  Author:    Charles E. Campbell, Jr. <NdrOchipS@PcampbellAfamily.Mbiz>
"  Date:    Feb 23, 2009
"  Version:    4j  ASTRO-ONLY
"
"  NOTE:        This script requires Vim 6.0 (or later)
"               Works best with Vim 7.1 with patch#215
"
"  Usage: {{{1
"
"  \hlt   : will reveal a linked list of highlighting from the top-level down
"           to the bottom level.
"           You may redefine the leading character using "let mapleader= ..."
"           in your <.vimrc>.
"
"  History: {{{1
"   3 04/07/05 :  * cpo&vim supported
"   2 07/14/04 :  * register a is used as before but now its original contents are restored
"           * bugfix: redraw taken before echo to fix message display
"           * debugging code installed
"    1 08/01/01 :  * the first release
" ---------------------------------------------------------------------
"  Load Once: {{{1
if exists('g:loaded_hilinks') || &cp
  finish
endif
let g:loaded_hilinks= '1'
if v:version < 700
  finish
endif
let s:keepcpo= &cpo
set cpo&vim

" ---------------------------------------------------------------------
"  Initialization: {{{1
let s:HLTmode       = 0

" ---------------------------------------------------------------------
" Public Interface: {{{1
noremap <script> <Plug>HiLinkTrace :call hilinktrace#HiLinkTrace(0)<CR>
command! -bang HLT call hilinktrace#HiLinkTrace(<bang>0)

" ---------------------------------------------------------------------
"  Options: {{{1
if !exists('g:hilinks_fmtwidth')
  let g:hilinks_fmtwidth= 35
endif

let &cpo= s:keepcpo
" ---------------------------------------------------------------------
" vim: fdm=marker

