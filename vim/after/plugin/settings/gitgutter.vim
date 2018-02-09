if exists('g:loaded_gitgutter') && g:loaded_gitgutter
  let g:gitgutter_enabled = 0
  let g:gitgutter_sign_modified_removed = '±'
  nmap <silent> <Space>hs <Plug>GitGutterStageHunk
  nmap <silent> <Space>hu <Plug>GitGutterUndoHunk
  nmap <silent> <Space>hp <Plug>GitGutterPreviewHunk
  nmap <silent> [h <Plug>GitGutterPrevHunk
  nmap <silent> ]h <Plug>GitGutterNextHunk
endif
