function! xml#complete#CompleteTags(findstart, base) abort
  if a:findstart
    " locate the start of the word
    let curline = line('.')
    let line = getline('.')
    let start = col('.') - 1
    let compl_begin = col('.') - 2

    while start >= 0 && line[start - 1] =~# '\(\k\|[:.-]\)'
      let start -= 1
    endwhile

    if start >= 0 && line[start - 1] =~# '&'
      let b:entitiescompl = 1
      let b:compl_context = ''
      return start
    endif

    let b:compl_context = getline('.')[0:(compl_begin)]
    if b:compl_context !~# '<[^>]*$'
      " Look like we may have broken tag. Check previous lines. Up to
      " 10?
      let i = 1
      while 1
        let context_line = getline(curline-i)
        if context_line =~# '<[^>]*$'
          " Yep, this is this line
          let context_lines = getline(curline-i, curline-1) + [b:compl_context]
          let b:compl_context = join(context_lines, ' ')
          break
        elseif context_line =~# '>[^<]*$' || i ==# curline
          " Normal tag line, no need for completion at all
          " OR reached first line without tag at all
          let b:compl_context = ''
          break
        endif
        let i += 1
      endwhile
      " Make sure we don't have counter
      unlet! i
    endif
    let b:compl_context = matchstr(b:compl_context, '.*\zs<.*')

    " Make sure we will have only current namespace
    unlet! b:xml_namespace
    let b:xml_namespace = matchstr(b:compl_context, '^<\zs\k*\ze:')
    if b:xml_namespace ==# ''
      let b:xml_namespace = 'DEFAULT'
    endif

    return start

  else
    " Initialize base return lists
    let res = []
    let res2 = []
    " a:base is very short - we need context
    if len(b:compl_context) == 0  && !exists('b:entitiescompl')
      return []
    endif
    let context = matchstr(b:compl_context, '^<\zs.*')
    unlet! b:compl_context
    " There is no connection of namespace and data file.
    if !exists('g:xmldata_connection') || g:xmldata_connection == {} || index(keys(g:xmldata_connection), b:xml_namespace) == -1
      " There is still possibility we may do something - eg. close tag
      " let b:unaryTagsStack = 'base meta link hr br param img area input col'
      let b:unaryTagsStack = ''
      if context =~# '^\/'
        let opentag = xmlcomplete#GetLastOpenTag('b:unaryTagsStack')
        return [opentag.'>']
      else
        return []
      endif
    endif

    " Make entities completion
    if exists('b:entitiescompl')
      unlet! b:entitiescompl

      if !exists('g:xmldata_entconnect') || g:xmldata_entconnect ==# 'DEFAULT'
        let values =  g:xmldata{'_'.g:xmldata_connection['DEFAULT']}['vimxmlentities']
      else
        let values =  g:xmldata{'_'.g:xmldata_entconnect}['vimxmlentities']
      endif

      " Get only lines with entity declarations but throw out
      " parameter-entities - they may be completed in future
      let entdecl = filter(getline(1, '$'), 'v:val =~# "<!ENTITY\\s\\+[^%]"')

      if len(entdecl) > 0
        let intent = map(copy(entdecl), 'matchstr(v:val, "<!ENTITY\\s\\+\\zs\\(\\k\\|[.-:]\\)\\+\\ze")')
        let values = intent + values
      endif

      if len(a:base) == 1
        for m in values
          if m =~ '^'.a:base
            call add(res, m.';')
          endif
        endfor
        return res
      else
        for m in values
          if m =~? '^'.a:base
            call add(res, m.';')
          elseif m =~? a:base
            call add(res2, m.';')
          endif
        endfor

        return res + res2
      endif

    endif
    if context =~# '>'
      " Generally if context contains > it means we are outside of tag and
      " should abandon action
      return []
    endif

    " find tags matching with "a:base"
    " If a:base contains white space it is attribute.
    " It could be also value of attribute...
    " We have to get first word to offer
    " proper completions
    if context ==# ''
      let tag = ''
    else
      let tag = split(context)[0]
    endif
    " Get rid of namespace
    let tag = substitute(tag, '^'.b:xml_namespace.':', '', '')


    " Get last word, it should be attr name
    let attr = matchstr(context, '.*\s\zs.*')
    " Possible situations where any prediction would be difficult:
    " 1. Events attributes
    if context =~# '\s'

      " If attr contains =\s*[\"'] we catched value of attribute
      if attr =~# "=\s*[\"']" || attr =~# '=\s*$'
        " Let do attribute specific completion
        let attrname = matchstr(attr, '.*\ze\s*=')
        let entered_value = matchstr(attr, ".*=\\s*[\"']\\?\\zs.*")

        if tag =~# '^[?!]'
          " Return nothing if we are inside of ! or ? tag
          return []
        else
          if has_key(g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}, tag) && has_key(g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}[tag][1], attrname)
            let values = g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}[tag][1][attrname]
          else
            return []
          endif
        endif

        if len(values) == 0
          return []
        endif

        " We need special version of sbase
        let attrbase = matchstr(context, ".*[\"']")
        let attrquote = matchstr(attrbase, '.$')
        if attrquote !~# "['\"]"
          let attrquoteopen = '"'
          let attrquote = '"'
        else
          let attrquoteopen = ''
        endif

        for m in values
          " This if is needed to not offer all completions as-is
          " alphabetically but sort them. Those beginning with entered
          " part will be as first choices
          if m =~ '^'.entered_value
            call add(res, attrquoteopen . m . attrquote.' ')
          elseif m =~ entered_value
            call add(res2, attrquoteopen . m . attrquote.' ')
          endif
        endfor

        return res + res2

      endif

      if tag =~# '?xml'
        " Two possible arguments for <?xml> plus variation
        let attrs = ['encoding', 'version="1.0"', 'version']
      elseif tag =~# '^!'
        " Don't make completion at all
        "
        return []
      else
        if !has_key(g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}, tag)
          " Abandon when data file isn't complete
          return []
        endif
        let attrs = keys(g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}[tag][1])
      endif

      for m in sort(attrs)
        if m =~ '^'.attr
          call add(res, m)
        elseif m =~ attr
          call add(res2, m)
        endif
      endfor
      let menu = res + res2
      let final_menu = []
      if has_key(g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}, 'vimxmlattrinfo')
        for i in range(len(menu))
          let item = menu[i]
          if has_key(g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}['vimxmlattrinfo'], item)
            let m_menu = g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}['vimxmlattrinfo'][item][0]
            let m_info = g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}['vimxmlattrinfo'][item][1]
          else
            let m_menu = ''
            let m_info = ''
          endif
          if tag !~# '^[?!]' && len(g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}[tag][1][item]) > 0 && g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}[tag][1][item][0] =~# '^\(BOOL\|'.item.'\)$'
            let item = item
          else
            let item .= '="'
          endif
          let final_menu += [{'word':item, 'menu':m_menu, 'info':m_info}]
        endfor
      else
        for i in range(len(menu))
          let item = menu[i]
          if tag !~# '^[?!]' && len(g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}[tag][1][item]) > 0 && g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}[tag][1][item][0] =~# '^\(BOOL\|'.item.'\)$'
            let item = item
          else
            let item .= '="'
          endif
          let final_menu += [item]
        endfor
      endif
      return final_menu

    endif
    " Close tag
    " let b:unaryTagsStack = 'base meta link hr br param img area input col'
    let b:unaryTagsStack = ''
    if context =~# '^\/'
      let opentag = xmlcomplete#GetLastOpenTag('b:unaryTagsStack')
      return [opentag.'>']
    endif

    " Complete elements of XML structure
    " TODO: #REQUIRED, #IMPLIED, #FIXED, #PCDATA - but these should be detected like
    " entities - in first run
    " keywords: CDATA, ID, IDREF, IDREFS, ENTITY, ENTITIES, NMTOKEN, NMTOKENS
    " are hardly recognizable but keep it in reserve
    " also: EMPTY ANY SYSTEM PUBLIC DATA
    if context =~# '^!'
      let tags = ['!ELEMENT', '!DOCTYPE', '!ATTLIST', '!ENTITY', '!NOTATION', '![CDATA[', '![INCLUDE[', '![IGNORE[']

      for m in tags
        if m =~ '^'.context
          let m = substitute(m, '^!\[\?', '', '')
          call add(res, m)
        elseif m =~ context
          let m = substitute(m, '^!\[\?', '', '')
          call add(res2, m)
        endif
      endfor

      return res + res2

    endif

    " Complete text declaration
    if context =~# '^?'
      let tags = ['?xml']

      for m in tags
        if m =~ '^'.context
          call add(res, substitute(m, '^?', '', ''))
        elseif m =~ context
          call add(res, substitute(m, '^?', '', ''))
        endif
      endfor

      return res + res2

    endif

    " Deal with tag completion.
    let opentag = xmlcomplete#GetLastOpenTag('b:unaryTagsStack')
    let opentag = substitute(opentag, '^\k*:', '', '')
    if opentag ==# ''
      "return []
      let tags = keys(g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]})
      call filter(tags, "v:val !~# '^vimxml'")
    else
      if !has_key(g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}, opentag)
        " Abandon when data file isn't complete
        return []
      endif
      let tags = g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}[opentag][0]
    endif

    let context = substitute(context, '^\k*:', '', '')

    for m in tags
      if m =~ '^'.context
        call add(res, m)
      elseif m =~ context
        call add(res2, m)
      endif
    endfor
    let menu = res + res2
    if b:xml_namespace ==# 'DEFAULT'
      let xml_namespace = ''
    else
      let xml_namespace = b:xml_namespace.':'
    endif
    if has_key(g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}, 'vimxmltaginfo')
      let final_menu = []
      for i in range(len(menu))
        let item = menu[i]
        if has_key(g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}['vimxmltaginfo'], item)
          let m_menu = g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}['vimxmltaginfo'][item][0]
          let m_info = g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}['vimxmltaginfo'][item][1]
        else
          let m_menu = ''
          let m_info = ''
        endif
        let final_menu += [{'word':xml_namespace.item, 'menu':m_menu, 'info':m_info}]
      endfor
    else
      let final_menu = map(menu, 'xml_namespace.v:val')
    endif

    return final_menu

  endif
endfunction
