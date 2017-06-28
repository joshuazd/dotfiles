let g:airline#themes#material#palette = {}

let s:bg_none = 'NONE'

let s:guibg = '#080808'
let s:guibg2 = '#3e515b'
let s:termbg = s:bg_none
let s:termbg2= 0

let s:N1 = [ s:guibg , '#6182b8' , 232 , 4 ]
let s:N2 = [ '#263238' , '#9e9e9e', s:termbg2, 247 ]
let s:N3 = [ '#82aaff' , s:guibg2, 12 , 8]
let g:airline#themes#material#palette.normal = airline#themes#generate_color_map(s:N1, s:N2, s:N3)
let g:airline#themes#material#palette.normal_modified = {
      \ 'airline_c': [ '#ffb62c' , '#3e515b', 3, 8   , ''     ] ,
      \ }


let s:I1 = [ s:guibg, '#ffb62c' , 232 , 3 ]
let s:I2 = s:N2
let s:I3 = [ '#ffcb6b' , s:guibg2, 11 , 8 ]
let g:airline#themes#material#palette.insert = airline#themes#generate_color_map(s:I1, s:I2, s:I3)
let g:airline#themes#material#palette.insert_modified = copy(g:airline#themes#material#palette.normal_modified)
let g:airline#themes#material#palette.insert_paste = {
      \ 'airline_a': [ s:I1[0]   , '#d78700' , s:I1[2] , 172     , ''     ] ,
      \ }


let g:airline#themes#material#palette.replace = {
      \ 'airline_a': [ s:I1[0]   , '#af0000' , s:I1[2] , 1     , ''     ] ,
      \ }
let g:airline#themes#material#palette.replace_modified = copy(g:airline#themes#material#palette.normal_modified)


let s:V1 = [ s:guibg, '#91b859' , 232, 10]
let s:V2 = s:N2
let s:V3 = [ '#c3e88d' , s:guibg2, 2 , 8 ]
let g:airline#themes#material#palette.visual = airline#themes#generate_color_map(s:V1, s:V2, s:V3)
let g:airline#themes#material#palette.visual_modified = copy(g:airline#themes#material#palette.normal_modified)


let s:IA  = [ '#d75f5f' , s:guibg2  , 167 , 8 , '' ]
let s:IA2 = [ '#6182b8' , s:guibg2 , 12 , 8, '' ]
let g:airline#themes#material#palette.inactive = airline#themes#generate_color_map(s:IA, s:IA2, s:IA2)
let g:airline#themes#material#palette.inactive_modified = {
      \ 'airline_c': [ '#ffcb6b', '', 3, '', '' ] ,
      \ }

" Warnings
let s:WI = [ '#282C34', '#E5C07B', 16, 202 ]
let g:airline#themes#material#palette.normal.airline_warning = [
            \ s:WI[0], s:WI[1], s:WI[2], s:WI[3]
            \ ]

let g:airline#themes#material#palette.normal_modified.airline_warning =
            \ g:airline#themes#material#palette.normal.airline_warning

let g:airline#themes#material#palette.insert.airline_warning =
            \ g:airline#themes#material#palette.normal.airline_warning

let g:airline#themes#material#palette.insert_modified.airline_warning =
            \ g:airline#themes#material#palette.normal.airline_warning

let g:airline#themes#material#palette.visual.airline_warning =
            \ g:airline#themes#material#palette.normal.airline_warning

let g:airline#themes#material#palette.visual_modified.airline_warning =
            \ g:airline#themes#material#palette.normal.airline_warning

let g:airline#themes#material#palette.replace.airline_warning =
            \ g:airline#themes#material#palette.normal.airline_warning

let g:airline#themes#material#palette.replace_modified.airline_warning =
            \ g:airline#themes#material#palette.normal.airline_warning

" Errors
let s:ER = [ '#282C34', '#E06C75', 16, 1 ]
let g:airline#themes#material#palette.normal.airline_error = [
            \ s:ER[0], s:ER[1], s:ER[2], s:ER[3]
            \ ]

let g:airline#themes#material#palette.normal_modified.airline_error =
            \ g:airline#themes#material#palette.normal.airline_error

let g:airline#themes#material#palette.insert.airline_error =
            \ g:airline#themes#material#palette.normal.airline_error

let g:airline#themes#material#palette.insert_modified.airline_error =
            \ g:airline#themes#material#palette.normal.airline_error

let g:airline#themes#material#palette.visual.airline_error =
            \ g:airline#themes#material#palette.normal.airline_error

let g:airline#themes#material#palette.visual_modified.airline_error =
            \ g:airline#themes#material#palette.normal.airline_error

let g:airline#themes#material#palette.replace.airline_error =
            \ g:airline#themes#material#palette.normal.airline_error

let g:airline#themes#material#palette.replace_modified.airline_error =
            \ g:airline#themes#material#palette.normal.airline_error
