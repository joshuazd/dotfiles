" To make this file do stuff, add something like the following (without the
" leading ") to your ~/.vimrc:
" au BufNewFile,BufRead *.yaml,*.yml so ~/src/PyYaml/YAML.vim

" Vim syntax/macro file
" Language:    YAML
" Author:    Igor Vergeichik <iverg@mail.ru>
" Sponsor: Tom Sawyer <transami@transami.net>
" Stayven: Ryan King <jking@panoptic.com>
" Copyright (c) 2002 Tom Saywer

" Add an item to a gangly list:
"map , o<bs><bs><bs><bs>-<esc>o
" Convert to Canonical form:
"map \c :%!python -c 'from yaml.redump import redump; import sys; print redump(sys.stdin.read()).rstrip()'

if exists('b:current_syntax')
    finish
endif

let s:cpo_save = &cpo
set cpo&vim

syn match yamlBlock "[\[\]\{\}\|\>]"

syn region yamlComment   start="\#" end="$"
syn match  yamlIndicator "#YAML:\S\+" display

syn region yamlString    start="\(^\|\s\|\[\|\,\|\-\)\zs'" end="'" skip="\\'"
syn region yamlString    start='"' end='"' skip='\\"' contains=yamlEscape
syn match  yamlEscape    +\\[abfnrtv'"\\]+ contained display
syn match  yamlEscape    "\\\o\o\=\o\=" contained display
syn match  yamlEscape    "\\x\x\+" contained display

syn match  yamlType    "!\S\+"

syn keyword yamlConstant NULL Null null NONE None none NIL Nil nil
syn keyword yamlConstant TRUE True true YES Yes yes
syn keyword yamlConstant FALSE False false NO No no

syn match yamlDelimiter ":" contained display

syn match  yamlKey    "^\s*\zs[^ \t\"]\+\ze\s*:" nextgroup=yamlDelimiter
syn match  yamlKey    "^\s*-\s*\zs[^ \t\"\']\+\ze\s*:" nextgroup=yamlDelimiter
syn match  yamlAnchor    "&\S\+" display
syn match  yamlAlias    "*\S\+" display

" Setup the highlighting links

hi def link yamlConstant  Keyword
hi def link yamlIndicator PreCondit
hi def link yamlDelimiter Delimiter
hi def link yamlAnchor    Function
hi def link yamlAlias     Function
hi def link yamlKey       Tag
hi def link yamlType      Type

hi def link yamlComment   Comment
hi def link yamlBlock     Delimiter
hi def link yamlString    String
hi def link yamlEscape    Special

let b:current_syntax = 'yaml'

let &cpo = s:cpo_save
unlet s:cpo_save
